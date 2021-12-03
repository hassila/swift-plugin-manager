# ``PluginManager``

Support for dynamic loading and management of plugins to extend hosting application functionality.

## Overview

A multi-platform server-side Swift Infrastructure to support a plugin architecture that allows for dynamically extend functionality of hosting applications.

#### Concepts

Term | Description
--- | ---
Hosting application | an executable that dynamically loads plugins at runtime
Plugin | a dynamic library that conforms to relevant protocols and conventions to support dynamic loading
Plugin type | specifies which Plugin API protocol the plugin implements, a hosting application can support multiple types of plugins
Plugin factory | a simple class that needs to be provided by a given plugin type and that can instantiate structs/classes/actors for the hosting applications use
Plugin API | the protocol that a given plugin type must implement
Plugin Manager API | to provide access to supporting functionality in the hosting application, the plugin is commonly provided one or more API surfaces to allow the plugin to use that functionality. 

The ``PluginManager`` is implemented as an actor type which takes a plugin type factory as a generic parameter allowing for multiple simultaneous PluginManagers each supporting a specific plugin type.

A plugin type is defined in terms of the protocol it implements, a sample is available in [swift-plugin-example-api](https://github.com/hassila/swift-plugin-example-api).

A concrete implementation of a Plugin of that plugin type (there can be several concrete implementations for a given type) is available as a sample in [swift-plugin-example](https://github.com/hassila/swift-plugin-example).

A hosting application can provide an API that allows the plugin to access functionality from the hosting application, an example of such an API is defined as a protocol in [swift-plugin-manager-example-api](https://github.com/hassila/swift-plugin-manager-example-api).

A given hosting application can load plugins and should implement the API that plugins can use, a sample hosting application is available as [swift-plugin-manager-example](https://github.com/hassila/swift-plugin-manager-example) which also can load the sample plugin.

The fundamental plugin protocol is available as a plugin package dependency [swift-plugin](https://github.com/hassila/swift-plugin).

### Related projects and usage notes

Loading of plugins is fundamentally unsafe by design as it allows for arbitrary code execution and no sandboxing is performed. This is only suitable for environments and use cases where the user/operator installing plugins have full control for obvious reasons.

This package was primarily put together with server-swide Swift usage in mind. Similar functionality is available in [Foundation in Bundle](https://developer.apple.com/documentation/foundation/bundle) with some caveats - it [seems to require using Objective-C bridging headers](https://blog.pendowski.com/plugin-architecture-in-swift-ish/) for a "pure Swift" version and for e.g. Linux [some functionality like principalClass isn't yet implemented](https://github.com/apple/swift-corelibs-foundation/blob/main/Docs/Status.md). That being said, if you are building something only on Apple platforms it is a very reasonable alternative solution to consider and has a lot of additional features like co-packaging of resources.

This package does not depend on neither Foundation nor Objective-C facilities and works on both macOS and Linux.

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

// - ``PluginManager``
