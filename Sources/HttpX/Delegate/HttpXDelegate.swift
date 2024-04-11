// Copyright 2024-2024 Ruiyang Sun. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

// swiftlint:disable required_deinit

/// The delegate class for HttpX requests.
public class HttpXDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    // swiftlint:enable required_deinit
    public func urlSession(
        _: URLSession,
        didReceive _: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Make sure URLSession will not automatically handle the challenge
        completionHandler(.useCredential, nil)
    }

    public func urlSession(
        _: URLSession,
        task _: URLSessionTask,
        willPerformHTTPRedirection _: HTTPURLResponse,
        newRequest _: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        // Make sure URLSession will not automatically follow the redirection
        completionHandler(nil)
    }
}
