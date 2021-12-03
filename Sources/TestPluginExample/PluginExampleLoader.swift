import TestPluginExampleAPI

@_cdecl("_pluginFactory")
public func _pluginFactory() -> UnsafeMutableRawPointer {
  return Unmanaged.passRetained(PluginExampleAPIFactory(PluginExample.self)).toOpaque()
}
