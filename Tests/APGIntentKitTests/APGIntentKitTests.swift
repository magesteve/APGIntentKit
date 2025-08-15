import Testing
@testable import APGIntentKit

@Test func versionTest() async throws {
    #expect(APGIntent.version == "1.0.0")
}
