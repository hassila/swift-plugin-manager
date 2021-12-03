import TestPluginManagerExampleAPI

public protocol PluginExampleAPI {
  init()
  func name() -> String
  mutating func setPluginManagerExampleAPI(_ pluginAPI: PluginManagerExampleAPI)
}
