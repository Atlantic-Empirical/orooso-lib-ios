# OroosoLib

**OroosoLib** is an iOS Framework containing all the external code developed for Orooso (currently it consists of all the social integration classes).

The framework was built according to [this GitHub project](https://github.com/jverkoey/iOS-Framework).

## Adding the Framework Source to a Project

1. Move the framework source to a folder called `OroosoLib` inside the client project. You can also add `OroosoLib` as a git submodule.
2. Drag `OroosoLib.xcodeproj` inside the client project. **Warning:** the framework needs to be *inside* the client project, and not sharing the same workspace.
3. Select the `Framework` scheme and build the project one time.
3. In the **target** `Build Phases`:
    * Add `CFNetwork`, `SystemConfiguration`, `Security`, `CoreData`. `CoreTelephony`, `AddressBook`, `Accounts`, `Twitter` and `libz.1.2.5.dylib` frameworks to `Link Binary With Libraries`.
    * Add `OroosoLib` to `Target Dependencies`.
    * Add `OroosoLibResources` to `Target Dependencies`.
    * Add `libOroosoLib.a` to `Link Binary With Libraries`.
    * Open the group `Products` inside the framework project and drag `OroosoLib.bundle` to `Copy Bundle Resources`.
4. In the **project** `Build Settings`:
    * Add `"$(SRCROOT)/../../orooso-lib-ios"` to `Header Search Paths` (select the `recursive` option).
    * Add `-ObjC` to `Other Linker Flags` ([to enable framework categories](http://developer.apple.com/library/mac/#qa/qa1490/_index.html)).
5. Add `#import <OroosoLib/OroosoLib.h>` to the project PCH.
6. Select the client project scheme and build it.

## Adding the Compiled Framework to a Project

**TODO**: describe the steps here later.