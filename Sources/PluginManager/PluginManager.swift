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
import Logging
import Plugin

#if canImport(Darwin)
import Darwin
private let defaultPluginExtension = "dylib"
#elseif canImport(Glibc)
import Glibc
private let defaultPluginExtension = "so"
#else
#error("Unsupported Platform")
#endif

/// The coordinator that dynamically loads shared library plugins
///
public actor PluginManager<T : PluginFactory> {

  /// A successfully loaded plugin instance using the plugin dynamic library path as the key.
  ///
  public struct Plugin {
    /// The path to the plugin dynamic library.
    ///
    public var path : FilePath
    /// An instance of the factory class for this ``PluginManager`` that can create plugin instances.
    ///
    ///```swift
    ///  var pluginInstance = plugin.factory.create()
    ///  print(pluginInstance.name())
    ///```
    ///
    public var factory : T
    fileprivate var _dlHandle : UnsafeMutableRawPointer?
  }

  /// The currently successfully loaded plugins which can be used to create instances.
  ///
  ///
  /// ```swift
  ///  let pluginManager = try await PluginManager<PluginExampleAPIFactory>(withPath: validPath)
  ///  let pluginCount = await pluginManager.plugins.count
  ///
  ///  for (_, plugin) in await pluginManager.plugins {
  ///    var pluginInstance = plugin.factory.create()
  ///    pluginInstance.setPluginManagerExampleAPI(PluginManagerExampleAPIProvider())
  ///    print(pluginInstance.name())
  ///  }
  /// ```
  ///
  public var plugins : [FilePath:Plugin] = [:]
    
  private var pluginDirectory : FilePath = "/tmp/plugins"
  private let logger = Logger(label: "PluginManager")
  private let pluginSuffix : String
  
  /// Initialize the ``PluginManager`` and dynamically load plugin instances.
  /// By default all plugin shared libraries will be loaded from the given path.
  ///
  /// - Parameters:
  ///   - directoryPath: The filesystem directory path from where plugins will be loaded
  ///   - pluginExtension: Specifies a custom plugin extension to use, otherwise use the platform default (.dylib/.so/.dll)
  ///   - loadPlugins: Whether to load all the plugins from the specified directory as part of initialization, by default they will be loaded.
  public init(withPath directoryPath: FilePath,
              pluginExtension: String? = nil,
              loadPlugins: Bool = true) async throws {
    
    self.pluginDirectory = directoryPath

    if let pluginSuffix = pluginExtension {
      self.pluginSuffix = pluginSuffix
    } else {
      self.pluginSuffix = defaultPluginExtension
    }
    
    if loadPlugins {
      try self.loadPlugins()
    }
  }
}

extension PluginManager {
  typealias PluginFactoryFunctionPointer = @convention(c) () -> UnsafeMutableRawPointer
  
  private func loadPlugins() throws {
    
    logger.debug("Loading plugins from [\(self.pluginDirectory)] of type \(String.init(describing: T.self)).")
      for file in self.pluginDirectory.directoryEntries {
        if file.extension == defaultPluginExtension {
          do {
            try self.load (plugin: file)
          } catch PluginManagerError.missingPluginModuleEntrypoint(let path, let reason) {
            logger.debug("loadPlugin missing plugin module entry point for [\(path)], failed with reason [\(reason)]")
          } catch PluginManagerError.incompatibleFactoryClass(let path) {
            logger.debug("loadPlugin failed due to an incompatible factory class for [\(path)]")
          }
        }
      }
    logger.debug("Loaded \(self.plugins.count) plugins.")
  }
  
  fileprivate func _resolveFactoryFor(_ dlHandle: UnsafeMutableRawPointer?, _ symbol: String) -> T? {
    let pluginFactorySymbolReference = dlsym(dlHandle, symbol)

    guard pluginFactorySymbolReference != nil else {
      return nil
    }

    let pluginFactoryCreator: PluginFactoryFunctionPointer = unsafeBitCast(pluginFactorySymbolReference, to: PluginFactoryFunctionPointer.self)
    let pluginFactory = Unmanaged<T>.fromOpaque(pluginFactoryCreator()).takeRetainedValue() as T

    return pluginFactory
  }
  
  /// Try to load a specific plugin from the given path
  /// - Parameter path: The full path to the specific plugin to load including suffix, e.g. `/usr/local/plugins/myplugin.dylib`
  /// - Throws: ``PluginManagerError``
  ///
  /// ```swift
  ///  let pluginManager = try await PluginManager<PluginExampleAPIFactory>(withPath: "", loadPlugins: false)
  ///
  ///  try await pluginManager.load(plugin: "/usr/local/plugins/myplugin.dylib").
  /// ```
  public func load(plugin path: FilePath) throws {

    if plugins[path] != nil {
      logger.debug("loadPlugin called for \(path) which was already loaded")
      throw PluginManagerError.duplicatePlugin(path)
    }

    logger.debug("Loading plugin [\(path)]")

    try path.withPlatformString {
      // TODO: Check RTLD_ flags to use again
      guard let dlHandle = dlopen($0, RTLD_NOW|RTLD_LOCAL|RTLD_NODELETE) else {
        throw PluginManagerError.failedToLoadPlugin(path: path, errorMessage: String.init(cString: dlerror()))
      }
      
      guard let pluginFactory = _resolveFactoryFor(dlHandle, "_pluginFactory") else {
        throw PluginManagerError.missingPluginModuleEntrypoint(path: path, errorMessage: String.init(cString: dlerror()))
      }

       guard pluginFactory.compatible(withType: T.self) else {
        throw PluginManagerError.incompatibleFactoryClass(path)
       }
      
      plugins[path] = Plugin(path: path, factory: pluginFactory,  _dlHandle: dlHandle)
      logger.debug("Loaded plugin [\(path)] factory [\(String.init(describing: pluginFactory.self))]")
    }
  }
  
  /// Reload the plugin executable image to allow for on-the-fly new versions. Old instances will continue to run the original code.
  /// - Parameter path: The full path to the specific plugin to reload including suffix, e.g. `/usr/local/plugins/myplugin.dylib`
  public func reload(plugin path: FilePath) throws {
    logger.debug("Reloading plugin \(path)")
    try self.unload(plugin: path)
    try self.load(plugin: path)
  }

  private func _unloadPlugin(_ plugin: Plugin) {
    logger.debug("Unloading plugin \(plugin.path)")

    guard let dlHandle = plugin._dlHandle else {
      logger.debug("_unloadPlugin called for plugin._dlHandle that was nil for [\(plugin.path)]")
      return
    }
    
    if dlclose(dlHandle) == -1 {
      logger.debug("dlclose failed with \(String.init(cString: dlerror()))") // We don't throw on a failed dlclose, but lets warn about it
    }
  }

  /// Unload the plugin executable image and remove it from the internal ``plugins`` dictionary. Existing instances will continue to run the original code loaded.
  /// - Parameter path: The full path to the specific plugin to unload including suffix, e.g. `/usr/local/plugins/myplugin.dylib`
  public func unload(plugin path: FilePath) throws {
    guard let plugin = plugins[path] else {
      logger.debug("unloadPlugin failed as \(path) was not a previously loaded plugin.")
      throw PluginManagerError.unknownPlugin(path)
    }
    self._unloadPlugin(plugin)
    plugins[path] = nil
  }

  /// Unload all plugin executable images and remove them from the internal ``plugins`` dictionary. Existing plugin instances will continue to run the original code loaded.
  public func unloadAll() {
    logger.debug("Unloading all plugins:")

    for (_, value) in plugins {
        self._unloadPlugin(value)
    }
    plugins.removeAll()
  }
}
