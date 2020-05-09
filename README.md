# AnotherMockHttpClient

AnotherMockHttpClient is a NetworkProtocol implementation.
 - I'ts used to decorate a real NetworkProtocol implementation
 - intrecepts all requests and for the given request if there is a mock, the mock will be used instead
 - could serve as an example for a cache mechanism
 
 Ex:
 ```swift
 let yourNetwork: NetworkProtocol = YourNetwork()
 let mockedNetwork: NetworkProtocol = AnotherMockHttpClient(..., network: yourNetwork)
```

## MockHttpRequestProtocol
MockHttpRequestProtocol defines the structure for a mock response.

### SingleMockHttpRequest
SingleMockHttpRequest is a MockHttpRequest implementation. 
It always use the same MockReadStrategyProtocol to mock the given MockOverrideStrategyProtocol.

 Ex: Mock a request to return always the json object provided, with a delay of 4s
 ```swift
 let request = ...
 
 SingleMockHttpRequest(
     delay: 4,
     request: request,
     readStrategy: DataMockReadStrategy.makeWithJsonValue(
         json: [
             "id": "1",
             "name": "jorge"
         ]
     )
 )
```

### MultipleMocksHttpRequest
MultipleMocksHttpRequest is a MockHttpRequest implementation.
Gives the possibility to have diferent responses for the same request.
Internaly a MockReadStrategyProtocol array is used , and for each request it returns a element from the array.
- First request arrives it will use the first MockReadStrategyProtocol
- Second request arrives it will use the second MockReadStrategyProtocol
- When the array reaches it's end, it will start over from the first element
This could serve as an example for a more intelligent mock.

 Ex: Mock a request to return between two json objects provided, with a delay of 4s
 ```swift
 let request = ...
 
 MultipleMocksHttpRequest(
     delay: 4,
     request: request,
     readers: [
         DataMockReadStrategy.makeWithJsonValue(
             json: [
                 "id": "1",
                 "name": "jorge"
             ]
         ),
         DataMockReadStrategy.makeWithJsonValue(
             json: [
                 "id": "2",
                 "name": "sara"
             ]
         )
     ]
 )
```

## MockOverrideStrategyProtocol
MockOverrideStrategy defines the strategy used to override a NetworkRequest.
Make your own implementation for custom override strategies.

### MockOverrideCompareStrategy
MockOverrideCompareStrategy is a MockOverrideStrategy to return NetworkRequest.deepEqual


## MockReadStrategyProtocol
Protocol that defines a strategy to read Data or Error to be used in MockHttpRequestProtocol.

### BundleMockReadStrategy
BundleMockReadStrategy is a MockReadStrategy to return always a Data fetched from a file in a Bundle.

### DataMockReadStrategy
DataMockReadStrategy is a MockReadStrategy to return always a Data object given at the constructor.

### FailureMockReadStrategy
FailureMockReadStrategy is a MockReadStrategy to return always an error object given at the constructor.
