## Dispatcher

Apple's [Grand Central Dispatch](https://developer.apple.com/library/mac/documentation/performance/reference/gcd_libdispatch_ref/Reference/reference.html) deserves an API more suitable for Swift.

This wrapper aims to...

**1.** Be more concise

**2.** Require less cognitive load to use

**3.** Use Swift magic when it makes sense

**Disclaimer**: This wrapper does not provide everything that GCD does.

-

### Table of Contents

[Dispatcher](https://github.com/aleclarson/swift-dispatcher#dispatcher)

[DispatchQueue](https://github.com/aleclarson/swift-dispatcher#dispatchqueue)

[DispatchGroup](https://github.com/aleclarson/swift-dispatcher#dispatchgroup)

-

### Dispatcher

The `Dispatcher` is a singleton for accessing various pre-defined `DispatchQueue`s. It's also easy to make your own serial or concurrent queues!

You can't initialize your own `Dispatcher`. Instead, use `gcd`.

#### Properties

`let main: DispatchQueue`

> The equivalent of [`dispatch_get_main_queue()`](https://developer.apple.com/library/mac/documentation/performance/reference/gcd_libdispatch_ref/Reference/reference.html#//apple_ref/doc/uid/TP40008079-CH2-SW11)

`let global: DispatchQueue`

> The equivalent of `dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)`

`let background: DispatchQueue`

> The equivalent of `dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)`

`let high: DispatchQueue`

> The equivalent of `dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)`

`let low: DispatchQueue`

> The equivalent of `dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)`

#### Methods

`func serial (id: String) -> DispatchQueue`

> The equivalent of `dispatch_queue_create(id, DISPATCH_QUEUE_SERIAL)`

`func concurrent (id: String) -> DispatchQueue`

> The equivalent of `dispatch_queue_create(id, DISPATCH_QUEUE_CONCURRENT)`

-

### DispatchQueue

A `DispatchQueue` wraps around the traditional [`dispatch_queue_t`](https://developer.apple.com/library/mac/documentation/performance/reference/gcd_libdispatch_ref/Reference/reference.html#//apple_ref/doc/uid/TP40008079-CH102-SW8).

To initialize your own `DispatchQueue`, you must use `gcd.serial("name")` or `gcd.concurrent("name")`.

#### Properties

`let id: String`

> The unique identifier

`let q: dispatch_queue_t`

> A reference to the underlying `dispatch_queue_t` in case you need to pass it somewhere

#### Methods

`func async (block: () -> ())`

> The equivalent of [`dispatch_async()`](https://developer.apple.com/library/mac/documentation/performance/reference/gcd_libdispatch_ref/Reference/reference.html#//apple_ref/doc/uid/TP40008079-CH2-SW7)

`func sync (block: () -> ())`

> The equivalent of [`dispatch_sync()`](https://developer.apple.com/library/mac/documentation/performance/reference/gcd_libdispatch_ref/Reference/reference.html#//apple_ref/doc/uid/TP40008079-CH2-SW17)

#### How to use

Get back to the main thread.

```Swift
gcd.main.sync {
  // code goes here
}
```

If only a single thing needs to be performed, you can take advantage of Swift's `@autoclosure`.

```Swift
gcd.global.async(myClass.doLongOperation("http://sutura.io/wp-content/uploads/2014/08/Aug8th-techweekly.jpg", true))
```

Create your own `DispatchQueue`. You'll need to retain these ones yourself.

```Swift
let myQueue = gcd.concurrent("camera")
```

-

### DispatchGroup

A `DispatchGroup` wraps around the traditional [`dispatch_group_t`](https://developer.apple.com/library/mac/documentation/performance/reference/gcd_libdispatch_ref/Reference/reference.html#//apple_ref/doc/uid/TP40008079-CH102-SW3).

#### Properties

`let count: Int`

> The number of operations still running in the `DispatchGroup`


#### Methods

`func onFinish (block: () -> ())`

> Supply the block to be executed when the `DispatchGroup` is finished (a.k.a. when `count` reaches zero)


#### Constructors

`init ()`

> Creates a `DispatchGroup` with a `count` equal to `0`.

`convenience init (_ count: Int)`

> Creates a `DispatchGroup` with a `count` equal to the passed `Int`. This is incredibly useful when you know exactly how many operations will be waited on.

#### Operators

`DispatchGroup += Int`

> The equivalent of [`dispatch_group_enter()`](https://developer.apple.com/library/mac/documentation/performance/reference/gcd_libdispatch_ref/Reference/reference.html#//apple_ref/doc/uid/TP40008079-CH2-SW23) inside a for loop

`DispatchGroup -= Int`

> The equivalent of [`dispatch_group_leave()`](https://developer.apple.com/library/mac/documentation/performance/reference/gcd_libdispatch_ref/Reference/reference.html#//apple_ref/doc/uid/TP40008079-CH2-SW24) inside a for loop

#### How to use

```Swift
let group = DispatchGroup(2)

loadUserInfo(onFinish: {
  // ...
  
  group -= 1
})

loadFriends(onFinish: {
  // ...
  
  group -= 1
})

group.onFinish {
  println("Successfully loaded user info AND friends!")
}
```

-

Crafted by Alec Larson
