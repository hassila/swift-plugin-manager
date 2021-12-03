import Plugin

public final class PluginExampleAPIFactory : PluginFactory { // rename the class after the API
  public typealias FactoryType = PluginExampleAPI // update this to the specific API implemented

  fileprivate let _pluginType: FactoryType.Type
    
  public init(_ pluginType: FactoryType.Type) {
    self._pluginType = pluginType
  }

  public func create() -> FactoryType {
    return _pluginType.init()
  }
}
