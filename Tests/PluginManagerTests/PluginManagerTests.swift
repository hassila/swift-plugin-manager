import XCTest
import SystemPackage
import TestPluginManagerExampleAPI
import TestPluginExampleAPI
import TestPluginExampleActorAPI

@testable import PluginManager

final class PluginManagerTests: XCTestCase {

  fileprivate var validPath : FilePath = ""
  fileprivate var invalidPath : FilePath = ""

  // find build directory for debug test
  private func _getPluginPath() -> FilePath {
    var path : FilePath = #file
    path.components.removeLast(3)
    path.components.append(".build")
    path.components.append("debug")
    return path
  }

  private func _getInvalidPluginPath() -> FilePath {
    return "/invalid/path/to/plugin"
  }

  override func setUp() {
    super.setUp()
    validPath = _getPluginPath()
    invalidPath = _getInvalidPluginPath()
  }
  
  func testThatLoadAndRunPluginReturnsCorrectValueForStruct() async throws {
    do {
      let pluginManager = try await PluginManager<PluginExampleAPIFactory>(withPath: validPath)
      let pluginCount = await pluginManager.plugins.count
      
      XCTAssertGreaterThan(pluginCount, 0)

      for (_, p) in await pluginManager.plugins {
        var x = p.factory.create()
        x.setPluginManagerExampleAPI(PluginManagerExampleAPIProvider())
        let name = x.name()
        XCTAssertEqual(name, "Awesome PluginManagerExampleAPIProvider callback")
      }
    }
  }

  func testThatLoadAndRunPluginReturnsCorrectValueForActor() async throws {
    do {
      let pluginManager = try await PluginManager<PluginExampleActorAPIFactory>(withPath: validPath)
      let pluginCount = await pluginManager.plugins.count
      
      XCTAssertGreaterThan(pluginCount, 0)

      for (_, p) in await pluginManager.plugins {
        let x = p.factory.create()
        await x.setPluginManagerExampleActorAPI(PluginManagerExampleActorAPIProvider())
        let name = await x.name()
        XCTAssertEqual(name, "Awesome PluginManagerExampleActorAPIProvider callback")
      }
    }
  }
  
  func testThatLoadAndUnloadResultsInEmptyPluginList() async throws {
    do {
      let pluginManager = try await PluginManager<PluginExampleAPIFactory>(withPath: validPath)

      var pluginCount = await pluginManager.plugins.count
      
      XCTAssertGreaterThan(pluginCount, 0)
      
      await pluginManager.unloadAll()

      pluginCount = await pluginManager.plugins.count

      XCTAssertEqual(pluginCount, 0)
    }
  }

  func testThatPluginLoadForInvalidPathThrows() async throws {
    let pluginManager = try await PluginManager<PluginExampleAPIFactory>(withPath: "", loadPlugins: false)
    let pluginCount = await pluginManager.plugins.count
    
    XCTAssertEqual(pluginCount, 0)
    do {
      try await pluginManager.load(plugin: invalidPath)
    } catch PluginManagerError.failedToLoadPlugin {
      return
    }
    XCTFail("PluginManager should have thrown a PluginManagerError.failedToLoadPlugin exception")
  }

  func testThatDuplicateLoadingOfPluginThrows() async throws {
    do {
      let pluginManager = try await PluginManager<PluginExampleAPIFactory>(withPath: validPath)
      let pluginCount = await pluginManager.plugins.count
      
      XCTAssertGreaterThan(pluginCount, 0)

      for (_, p) in await pluginManager.plugins {
        try await pluginManager.load(plugin: p.path)
      }
    } catch PluginManagerError.duplicatePlugin {
      return
    }
    XCTFail("PluginManager should have thrown a PluginManagerError.duplicatePlugin exception")
  }

  func testThatReloadOfUnknownPluginThrows() async throws {
    do {
     let pluginManager = try await PluginManager<PluginExampleAPIFactory>(withPath: "", loadPlugins: false)

      try await pluginManager.reload(plugin: invalidPath)

    } catch PluginManagerError.unknownPlugin {
      return
    }
    XCTFail("PluginManager should have thrown a PluginManagerError.unknownPlugin exception")
  }
  
  func testThatLoadOfPluginWithMissingEntrypointThrows() async throws {
    // Test for missing entry point in plugin module
    // This is actually tested but not propagated from loadPlugins, so need to sort out path for a manual load of
    // PluginManagerTestsInvalidPlugin.dylib
  }

  func testThatReloadOfPluginReturnsCorrectValue() async throws {
    // TODO: implement test for reload of module will give new updated value - need additional plugin which we copy over existing dylib
    // and check for return of new values
  }
}
