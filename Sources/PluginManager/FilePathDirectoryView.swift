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

#if canImport(Darwin)
import Darwin
typealias DirectoryStreamPointer = UnsafeMutablePointer<DIR>?
#elseif canImport(Glibc)
import Glibc
typealias DirectoryStreamPointer = OpaquePointer?
#else
#error("Unsupported Platform")
#endif

/// Extends FilePath with basic directory iteration capabilities
extension FilePath {
  
  /// `DirectoryView` provides an iteratable sequence of the contents of a directory referenced by a `FilePath`
  public struct DirectoryView {
    internal var _directoryStreamPointer: DirectoryStreamPointer = nil
    internal var _path: FilePath
    
    /// Initializer
    /// - Parameter path: The file system path to provide directory entries for, should reference a directory
    internal init(_ path: FilePath) {
      self._path = path
      self._path.withPlatformString {
        _directoryStreamPointer = opendir($0)
      }
    }
  }
  
  public var directoryEntries: DirectoryView {
     get { DirectoryView(self) }
  }
}

extension FilePath.DirectoryView: IteratorProtocol, Sequence {

  mutating public func next() -> FilePath? {
    guard let directoryStreamPointer = self._directoryStreamPointer else {
      return nil
    }

    guard let directoryEntry = readdir(directoryStreamPointer) else
    {
      closedir(directoryStreamPointer)
      _directoryStreamPointer = nil
      return nil
    }

    let fileName = withUnsafePointer(to: &directoryEntry.pointee.d_name) { (pointer) -> FilePath.Component in
        pointer.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: directoryEntry.pointee.d_name)) {
          guard let fileName = FilePath.Component.init(platformString: $0) else {
            fatalError("Could not initialize FilePath.Component from platformString \(String(cString:$0))")
          }
          return fileName
        }
      }
    return self._path.appending(fileName)
  }
}
