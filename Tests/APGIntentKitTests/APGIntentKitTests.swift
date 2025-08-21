import Testing
@testable import APGIntentKit

@Test func versionTest() async throws {
    #expect(APGIntent.version == "0.3.0")
}
