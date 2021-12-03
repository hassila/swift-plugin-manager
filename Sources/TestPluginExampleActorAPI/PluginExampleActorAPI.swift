import Plugin
import TestPluginManagerExampleActorAPI

public protocol PluginExampleActorAPI : Actor {
  init()
  func name() -> String
  func setPluginManagerExampleActorAPI(_ pluginAPI: PluginManagerExampleActorAPI)
}
