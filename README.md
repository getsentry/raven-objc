# raven-objc

Objective-c client for [Sentry](https://www.getsentry.com/welcome/).


## Installation

The easiest way is to use [CocoaPods](http://cocoapods.org). It takes care of all required frameworks and third party dependencies:

```ruby
pod 'Raven', :git => 'https://github.com/getsentry/raven-objc.git', :tag => '1.0.1'
```

**Alternatively**, you can install manually.

1. Get the code: `git clone git://github.com/getsentry/raven-objc`
2. Drag the `Raven` subfolder to your project. Check both "copy items into destination group's folder" and your target.

Alternatively you can add this code as a Git submodule:

1. `cd [your project root]`
2. `git submodule add git://github.com/getsentry/raven-objc`
3. Drag the `Raven` subfolder to your project. Uncheck the "copy items into destination group's folder" box, do check your target.


## How to get started

While you are free to initialize as many instances of `RavenClient` as is appropriate for your application, there is a shared singleton instance that is globally available. This singleton instance is often configured in your app delegate's `application:didFinishLaunchingWithOptions:` method:

```objective-c
#import "RavenClient.h"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    RavenClient *client = [RavenClient clientWithDSN:@"[SENTRY_DSN]"];
    // [...]
    return YES;
}
```
If you would like to use the singleton pattern, you can set the shared client that is used with the
`+[setSharedClient:]` class method. After setting a client, you can retreive the singleton instance via
the `sharedClient` singleton method:

```objective-c
[RavenClient setSharedClient:client];
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
    RavenClient *client = [RavenClient clientWithDSN:@"https://[public]:[secret]@[server]/[project id]"];
    [client setupExceptionHandler];
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
    RavenCaptureException(exception);
}
```

You can also capture errors:

```objective-c
NSError *error;
[[NSFileManager defaultManager] removeItemAtPath:@"some/path" error:&error];
RavenCaptureError(error);
```

*Note: when using the global exception handler, exceptions will be sent the __next__ time the app is started.*

### ARC Support

raven-objc requires ARC support and should run on iOS 5.0 and Mac OS X 10.7.

## Issues and questions

Have a bug? Please create an issue on GitHub!

https://github.com/getsentry/raven-objc/issues


## Contributing

raven-objc is an open source project and your contribution is very much appreciated.

1. Check for [open issues](https://github.com/getsentry/raven-objc/issues) or [open a fresh issue](https://github.com/getsentry/raven-objc/issues/new) to start a discussion around a feature idea or a bug.
2. Fork the [repository on Github](https://github.com/getsentry/raven-objc) and make your changes.
3. Make sure to add yourself to AUTHORS and send a pull request.


## License

raven-objc is available under the MIT license. See the LICENSE file for more info.
