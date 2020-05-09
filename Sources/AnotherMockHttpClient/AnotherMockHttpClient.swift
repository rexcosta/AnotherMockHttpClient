//
// The MIT License (MIT)
//
// Copyright (c) 2020 Effective Like ABoss, David Costa Gonçalves
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import AnotherSwiftCommonLib
import Combine
import Foundation

/// AnotherMockHttpClient is a NetworkProtocol implementation
/// - i'ts used to decorate a real NetworkProtocol
/// - intrecepts all requests and for the given request if there is a mock, the mock will be used instead
/// - could serve as an example for a cache mechanism
public final class AnotherMockHttpClient {
    
    private let queue: DispatchQueue
    private let decoder: JSONDecoder
    private let network: NetworkProtocol
    private let mocks: [MockHttpRequestProtocol]
    
    public init(queue: DispatchQueue, network: NetworkProtocol, mocks: [MockHttpRequestProtocol]) {
        self.queue = queue
        self.decoder = JSONDecoder()
        self.network = network
        self.mocks = mocks
    }
    
    public init(queue: DispatchQueue, decoder: JSONDecoder, network: NetworkProtocol, mocks: [MockHttpRequestProtocol]) {
        self.queue = queue
        self.decoder = decoder
        self.network = network
        self.mocks = mocks
    }
    
    private func findMock(for request: NetworkRequest) -> MockHttpRequestProtocol? {
        return mocks.first { $0.overrideStrategy.mock($0, shouldOverride: request) }
    }
    
}

// MARK: - NetworkProtocol
extension AnotherMockHttpClient: NetworkProtocol {
    
    public func requestData(request: NetworkRequest) -> AnyPublisher<Data, NetworkError> {
        guard let mock = findMock(for: request) else {
            return network.requestData(request: request)
        }
        return fetchData(mock: mock, for: request)
            .mapError({ error -> NetworkError in
                if let error = error as? NetworkError {
                    return error
                }
                return NetworkError.unknown(cause: error)
            })
            .eraseToAnyPublisher()
    }
    
    public func requestJsonObject(request: NetworkRequest) -> AnyPublisher<[String: Any], NetworkError> {
        guard let mock = findMock(for: request) else {
            return network.requestJsonObject(request: request)
        }
        return readJson(mock: mock, for: request)
    }
    
    public func requestJsonArray(request: NetworkRequest) -> AnyPublisher<[Any], NetworkError> {
        guard let mock = findMock(for: request) else {
            return network.requestJsonArray(request: request)
        }
        return readJson(mock: mock, for: request)
    }
    
    public func requestDecodable<T: Decodable>(request: NetworkRequest) -> AnyPublisher<T, NetworkError> {
        guard let mock = findMock(for: request) else {
            return network.requestDecodable(request: request)
        }
        return fetchData(mock: mock, for: request)
            .decode(type: T.self, decoder: decoder)
            .mapError({ error -> NetworkError in
                if let error = error as? NetworkError {
                    return error
                }
                if let decodeError = error as? DecodingError {
                    return NetworkError.decode(cause: decodeError)
                }
                return NetworkError.unknown(cause: error)
            }).eraseToAnyPublisher()
    }
    
}

// MARK: - Data Fetcher
extension AnotherMockHttpClient {
    
    private func fetchData(
        mock: MockHttpRequestProtocol,
        for request: NetworkRequest
    ) -> AnyPublisher<Data, Error> {
        
        // https://heckj.github.io/swiftui-notes/#reference-future
        return Deferred {
            return Future<Data, Error> { promise in
                self.queue.async {
                    let result = mock.readStrategy.read()
                    promise(result)
                }
            }
        }
        .delay(for: mock.delay, scheduler: queue)
        .eraseToAnyPublisher()
    }
    
    public func readJson<T>(
        mock: MockHttpRequestProtocol,
        for request: NetworkRequest
    ) -> AnyPublisher<T, NetworkError> {
        return fetchData(mock: mock, for: request)
            .tryMap({ data -> T in
                do {
                    guard let serializedObject = try JSONSerialization.jsonObject(with: data, options: []) as? T else {
                        let error = AnotherMockHttpClient.createMockError("Could not deserialize json fot the given type")
                        throw NetworkError.unknown(cause: error)
                    }
                    return serializedObject
                } catch {
                    let error = AnotherMockHttpClient.createMockError("Error deserializing json")
                    throw NetworkError.unknown(cause: error)
                }
            })
            .mapError({ error -> NetworkError in
                if let error = error as? NetworkError {
                    return error
                }
                return NetworkError.unknown(cause: error)
            })
            .eraseToAnyPublisher()
    }
    
}

// MARK: - Static Helpers
extension AnotherMockHttpClient {
    
    static func createMockError(_ failureReason: String) -> Error {
        var userInfo: [String: Any] = [:]
        
        userInfo[NSLocalizedDescriptionKey] = "This is just a mocked message"
        userInfo[NSLocalizedFailureReasonErrorKey] = failureReason
        userInfo[NSLocalizedRecoverySuggestionErrorKey] = "Check the mocked response"
        
        return NSError(domain: "AnotherMockHttpClient", code: -1, userInfo: userInfo)
    }
    
}
