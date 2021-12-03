import TestPluginExampleAPI
import TestPluginManagerExampleAPI

public struct PluginExample : PluginExampleAPI {
  var api : PluginManagerExampleAPI? = nil
  
  public init() {
  }
}

extension PluginExample {
  public mutating func setPluginManagerExampleAPI(_ pluginAPI: PluginManagerExampleAPI)
  {
      api = pluginAPI
  }

  public func name() -> String {
//    return "I was reloaded"
    if let a = api {
      return a.name()
    }
    return "failed to use api"
  }
}
