# ``SyncClient``

The `SyncClient` class provides a simple interface for making requests and handling responses in a synchronous way.

## Refer

For more information about Client Usage, see the <doc:Client>

## Topics

### Initializers

- ``init(auth:params:headers:cookies:cookieIdentifier:timeout:followRedirects:maxRedirects:eventHooks:baseURL:defaultEncoding:)``

### Making Request

- ``request(method:url:content:params:headers:timeout:auth:followRedirects:)``

- ``stream(method:url:content:params:headers:timeout:auth:followRedirects:chunkSize:)``
