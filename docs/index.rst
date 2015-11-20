.. sentry:edition:: self

    Raven-Objc
    ==========

.. sentry:edition:: on-premise, hosted

    .. class:: platform-objc

    Objective-C
    ===========

.. sentry:support-warning::

    The Objective-C SDK is maintained and supported by the Sentry
    community.  Learn more about the project on `GitHub
    <https://github.com/getsentry/raven-objc>`__.


The Objective-C client (raven-objc) allows the submission of information
to Sentry from Objective-C applications.

Installation
------------

The easiest way is to use `CocoaPods`_. It takes care of all required
frameworks and third party dependencies::

    $ pod 'Raven'

Alternatively, you can install manually.

1.  Get the code::

        git clone git://github.com/getsentry/raven-objc

2.  Drag the ``Raven`` subfolder to your project. Check both "copy items into
    destination group's folder" and your target.

Alternatively you can add this code as a Git submodule:

1.  Execute the following commands::

        cd [your project root]
        git submodule add git://github.com/getsentry/raven-objc

2.  Drag the ``Raven`` subfolder to your project. Uncheck the "copy items into
    destination group's folder" box, do check your target.

Configuration
-------------

While you are free to initialize as many instances of ``RavenClient`` as
is appropriate for your application, there is a shared singleton instance
that is globally available. This singleton instance is often configured in
your app delegate's ``application:didFinishLaunchingWithOptions:``
method:

.. sourcecode:: objc

    #import "RavenClient.h"

    - (BOOL)application:(UIApplication *)application
      didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        RavenClient *client = [RavenClient clientWithDSN:@"___DSN___"];
        /* ... */
        return YES;
    }

If you do not want to send to Sentry in debug builds, you can configure
``RavenClient`` without a DSN:

.. sourcecode:: objc

    RavenClient *client = [RavenClient clientWithDSN:nil];

The client will output the data as JSON, but not send anything to Sentry.

If you would like to use the singleton pattern, you can set the shared
client that is used with the ``+[setSharedClient:]`` class method. After
setting a client, you can retreive the singleton instance via the
``sharedClient`` singleton method:

.. sourcecode:: objc

    [RavenClient setSharedClient:client];
    NSLog(@"I am your RavenClient singleton: %@", [RavenClient sharedClient]);


.. _CocoaPods: http://cocoapods.org/

Sending Messages
----------------

Sending a basic message (note, does not include a stacktrace):

.. sourcecode:: objc

    [[RavenClient sharedClient] captureMessage:@"TEST 1 2 3"];

Sending a message with another level and a stacktrace:

.. sourcecode:: objc

    [[RavenClient sharedClient] captureMessage:@"TEST 1 2 3"
     level:kRavenLogLevelDebugInfo method:__FUNCTION__ file:__FILE__
     line:__LINE__];

Recommended macro to send a message with automatic stacktrace:

.. sourcecode:: objc

    RavenCaptureMessage(@"TEST %i %@ %f", 1, @"2", 3.0);

Handling Exceptions
-------------------

Setup a global exception handler (only iOS):

.. sourcecode:: objc

    - (BOOL)application:(UIApplication *)application
      didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        RavenClient *client = [RavenClient clientWithDSN:@"___DSN___"];
        [client setupExceptionHandler];
        /* ... */
        return YES;
    }

Or, capture a single exception:

.. sourcecode:: objc

    @try {
        [self performSelector:@selector(nonExistingSelector)];
    }
    @catch (NSException *exception) {
        RavenCaptureException(exception);
    }

You can also capture errors:

.. sourcecode:: objc

    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:@"some/path" error:&error];
    RavenCaptureError(error);

.. note:: when using the global exception handler, exceptions will be sent
   the next time the app is started.

ARC Support
-----------

raven-objc requires ARC support and should run on iOS 5.0 and Mac OS X
10.7.

Resources
---------

* `Bug Tracker <http://github.com/getsentry/raven-objc/issues>`_
* `Github Project <http://github.com/getsentry/raven-objc>`_
