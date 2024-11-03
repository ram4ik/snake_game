import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
    override func awakeFromNib() {
        let flutterViewController = FlutterViewController.init()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)

        // Set fixed window size
        self.styleMask.remove(.resizable) // Make window non-resizable
        self.setContentSize(NSSize(width: 800, height: 900)) // Set fixed size (e.g., 800x600)

        RegisterGeneratedPlugins(registry: flutterViewController)

        super.awakeFromNib()
    }
}

