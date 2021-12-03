import TestPluginExampleActorAPI
import TestPluginManagerExampleActorAPI

public actor PluginExampleActor : PluginExampleActorAPI {
  var api : PluginManagerExampleActorAPI? = nil
  
  public init() {
  }
  
  public func setPluginManagerExampleActorAPI(_ pluginAPI: PluginManagerExampleActorAPI)
  {
      api = pluginAPI
  }
}

extension PluginExampleActor {
  public func name() -> String {
      //    return "I was reloaded"
    if let a = api {
      return a.name()
    }
    return "failed to use api"
  }
}
