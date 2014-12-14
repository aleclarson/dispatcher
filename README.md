<img src="http://i.imgur.com/sEM1zbl.jpg"/>

-

###Queue

A `Queue` performs closures either serially (one at a time) or concurrently (many at a time).

[**Learn more**]()

-

###Job

A `Job` is an asynchronous task with the ability to depend on another `Job`. 

[**Learn more**]()

-

###Contract

A `Contract` tracks the completion of a group of asynchronous tasks. 

[**Learn more**]()

-

###Lock

A `Lock` wraps around a value to make it thread-safe. 

[**Learn more**]()

-

###Timer

A `Timer` performs a closure on the current thread after delaying. 

[**Learn more**]()

---

### Installation

**Dispatcher** is not yet available on CocoaPods.

In the meantime, drag-and-drop the `Dispatcher.xcodeproj` into your own Xcode project. In your application target's **Build Phases**, add `Dispatcher.framework` to **Target Dependencies**, **Link Binary With Libraries**, and **Copy Files**.

If that gives you trouble, open the `Dispatcher.xcodeproj` in Xcode and build the framework target. Right-click `Dispatcher.framework` in the **Products** folder in your **Project Navigator** and click **Show in Finder**. Drag-and-drop the `Dispatcher.framework` from your finder into your Xcode project.
