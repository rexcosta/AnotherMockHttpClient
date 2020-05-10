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

/// UrlMockReadStrategy is a MockReadStrategy to return always a Data fetched from a file in a Bundle
public struct UrlMockReadStrategy: MockReadStrategyProtocol {
    
    private let url: URL
    
    public init(url: URL) {
        self.url = url
    }
    
    public func read() -> Result<Data, Error> {
        do {
            let data = try Data(contentsOf: url)
            return Result.success(data)
        } catch {
            return Result.failure(error)
        }
    }
    
}

// MARK: Builders
extension UrlMockReadStrategy {
    
    /// Creates a MockReadStrategy to read from the app main bundle using the given name and the .json extension
    /// - Parameter fileName: the name of the file to read
    /// - Returns:a ready to use MockReadStrategyProtocol
    public static func jsonInMainBundle(fileName: String) throws -> MockReadStrategyProtocol {
        return try makeFromBundle(.main, fileName: fileName, fileExtension: "json")
    }
    
    /// Creates a MockReadStrategy to read from the given bundle using the given name and given extension
    /// - Parameters:
    ///   - bundle: the bundle to search
    ///   - fileName: the filename to search in the given bundle
    ///   - fileExtension: the file extension
    /// - Throws:
    ///   - `AnotherMockHttpClientError.fileNotPresentInBundle` if the file is not present in the bundle
    /// - Returns: a ready to use MockReadStrategyProtocol
    public static func makeFromBundle(_ bundle: Bundle, fileName: String, fileExtension: String) throws -> MockReadStrategyProtocol {
        guard let url = bundle.url(forResource: fileName, withExtension: fileExtension) else {
            throw AnotherMockHttpClientError.fileNotPresentInBundle(bundle, fileName, fileExtension)
        }
        return UrlMockReadStrategy(url: url)
    }
    
}
