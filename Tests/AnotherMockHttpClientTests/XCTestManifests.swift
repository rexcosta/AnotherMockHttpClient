import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(MultipleMocksHttpRequestTests.allTests),
        testCase(SingleMockHttpRequestTests.allTests),
        
        testCase(MockOverrideCompareStrategyTests.allTests),
        
        testCase(BundleMockReadStrategyTests.allTests),
        testCase(DataMockReadStrategyTests.allTests),
        testCase(FailureMockReadStrategyTests.allTests),
        
        testCase(AnotherMockHttpClientTests.allTests),
    ]
}
#endif
