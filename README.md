# Introduction

[CrashProbe](http://crashprobe.com/) provides a set of test crashes that can be used to test crash reporting SDKs and symbolication implementations on iOS and OS X.

The project has been developed using Xcode 5.1.1 and has been tested with OS X 10.9.2 and iOS 7.1.1.

# Setup

1. Clone this repository.
2. Open the project in Xcode.
3. Integrate your crash reporting SDK into the required platform target (`CrashProbe` for OS X and `CrashProbeiOS` for iOS).
4. Build the app using the `Release` build configuration and install it on a device.

   Either use `Archive` or `Build for Profiling` and copy the app bundle onto the device. Using `Debug` build configuration will result in different results due to disabled compiler optimizations.
5. Start the app without the debugger being attached.
6. Choose a crash and trigger it.
7. Start the app again, the integrated SDK should now upload the crash report to its server.
8. Go back to step 5. and process the next crash. Otherwise continue with step 9.
9. Symbolicate the crash report(s).
10. Compare the symbolicated crash report(s) with the data available on the [CrashProbe](http://crashprobe.com/) website.

# Disclaimer

The suite of tests was developed by [Bit Stadium GmbH](http://hockeyapp.net/) for the [HockeyApp](http://hockeyapp.net) service.

# License

This project is released under the MIT license.
