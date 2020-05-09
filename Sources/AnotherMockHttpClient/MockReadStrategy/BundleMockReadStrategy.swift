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

/// BundleMockReadStrategy is a MockReadStrategy to return always a Data fetched from a file in a Bundle
public struct BundleMockReadStrategy: MockReadStrategyProtocol {
    
    private let bundle: Bundle
    private let fileName: String
    private let fileExtension: String
    
    public init(bundle: Bundle, fileName: String, fileExtension: String) {
        self.bundle = bundle
        self.fileName = fileName
        self.fileExtension = fileExtension
    }
    
    public func read() -> Result<Data, Error> {
        guard let url = bundle.url(forResource: fileName, withExtension: fileExtension) else {
            let error = AnotherMockHttpClient.createMockError(
                "Didn't find mock \(fileName) \(fileExtension) files"
            )
            return Result.failure(error)
        }
        
        do {
            let data = try Data(contentsOf: url)
            return Result.success(data)
        } catch {
            return Result.failure(error)
        }
    }
    
}

// MARK: Builders
extension BundleMockReadStrategy {
    
    /// Creates a MockReadStrategy to read from the app main bundle using the given name and the .json extension
    /// - Parameter fileName: the name of the file to read
    /// - Returns:a ready to use MockReadStrategyProtocol 
    static func jsonInMainBundle(fileName: String) -> MockReadStrategyProtocol {
        return BundleMockReadStrategy(bundle: .main, fileName: fileName, fileExtension: ".json")
    }
    
}
