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

/// Timeout In HttpX
public struct Timeout {
    // MARK: Lifecycle

    /// Initialize a new timeout.
    ///
    /// - Parameters:
    ///     - connect: The timeout for network connection in seconds. The timeout
    ///         control the time to establish a connection to the server. Default is 30 seconds.
    ///     - request: The timeout for request wait for next additional data in seconds. The
    ///         timeout control the time to wait for the next data to arrive. Default is 60 seconds.
    ///     - resource: The timeout for entire resource download in seconds. The timeout
    ///         control the time to download the entire resource. Default is 24 hours.
    public init(
        connect: TimeInterval = kDefaultConnectTimeout,
        request: TimeInterval = kDefaultRequestTimeout,
        resource: TimeInterval = kDefaultResourceTimeout
    ) {
        self.connect = connect
        self.request = request
        self.resource = resource
    }

    // MARK: Public

    /// The Timeout for network connection in seconds. The timeout control
    /// the time to establish a connection to the server. Default is 30 seconds.
    public var connect: TimeInterval

    /// The Timeout for request wait for next additional data in seconds. The
    /// timeout control the time to wait for the next data to arrive. Default is
    /// 60 seconds.
    public var request: TimeInterval

    /// The Timeout for entire resource download in seconds. The timeout
    /// control the time to download the entire resource. Default is 24 hours.
    public var resource: TimeInterval
}
