<img src="http://i.imgur.com/sEM1zbl.jpg"/>

**Dispatcher** eases the pain of using [Grand Central Dispatch](https://developer.apple.com/library/mac/documentation/performance/reference/gcd_libdispatch_ref/Reference/reference.html) by introducing 4 new Swift classes.

- [Dispatcher](https://github.com/aleclarson/dispatcher/wiki/Dispatcher)

- [Queue](https://github.com/aleclarson/dispatcher/wiki/Queue)

- [Group](https://github.com/aleclarson/dispatcher/wiki/Group)

- [Timer](https://github.com/aleclarson/dispatcher/wiki/Timer)

[![Thank me!](http://img.shields.io/gratipay/aleclarson.svg "Thank me!")](https://gratipay.com/aleclarson/)

-

#### Requirements

- Swift 2.0+

-

#### Installation

##### [CocoaPods](http://cocoapods.org)

**Dispatcher** is not yet available on CocoaPods.

##### [Carthage](https://github.com/Carthage/Carthage)

```bash
github "aleclarson/dispatcher" "master"
```

##### Manually

Drag-and-drop the `Dispatcher.xcodeproj` into your own Xcode project. In your application target's **Build Phases**, add `Dispatcher.framework` to **Target Dependencies**, **Link Binary With Libraries**, and **Copy Files**.

If that gives you trouble, open the `Dispatcher.xcodeproj` in Xcode and build the framework target. Right-click `Dispatcher.framework` in the **Products** folder in your **Project Navigator** and click **Show in Finder**. Drag-and-drop the `Dispatcher.framework` from your finder into your Xcode project.
