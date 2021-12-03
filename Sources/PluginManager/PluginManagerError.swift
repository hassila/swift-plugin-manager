//===----------------------------------------------------------------------===//
//
// This source file is part of the PluginManager open source project
//
// Copyright (c) 2021 Joakim Hassila and the PluginManager project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import SystemPackage

/// Throwable errors from ``PluginManager`` operations
public enum PluginManagerError : Error {
    /// The loading of the plugin shared library (.dylib or .so) at the given path failed.
    case failedToLoadPlugin(path: FilePath, errorMessage: String)
    /// The plugin is missing the required function entry point
    ///
    /// The plugin shared library must contain a `@_cdecl`'d function named `_pluginFactory` that returns the factory class to be used.
    ///
    ///```swift
    ///  @_cdecl("_pluginFactory")
    ///  public func _pluginFactory() -> UnsafeMutableRawPointer {
    ///    return Unmanaged.passRetained(PluginExampleAPIFactory(PluginExample.self)).toOpaque()
    ///  }
    ///```
    case missingPluginModuleEntrypoint(path: FilePath, errorMessage: String)
    /// The  factory class was of a different type than the generic factory type for this ``PluginManager`` instance, so loading failed.
    case incompatibleFactoryClass(FilePath)
    /// Attempt to explcitily load a plugin that already was loaded by the ``PluginManager``
    case duplicatePlugin(FilePath)
    /// Attempt to unload or reload a plugin that was unknown to the ``PluginManager``
    case unknownPlugin(FilePath)
}
