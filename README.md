[![Swift version](https://img.shields.io/badge/Swift-5.5-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.5-orange?style=flat-square)
[![Ubuntu](https://github.com/hassila/swift-plugin-manager/actions/workflows/swift-linux.yml/badge.svg?branch=main)](https://github.com/hassila/swift-plugin-manager/actions/workflows/swift-linux.yml)
[![macOS](https://github.com/hassila/swift-plugin-manager/actions/workflows/swift-macos.yml/badge.svg)](https://github.com/hassila/swift-plugin-manager/actions/workflows/swift-macos.yml)
[![codecov](https://codecov.io/gh/hassila/swift-plugin-manager/branch/main/graph/badge.svg)](https://codecov.io/gh/hassila/swift-plugin-manager)

# PluginManager

Support for dynamic loading and management of plugins to extend hosting application functionality.

## Overview

A multi-platform server-side Swift Infrastructure to support a plugin architecture that allows for dynamically extended functionality of hosting applications.

The PluginManager is implemented as an actor type which takes a plugin type factory as a generic parameter allowing for multiple simultaneous PluginManagers each supporting a specific plugin type.

A plugin type is defined in terms of the protocol it implements, a sample is available in [swift-plugin-example-api](https://github.com/hassila/swift-plugin-example-api).

A concrete implementation of a Plugin of that plugin type (there can be several concrete implementations for a given type) is available as a sample in [swift-plugin-example](https://github.com/hassila/swift-plugin-example).

A hosting application can provide an API that allows the plugin to access functionality from the hosting application, an example of such an API is defined as a protocol in [swift-plugin-manager-example-api](https://github.com/hassila/swift-plugin-manager-example-api).

A given hosting application can load plugins and should implement the API that plugins can use, a sample hosting application is available as [swift-plugin-manager-example](https://github.com/hassila/swift-plugin-manager-example) which also can load the sample plugin.

The fundamental plugin protocol is available as a plugin package dependency [swift-plugin](https://github.com/hassila/swift-plugin).

## Sample usage

Load all plugins from a given directory, create the factory for each plugin type to create an instance and call a function that uses the host application API:
```swift
  let pluginManager = try await PluginManager<PluginExampleAPIFactory>(withPath: validPath)

  for (_, plugin) in await pluginManager.plugins {
    var myInstance = plugin.factory.create()
    myInstance.setPluginManagerExampleAPI(PluginManagerExampleAPIProvider())
    print(myInstance.callFunctionThatUsesHostingApplicationAPI())
  }
```

## Supported Platforms

PluginManager currently supports macOS and Linux with a Swift toolchain versin of at least 5.5 (as the PluginManager is implemented as an actor)

PluginManager uses and supports swift-log.

## Getting Started

You just need to do a few things to add plugin capabilities to your application:
1. Create an API protocol for the plugin (usually as a separate package, as multiple concrete plugins will depend on that)
2. Create a concrete plugin implementation that implements that API and that includes a trivial factory class to create instances
3. Add the Plugin Manager dependency to your hosting application and add code to load instances
4. (optionally) Add an API protocol for the hostsing application so the plugin can use specific features there.

For point 1 and 2, see the sample projects linked above.

For point 3, to add PluginManager as dependency in your own project to add plugin capabilities, it's as simple as adding a dependencies clause to your Package.swift:
```
dependencies: [
    .package(url: "https://github.com/hassile/swift-plugin-manager.git")
]
```

and then add the dependency to your target:
```
        .executableTarget(
            name: "PluginManagerExample",
            dependencies: [
              .product(name: "PluginManager", package: "swift-plugin-manager")
            ]),
```

The easiest approach to learn is probably to play with the samples published above that are minimal in scope, so download and run the example:

```
mkdir plugin-test
cd plugin-test
git clone https://github.com/hassila/swift-plugin-manager-example
git clone https://github.com/hassila/swift-plugin-example
cd swift-plugin-example
swift build
cd ../swift-plugin-manager-example
swift run
```

## Runtime warnings
A runtime warning will be issued when a plugin is loaded as the factory class will be implemented both in the hosting application and in the plugin that is loaded - the trivial transport class should be identical in both and the warning can be disregarded.

```
objc[21884]: Class _TtC16PluginExampleAPI23PluginExampleAPIFactory is implemented in both /Users/jocke/Library/Developer/Xcode/DerivedData/swift-plugin-manager-example-gpipkszbaeyszjgfyfslngejclgt/Build/Products/Debug/PluginManagerExample (0x100060e90) and /Users/jocke/GitHub/swift-plugin-example/.build/arm64-apple-macosx/debug/libPluginExample.dylib (0x1007cc108). One of the two will be used. Which one is undefined.
```

## Related projects and usage notes

Loading of plugins is fundamentally unsafe from a security perspective as it allows for arbitrary code execution and no sandboxing is performed. 
This makes use of this plugin infrastructur suitable for environments and use cases where the user/operator installing plugins have full control of what's loaded.

This package was primarily put together with server-swide Swift usage in mind. Similar functionality is available in [Foundation in Bundle](https://developer.apple.com/documentation/foundation/bundle) with some caveats - it [seems to require using Objective-C bridging headers](https://blog.pendowski.com/plugin-architecture-in-swift-ish/) for a "pure Swift" version and for e.g. Linux [some functionality like principalClass isn't yet implemented](https://github.com/apple/swift-corelibs-foundation/blob/main/Docs/Status.md). That being said, if you are building something only on Apple platforms and can accept a dependency on Foundation, it is a very reasonable alternative solution to consider and has a lot of additional features like co-packaging of resources.

This package does not depend on neither Foundation nor Objective-C facilities and works on both macOS and Linux.

Documentation is supplied in docc format, easiest is to open the package in xcode and build documentation, alternatively run docc from command line.

### Future directions

Add a proper github pipeline with autogenerating of html for GH pages in the future to make docs available without downloading package.

Autogeneration of plugin and hosting API:s semvers when doinga a release using Swift Package Managers diagnose-api-breaking-changes (previously named experimental-api-diff) feature. Then we can expose the semver as another known entry point in the module and check that it is compatible during loading.

Feedback and PR:s are welcome.

