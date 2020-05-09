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

import Foundation

/// DataMockReadStrategy is a MockReadStrategy to return always a Data object given at the constructor
public struct DataMockReadStrategy: MockReadStrategyProtocol {
    
    private let data: Data
    
    public init(data: Data) {
        self.data = data
    }

    public func read() -> Result<Data, Error> {
        return Result.success(data)
    }
    
}

// MARK: Builders
extension DataMockReadStrategy {
    
    /// Creates a MockReadStrategy to use the data from the given json object
    /// Internally it uses the JSONSerialization
    /// - Parameter json: the json to convert to Data
    /// - Throws: It can throw any error associated with the JSONSerialization.data operation, also can throw if JSONSerialization.isValidJSONObject fails
    /// - Returns: a ready to use MockReadStrategyProtocol
    static func makeWithJsonValue(json: Any) throws -> MockReadStrategyProtocol {
        guard JSONSerialization.isValidJSONObject(json) else {
            throw AnotherMockHttpClient.createMockError("Trying to transform invalid json to data")
        }
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return DataMockReadStrategy(data: data)
    }
    
    /// Creates a MockReadStrategy to use the data from the given string object
    /// - Parameters:
    ///   - value: the string value to convert to Data
    ///   - encoding: the encoding to use on the string
    /// - Throws: can throw a informative error if the String -> Data fails
    /// - Returns: a ready to use MockReadStrategyProtocol
    static func makeWithString(value: String, encoding: String.Encoding) throws -> MockReadStrategyProtocol {
        guard let data = value.data(using: encoding) else {
            throw AnotherMockHttpClient.createMockError("Couldn't create data for the given string value")
        }
        return DataMockReadStrategy(data: data)
    }
    
}
