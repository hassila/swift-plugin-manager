import TestPluginExampleActorAPI

@_cdecl("_pluginFactory")
public func _pluginFactory() -> UnsafeMutableRawPointer {
  return Unmanaged.passRetained(PluginExampleActorAPIFactory(PluginExampleActor.self)).toOpaque()
}
