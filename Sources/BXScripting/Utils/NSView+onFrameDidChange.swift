//**********************************************************************************************************************
//
//  NSView+onFrameDidChange.swift
//	Reports any frame changes of a NSView in global window coordinates
//  Copyright ©2023 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit


//----------------------------------------------------------------------------------------------------------------------


extension NSView
{
	/// Observes frame changes of the NSView and all it ancestors. That way any size or position change that is visible in the window will be reported,
	/// regardless of where in the view hierarchy the change really occured. The frame is reported in global window coordinates.
	///
	/// You must retain the return value of this function, or the frame observing and reporting will not work correctly.
	
    func onFrameDidChange(_ frameDidChangeHandler:@escaping (CGRect)->Void) -> [Any]
    {
		var observers:[Any] = []
		var lastKnownFrame:CGRect = .zero
		
		// Walk through the view hierarchy from the current view all the way up to the window content view (i.e. root view)
		
		var view:NSView? = self
		
		while view != nil
		{
			// Observe frame changes at each level in the view hierarchy
			
			view?.postsFrameChangedNotifications = true
			
			observers += NotificationCenter.default.publisher(for:NSView.frameDidChangeNotification, object: view)
				.sink
				{
					[weak self] _ in
					guard let self = self else { return }
					
					let frame = self.frameInWindowCoordinates
					defer { lastKnownFrame = frame }
					
					// Only report a change if the resulting global frame has really changed
					
					if frame != lastKnownFrame
					{
						frameDidChangeHandler(frame)
					}
				}
			
			view = view?.superview
		}
		
		return observers
    }
    
    /// Returns the frame of a view in window coordinates
	
    var frameInWindowCoordinates:CGRect
    {
		self.convert(self.bounds, to:nil)
    }

	/// Return sthe root view in this view hierarchy
	
    var rootView:NSView?
    {
		self.window?.contentView
    }
    
}


//----------------------------------------------------------------------------------------------------------------------
