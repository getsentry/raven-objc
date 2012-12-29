# raven-objc

Objective-c client for [Sentry](https://www.getsentry.com/welcome/).


## Installation

1. Get the code: `git clone git://github.com/getsentry/raven-objc`
2. Drag the `Raven` subfolder to your project. Check both "copy items into destination group's folder" and your target.

Alternatively you can add this code as a Git submodule:

1. `cd [your project root]`
2. `git submodule add git://github.com/getsentry/raven-objc`
3. Drag the `Raven` subfolder to your project. Uncheck the "copy items into destination group's folder" box, do check your target.


## How to get started

While you are free to initialize as many instances of `RavenClient` as is appropriate for your application, there is a shared singleton instance that is globally available. This singleton instance is often configured in your app delegate's `application:didFinishLaunchingWithOptions:` method:

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [RavenClient clientWithDSN:@"[SENTRY_DSN]"];
    // [...]
    return YES;
}
```
The first `RavenClient` that is initialized is automatically configured as the singleton instance and becomes available via the `sharedClient` singleton method:

```objective-c
NSLog(@"I am your RavenClient singleton : %@", [RavenClient sharedClient]);
```

### Sending messages

```objective-c
// Sending a basic message (note, does not include a stacktrace):
[[RavenClient sharedClient] captureMessage:@"TEST 1 2 3"];

// Sending a message with another level and a stacktrace:
[[RavenClient sharedClient] captureMessage:@"TEST 1 2 3" level:kRavenLogLevelDebugInfo method:__FUNCTION__ file:__FILE__ line:__LINE__];

// Recommended macro to send a message with automatic stacktrace:
RavenCaptureMessage(@"TEST %i %@ %f", 1, @"2", 3.0);
```

### Handling exceptions

Setup a global exception handler:

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [RavenClient clientWithDSN:@"https://[public]:[secret]@[server]/[project id]"];
    [[RavenClient sharedClient] setupExceptionHandler];
    // [...]
    return YES;
}
```

Or, capture a single exception:

```objective-c
@try {
    [self performSelector:@selector(nonExistingSelector)];
}
@catch (NSException *exception) {
    [[RavenClient sharedClient] captureException:exception];
}
```

*Note: when using the global exception handler, exceptions will be sent the __next__ time the app is started.*


## Requirements

### JSON

raven-objc uses [`NSJSONSerialization`](http://developer.apple.com/library/mac/#documentation/Foundation/Reference/NSJSONSerialization_Class/Reference/Reference.html) to generate the JSON payload, if it is available. If your app targets a platform where this class is not available (i.e. iOS < 5.0) you can include one of the following JSON libraries to your project for raven-objc to automatically detect and use.

* [JSONKit](https://github.com/johnezang/JSONKit)
* [SBJson](https://stig.github.com/json-framework/)
* [YAJL](https://lloyd.github.com/yajl/)
* [NextiveJson](https://github.com/nextive/NextiveJson)

### ARC Support

raven-objc requires ARC support and should run on iOS 4.0 and higher. However, `RavenJSONUtilities.m` needs to be compiled with the `-fno-objc-arc` flag. To do this in Xcode, go to your active target and select the "Build Phases" tab. In the "Compiler Flags" column, set `-fno-objc-arc` for `RavenJSONUtilities.m`.

## Issues and questions

Have a bug? Please create an issue on GitHub!

https://github.com/kevinrenskers/raven-objc/issues


## Contributing

raven-objc is an open source project and your contribution is very much appreciated.

1. Check for [open issues](https://github.com/getsentry/raven-objc/issues) or [open a fresh issue](https://github.com/getsentry/raven-objc/issues/new) to start a discussion around a feature idea or a bug.
2. Fork the [repository on Github](https://github.com/getsentry/raven-objc) and make your changes.
3. Make sure to add yourself to AUTHORS and send a pull request.


## License

raven-objc is available under the MIT license. See the LICENSE file for more info.
