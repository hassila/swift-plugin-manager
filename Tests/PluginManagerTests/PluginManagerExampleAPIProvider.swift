import TestPluginManagerExampleAPI

struct PluginManagerExampleAPIProvider : PluginManagerExampleAPI {
  public func name() -> String
  {
    return "Awesome PluginManagerExampleAPIProvider callback"
  }
}
