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
import Foundation

/// MultipleMocksHttpRequest is a MockHttpRequest
/// Gives the possibility to have diferent responses for the same request
/// Internaly a MockReadStrategyProtocol array is used , and for each request it returns a element from the array.
/// - First request arrives it will use the first MockReadStrategyProtocol
/// - Second request arrives it will use the second MockReadStrategyProtocol
/// - When the array reaches it's end, it will start over from the first element
/// This could serve as an example for a more intelligent mock
public final class MultipleMocksHttpRequest: MockHttpRequestProtocol {
    
    private let lock = NSRecursiveLock()
    private var currentIndex: Int
    private let readers: [MockReadStrategyProtocol]
    
    public let delay: DispatchQueue.SchedulerTimeType.Stride
    public let overrideStrategy: MockOverrideStrategyProtocol
    
    public var readStrategy: MockReadStrategyProtocol {
        lock.lock()
        let currentFetcher = readers[currentIndex]
        currentIndex += 1
        if currentIndex >= readers.count {
            currentIndex = 0
        }
        lock.unlock()
        
        return currentFetcher
    }
    
    init(
        delay: DispatchQueue.SchedulerTimeType.Stride = 0,
        readers: [MockReadStrategyProtocol],
        overrideStrategy: MockOverrideStrategyProtocol
    ) {
        if readers.isEmpty {
            fatalError("[MultipleMocksHttpRequest] Fetchers can't be empty")
        }
        
        self.currentIndex = 0
        self.delay = delay
        self.readers = readers
        self.overrideStrategy = overrideStrategy
    }
    
    public convenience init(
        delay: DispatchQueue.SchedulerTimeType.Stride = 0,
        request: NetworkRequest,
        readers: [MockReadStrategyProtocol]
    ) {
        self.init(
            delay: delay,
            readers: readers,
            overrideStrategy: MockOverrideCompareStrategy(request: request)
        )
    }
    
}
