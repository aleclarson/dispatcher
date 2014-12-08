<img src="http://i.imgur.com/sEM1zbl.jpg"/>

**Queue**: multi-threaded dispatcher
**Thread**: single-threaded dispatcher
**Dispatcher**: serial/concurrent task execution

**Job**: task chaining
**Lock**: resource synchronization
**Timer**: delayed closures
**Work**: task groups

#### Installation

**Dispatcher** is not yet available on CocoaPods.

In the meantime, drag-and-drop the `Dispatcher.xcodeproj` into your own Xcode project. In your application target's **Build Phases**, add `Dispatcher.framework` to **Target Dependencies**, **Link Binary With Libraries**, and **Copy Files**.

If that gives you trouble, open the `Dispatcher.xcodeproj` in Xcode and build the framework target. Right-click `Dispatcher.framework` in the **Products** folder in your **Project Navigator** and click **Show in Finder**. Drag-and-drop the `Dispatcher.framework` from your finder into your Xcode project.
