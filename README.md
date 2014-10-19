<img src="http://i.imgur.com/sEM1zbl.jpg"/>

**Dispatcher** eases the pain of using [Grand Central Dispatch](https://developer.apple.com/library/mac/documentation/performance/reference/gcd_libdispatch_ref/Reference/reference.html).

```Swift
gcd.async {
	
	// do something that takes time...

	gcd.main.sync {

		// update the user interface...
	}
}
```

### Queue

A `Queue` can execute closures serially (in order) or concurrently (possibly out of order).

To add a closure to a `Queue`, pass it to `async()` or `sync()`.

Use `sync()` if you want to wait for the closure to complete before moving on.

Use `async()` if you don't care when the closure completes.

This class **is** thread-safe!

-

#### What Queues already exist?

These 5 queues are at your disposal...

* `gcd`: The `Dispatcher` singleton. The concurrent `Queue` for default-priority tasks.

* `gcd.main`: The serial `Queue` where all your UI magic takes place.

* `gcd.high`: The concurrent `Queue` for high-priority tasks.

* `gcd.low`: The concurrent `Queue` for low-priority tasks.

* `gcd.background`: The concurrent `Queue` for no-priority tasks.

-

#### Which Queue am I currently on?

There are two ways to know which `Queue` you're currently on:

* `gcd.current`: Only available on `Dispatcher`.

* `gcd.isCurrent`: Available on all `Queue`s.

-

#### How do I make my own Queue?

Simply call `gcd.serial()` to make a serial `Queue`.

And call `gcd.concurrent()` to make a concurrent `Queue`.

You **must** retain these yourself!

-

### Group

A `Group` watches two or more concurrent tasks. 

If all tasks complete, the closure you pass to `done()` is called. 

If all tasks fail to complete in `x` seconds, the closure you pass to `wait()` is called.

This class **is** thread-safe!

```Swift
let group = Group(1)

gcd.async {

  // do some work...
  
  --group
}

if someCondition {
  
  ++group
  
  gcd.async {
    
    // do some other work...
    
    --group
  }
}

group.done {
	
  // do something when both are finished...
}

group.wait(1) {
  
  // do something if the group isn't done in 1 second...
}
```

-

### Timer

A `Timer` calls a closure after `x` seconds go by.

You **must** retain these yourself!

```Swift
let timer = Timer(0.5) {
  // do something after half a second passes...
}

timer.repeat(2) // repeat twice

timer.repeat() // repeat until stopped

timer.stop() // stops the Timer immediately

timer.fire() // completes the Timer immediately (only if not stopped)
```

**Important:** Be wary of reference cycles!

```Swift
class MyClass {
  var timer: Timer!
  func doSomething () {}
  init () {
    timer = Timer(1, doSomething) // this will cause a reference cycle
    timer = Timer(1) { [unowned self] in self.doSomething() } // this prevents a reference cycle
    timer = Timer(1, doSomething()) // so does this!
  }
}
```

-

#### Installation

**Dispatcher** is not yet available on CocoaPods.

In the meantime, drag-and-drop the `Dispatcher.xcodeproj` into your own Xcode project. In your application target's **Build Phases**, add `Dispatcher.framework` to **Target Dependencies**, **Link Binary With Libraries**, and **Copy Files**.

If that gives you trouble, open the `Dispatcher.xcodeproj` in Xcode and build the framework target. Right-click `Dispatcher.framework` in the **Products** folder in your **Project Navigator** and click **Show in Finder**. Drag-and-drop the `Dispatcher.framework` from your finder into your Xcode project.
