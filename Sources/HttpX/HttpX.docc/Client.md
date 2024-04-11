# Client

If you do anything more than experimentation, one-off scripts, or prototypes, then you should use a Client instance.

## Why use Client

When using the Function API in HttpX, a new URLSession instance is created for each request, leading to inefficiency and potential performance issues.

To address this problem, utilizing the Client instead of the Function API will allow for reusing the same URLSession provided by Swift Foundation and implementing connection pooling to reuse connections and resources effectively.

This brings the following benefits compared to the top-level Function API:

+ Reduced the latency between requests (no need re-handshaking)
+ persistent Cookies across requests
+ Apply the same configuration to all requests
+ Concurrent requests by multiple threads

## Making Request

To make a request using the Client, you need to create an instance of the Client and call the `request` method.

```swift
let client = SyncClient()
let response = client.request(
    method: .get,
    url: URLType.string("https://www.example.com")
)
```

This method take all same arguments as the top-level Function API, that means all features documented in the <doc:GettingStarted> page are available.

## Share Configuration

By Pass the Configuration when creating the Client instance, you can share the same configuration across all requests.

```swift
let client = SyncClient(
    auth: AuthType.basic(("user", "passwd")),
    headers: HeadersType.dictionary(["key": "value"]),
    timeout: 10,
    defaultEncoding: .utf8
)
```

Then the all requests made by the client will use the same configuration above unless you override it in the request.

## Merge Configuration

For specific Configuration, You can pass them to the request method. If you pass the same configuration as the Client instance, the request configuration will override the Client configuration.

```swift
let client = SyncClient(
    auth: AuthType.basic(("user", "passwd")),
    headers: HeadersType.dictionary(["key": "value"]),
    timeout: 10,
    defaultEncoding: .utf8
)

let response = client.request(
    method: .get,
    url: URLType.string("https://www.example.com"),
    headers: HeadersType.dictionary(["key": "value2"]),
    timeout: 5
)
// The request will use the headers `["key": "value2"]` and timeout `5` instead of the client configuration.
```

## Persistent Cookies by Pass CookieStorageIdentifier

Swift Foundation provides a way to store cookies persistently across different App or App Extension by using the class method `sharedCookieStorage(forGroupContainerIdentifier:)` of `HTTPCookieStorage`. You can pass the `cookieIdentifier` to the Client to enable this feature.

```swift
let client = SyncClient(
    cookieIdentifier: "com.example.app"
)
```

If you don't pass the `cookieStorageIdentifier`, the Client will create a new unique `HTTPCookieStorage` for each instance.
