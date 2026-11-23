//
//  APIClientTests.swift
//  Capstone Project
//
//  Created by Manelin Rajan on 11/22/26.
//



import Foundation
import Testing
@testable import Capstone_Project

@Suite(.serialized)
@MainActor
struct APIClientTests {

    @Test func successfulResponseDecodesJSON() async throws {
        let json = """
        {"message":"success"}
        """.data(using: .utf8)!

        let session = makeSession(
            data: json,
            statusCode: 200
        )

        let client = APIClient(session: session)

        let result = try await client.get(
            "/test",
            responseType: TestResponse.self
        )

        #expect(result.message == "success")
    }

    @Test func serverErrorThrowsHTTPError() async {
        let session = makeSession(
            data: Data(),
            statusCode: 500
        )

        let client = APIClient(session: session)

        do {
            let _: TestResponse = try await client.get(
                "/test",
                responseType: TestResponse.self
            )
            Issue.record("Expected HTTP error")
        } catch let error as APIError {
            if case .httpError(500) = error {
                #expect(true)
            } else {
                Issue.record("Unexpected API error")
            }
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func invalidJSONThrowsDecodingError() async {
        let session = makeSession(
            data: Data("invalid json".utf8),
            statusCode: 200
        )

        let client = APIClient(session: session)

        do {
            let _: TestResponse = try await client.get(
                "/test",
                responseType: TestResponse.self
            )
            Issue.record("Expected decoding error")
        } catch is DecodingError {
            #expect(true)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    private func makeSession(
        data: Data,
        statusCode: Int
    ) -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral

        configuration.protocolClasses = [
            MockURLProtocol.self
        ]

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: [
                    "Content-Type": "application/json"
                ]
            )!

            return (response, data)
        }

        return URLSession(configuration: configuration)
    }
}

private struct TestResponse: Decodable {
    let message: String
}

private final class MockURLProtocol: URLProtocol {

    static var requestHandler: ((URLRequest) throws -> (
        HTTPURLResponse,
        Data
    ))?

    override class func canInit(
        with request: URLRequest
    ) -> Bool {
        true
    }

    override class func canonicalRequest(
        for request: URLRequest
    ) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(
                self,
                didFailWithError: URLError(.badServerResponse)
            )
            return
        }

        do {
            let (response, data) = try handler(request)

            client?.urlProtocol(
                self,
                didReceive: response,
                cacheStoragePolicy: .notAllowed
            )

            client?.urlProtocol(
                self,
                didLoad: data
            )

            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(
                self,
                didFailWithError: error
            )
        }
    }

    override func stopLoading() {}
}
