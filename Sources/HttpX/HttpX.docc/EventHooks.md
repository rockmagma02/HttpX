# Event Hooks

HTTPX provides the hooks that allow you to hook into the request/response lifecycle. These hooks are useful for logging, debugging, and other purposes.

## Request Hooks

The Request Hooks HttpX accepts is defined as a function that takes am inout `Request` object.

```swift
let hooks = EventHooks(request: [
    { request in
        // Do something with the request
    },

    { request in
        // Do something with the request
    }
])
```

Then you can pass the hooks to the client.

```swift
let client = SyncClient(eventHooks: hooks)
```

## Response Hooks

The Response Hooks HttpX accepts is defined as a function that takes am inout `Response` object.

```swift
let hooks = EventHooks(response: [
    { response in
        // Do something with the response
    },

    { response in
        // Do something with the response
    }
])
```

Then you can pass the hooks to the client.

```swift
let client = SyncClient(eventHooks: hooks)
```

## Example

Here is an example of how to use the hooks. In this example, we will log the request and response.

```swift
let hooks = EventHooks(
    request: [
        { request in
            print("Request: \(request)")
        }
    ],
    response: [
        { response in
            print("Response: \(response)")
        }
    ]
)
