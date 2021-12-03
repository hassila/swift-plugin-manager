import TestPluginManagerExampleActorAPI

public actor PluginManagerExampleActorAPIProvider : PluginManagerExampleActorAPI {
  public nonisolated func name() -> String
  {
    return "Awesome PluginManagerExampleActorAPIProvider callback"
  }
}
