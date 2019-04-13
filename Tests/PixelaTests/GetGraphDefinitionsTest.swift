import Foundation
import XCTest
@testable import Pixela
import Promises

class GetGraphDefinitionsTest: XCTestCase {

    func testGetGraphDefinitions() {
        let httpClient = MockHttpClient(function: { (request: GetGraphDefinitionsRequest) -> RawGraphDefinitions in
            XCTAssertEqual("/v1/users/test-user/graphs", request.path)
            return RawGraphDefinitions(graphs: [
                RawGraphDefinition(id: "test-01", name: "graph-01", unit: "unit-01", type: "int", color: "shibafu", timezone: "UTC", purgeCacheURLs: ["https://example.com"]),
                RawGraphDefinition(id: "test-02", name: "graph-02", unit: "unit-02", type: "float", color: "ajisai", timezone: "Asia/Tokyo", purgeCacheURLs: []),
                RawGraphDefinition(id: "test-03", name: "graph-03", unit: "unit-03", type: "int", color: "momiji", timezone: "PST8PDT", purgeCacheURLs: ["https://example.com/1", "https://example.com/2"]),
            ])
        })

        let pixela = Pixela(username: "test-user", token: "test-token", httpClient: httpClient)
        let promise: Promise<GraphDefinitions> = pixela.getGraphDefinitions()
        promise.then(on: httpClient.queue, { (def: GraphDefinitions) -> Void in
            XCTAssertEqual(3, def.count)
        })
    }

    var allTests = [
        ("testGetGraphDefinitions", testGetGraphDefinitions)
    ]
}
