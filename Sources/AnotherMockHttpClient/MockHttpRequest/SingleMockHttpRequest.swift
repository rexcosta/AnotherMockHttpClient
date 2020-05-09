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

/// SingleMockHttpRequest is a MockHttpRequest
/// It always use the same MockReadStrategyProtocol to mock the given MockOverrideStrategyProtocol
public final class SingleMockHttpRequest: MockHttpRequestProtocol {
    
    public let delay: DispatchQueue.SchedulerTimeType.Stride
    public let readStrategy: MockReadStrategyProtocol
    public let overrideStrategy: MockOverrideStrategyProtocol
    
    public init(
        delay: DispatchQueue.SchedulerTimeType.Stride = 0,
        readStrategy: MockReadStrategyProtocol,
        overrideStrategy: MockOverrideStrategyProtocol
    ) {
        self.delay = delay
        self.readStrategy = readStrategy
        self.overrideStrategy = overrideStrategy
    }
    
    public convenience init(
        delay: DispatchQueue.SchedulerTimeType.Stride = 0,
        request: NetworkRequest,
        readStrategy: MockReadStrategyProtocol
    ) {
        self.init(
            delay: delay,
            readStrategy: readStrategy,
            overrideStrategy: MockOverrideCompareStrategy(request: request)
        )
    }
    
}
