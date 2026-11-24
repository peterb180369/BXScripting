//**********************************************************************************************************************
//
//  NSVisualEffectView+frostedGlass.swift
//	Creates a NSVisualEffectView for a frosted glass window
//  Copyright ©2023-2026 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import AppKit


//----------------------------------------------------------------------------------------------------------------------


extension NSVisualEffectView
{
	/// Creates a NSVisualEffectView that blurs whatever is BEHIND the window.
	///
	/// The optional scrim is a constant dark tint that is composited ON TOP of the material. Since the material
	/// blends with the backdrop, the brightness of the glass otherwise follows whatever happens to be behind the
	/// window, and no foreground color can be readable against an unbounded background. The scrim puts a ceiling
	/// on that brightness: with a scrim alpha of a, the glass can never get lighter than (1-a), so the contrast
	/// of white text on top of it is guaranteed, regardless of what is behind the window.
	///
	/// The default arguments reproduce the original light frosted glass without a scrim, so existing call sites
	/// are unaffected.

    public static func frostedGlassView(appearance:NSAppearance.Name = .vibrantLight, material:NSVisualEffectView.Material = .popover, scrimAlpha:CGFloat = 0.0) -> NSVisualEffectView
    {
        let effectView = BXScrimmedVisualEffectView()
        effectView.appearance = NSAppearance(named:appearance)
        effectView.state = .active
        effectView.material = material
        effectView.blendingMode = .behindWindow
        effectView.isEmphasized = true		// Without this the material would dim whenever the app loses focus
        effectView.scrimAlpha = scrimAlpha

        return effectView
    }
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: -

/// A NSVisualEffectView with an optional dark scrim that bounds how bright the glass can get.

public class BXScrimmedVisualEffectView : NSVisualEffectView
{
	/// The opacity of the black scrim that is composited on top of the material. A value of 0.0 disables it.

	public var scrimAlpha:CGFloat = 0.0
	{
		didSet { self.updateScrim() }
	}

	/// The scrim has to be a subview, because the material is drawn by a private backdrop layer. Anything that
	/// is applied to the effect view's own layer would end up BELOW the material and be tinted away by it.

	private weak var scrimView:NSView? = nil

	private var observer:Any? = nil


//----------------------------------------------------------------------------------------------------------------------


	override public init(frame:NSRect)
	{
		super.init(frame:frame)
		self.setupObserver()
	}


	required public init?(coder:NSCoder)
	{
		super.init(coder:coder)
		self.setupObserver()
	}


	private func setupObserver()
	{
		// The "Reduce Transparency" setting can be changed while a tutorial is running

		self.observer = NSWorkspace.shared.notificationCenter.addObserver(
			forName: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
			object: nil,
			queue: .main)
		{
			[weak self] _ in self?.updateScrim()
		}
	}


	deinit
	{
		if let observer = observer
		{
			NSWorkspace.shared.notificationCenter.removeObserver(observer)
		}
	}


//----------------------------------------------------------------------------------------------------------------------


	// MARK: - Scrim


	private func updateScrim()
	{
		// With "Reduce Transparency" turned on the material renders opaque, so it already provides the
		// brightness ceiling by itself and an additional scrim would only make the panel needlessly dark.

		let isReducingTransparency = NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency
		let alpha = isReducingTransparency ? 0.0 : scrimAlpha

		// Nothing to do as long as there is no scrim and none is being asked for. Once it exists it is kept
		// around and merely set to clear, so that it can fade out instead of vanishing in a single frame.
		
		guard let scrimView = self.scrimView ?? (alpha > 0.0 ? self.createScrimView() : nil) else { return }

		// The implicit layer animation provides the crossfade when the scrim is changed at runtime

		CATransaction.begin()
		CATransaction.setAnimationDuration(0.2)
		defer { CATransaction.commit() }

		scrimView.layer?.backgroundColor = alpha > 0.0 ? NSColor(calibratedWhite:0.0, alpha:alpha).cgColor : NSColor.clear.cgColor
	}


	private func createScrimView() -> NSView
	{
		// BXEventIgnoringView makes sure that the scrim cannot swallow clicks that are meant for the controls

		let scrimView = BXEventIgnoringView(frame:self.bounds)
		scrimView.wantsLayer = true
		scrimView.autoresizingMask = [.width,.height]

		self.addSubview(scrimView)
		self.scrimView = scrimView

		return scrimView
	}
}


//----------------------------------------------------------------------------------------------------------------------
