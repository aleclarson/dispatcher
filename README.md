<img src="http://i.imgur.com/sEM1zbl.jpg"/>

-

###Queue

A `Queue` performs closures either serially (one at a time) or concurrently (many at a time).

[**Learn more**]()

```Swift
Queue.high.async {
  // Perform a long-running operation (like loading an image)

  Queue.main.async {
    // Update the UI
  }
}
```

-

###Job

A `Job` is an asynchronous task with the ability to depend on another `Job`. 

[**Learn more**]()

```Swift
Job<Void, UIImage>(Queue.high) { _, job in
  let image: UIImage = // ...
  if image != nil {
    job.finish(image) // `finish` or `fail` must always be called
  } else {
    job.fail(NSError(domain: "Dispatcher.example", code: 404, userInfo: nil))
  }
}
.then(Queue.main) { (image, job: JobController<Void>) in
  imageView.image = image
  job.finish()
}
.catch { error in
  // Handle errors
}
.performAll()
```

-

###Contract

A `Contract` tracks the completion of a group of asynchronous tasks. 

[**Learn more**]()

```Swift
let contract = Contract(2)

Queue.high.async {
  // Make a network request
  contract--
}

Queue.high.async {
  // Take a load off Annie
  contract--
}

contract.done {
  // Pat yourself on the back
}
```

-

###Lock

A `Lock` wraps around a value to make it thread-safe. 

[**Learn more**]()

```
let messageCount = Lock<Int>()

messageCount.value = 0

messageCount.lock { 
  count in
  if count > 0 {
    count = count - 1
  }
}

messageCount.map { $0 + 1 }
```

-

###Timer

A `Timer` performs a closure on the current thread after delaying. 

[**Learn more**]()

```
weak var timer = Timer(0.5) {
  // this will run after at least 0.5 seconds
}
```

---

### Installation

**Dispatcher** is not yet available on CocoaPods.

In the meantime, drag-and-drop the `Dispatcher.xcodeproj` into your own Xcode project. In your application target's **Build Phases**, add `Dispatcher.framework` to **Target Dependencies**, **Link Binary With Libraries**, and **Copy Files**.

If that gives you trouble, open the `Dispatcher.xcodeproj` in Xcode and build the framework target. Right-click `Dispatcher.framework` in the **Products** folder in your **Project Navigator** and click **Show in Finder**. Drag-and-drop the `Dispatcher.framework` from your finder into your Xcode project.
