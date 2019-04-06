import Foundation
@testable import Pixela
import XCTest
import Promises

class CreateGraphTest: XCTestCase {

    enum Invalid: Error {
        case error
    }

    func testCreateGraph() {
        let httpClient = MockHttpClient(function: { (req: CreateGraphRequest) -> PixelaResponse in
            XCTAssertEqual("/v1/users/test-user/graphs", req.path)
            XCTAssertEqual(HttpMethod.post, req.httpMethod)
            XCTAssertNotNil(req.body())
            XCTAssertEqual("test-token", req.userToken)
            Maybe(req.body()).get(or: Invalid.error)
                    .doOn(success: { (cg: CreateGraph) -> Void in
                        XCTAssertEqual("test-graph", cg.id)
                        XCTAssertEqual("Asia/Tokyo", cg.timezone)
                        XCTAssertEqual("times", cg.unit)
                        XCTAssertEqual("int", cg.type)
                        XCTAssertEqual("shibafu", cg.color)
                        XCTAssertNil(cg.selfSufficient)
                    }, failure: { (Error) -> Void in XCTFail("create-graph has body") })
            return PixelaResponse(isSuccess: true, message: "success")
        })
        let pixela = Pixela(username: "test-user", token: "test-token", httpClient: httpClient)
        let promise: Promise<Graph> = pixela.createGraph(id: "test-graph", name: "test-graph-name", unit: "times", type: .int, color: .shibafu, timezone: "Asia/Tokyo")
        promise.then(on: .global(), { (graph: Graph) -> Void in
            XCTAssertEqual("graph[username:test-user,graph:test-graph]", graph.description)
        }).catch(on: .global(), { (error: Error) -> Void in
            XCTFail("\(error)")
        })
    }

    static var allTests = [
        ("testCreateGraph", testCreateGraph)
    ]
}
