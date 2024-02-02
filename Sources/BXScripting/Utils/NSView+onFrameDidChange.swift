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
	
    public func onFrameDidChange(_ frameDidChangeHandler:@escaping (CGRect)->Void) -> [Any]
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
    
    /// Returns the frame of a view in the coordinates of the window content view.
	///
	/// In almost all cases this is equivalent to window coordinates. However there are some cases where this is not true, e.g. for popovers, where the window is larger than its content view (because of the irregular window shape).
	
    public var frameInWindowCoordinates:CGRect
    {
		self.convert(self.bounds, to:rootView)
    }

	/// Returns the root view in this view hierarchy
	
    public var rootView:NSView?
    {
		self.window?.contentView
    }
}


    
//----------------------------------------------------------------------------------------------------------------------


extension NSWindow
{
    /// Creates a NSView that is added to the contentView of the this NSWindow.
	///
	/// The new subview always matches the frame of the specified view, regardless of where in the view hierarchy it sits.
	
    public func addSubviewMatchingFrame(of view:NSView) -> NSView?
    {
		let frame = view.frameInWindowCoordinates
		let newView = BXEventIgnoringView(frame:frame)
		newView.wantsLayer = true
		newView.clipsToBounds = false
		
		self.contentView?.addSubview(newView) //, positioned:.above, relativeTo:nil)
	
		newView.frameObservers = view.onFrameDidChange
		{
			[weak newView] in newView?.frame = $0
		}
		
		return newView
    }
}


//----------------------------------------------------------------------------------------------------------------------


extension NSView
{
    private static var frameObserversKey = "frameObservers"

    public var frameObservers:[Any]?
    {
        set
        {
            objc_setAssociatedObject(self, &NSView.frameObserversKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }

        get
        {
            return objc_getAssociatedObject(self, &NSView.frameObserversKey) as? [Any]
        }
     }
}


//----------------------------------------------------------------------------------------------------------------------


/// This custom NSView sublcass is completely transparent to mouse event, making sure that any views below (ancenstors or sibling) will
/// receive the mouse event and can handle any installed NSGestureRecognizers.

class BXEventIgnoringView : NSView
{
	override func hitTest(_ point:NSPoint) -> NSView?
	{
		nil
	}

	override func acceptsFirstMouse(for event:NSEvent?) -> Bool
	{
		return false
	}
}


//----------------------------------------------------------------------------------------------------------------------
