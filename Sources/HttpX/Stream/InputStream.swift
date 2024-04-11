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

public extension InputStream {
    /// Reads all available data from the input stream.
    ///
    /// This method opens the stream (if it's not already open), reads
    /// all available data into a buffer of a specified size, and returns
    /// the data as a `Data` object. It handles the stream opening,
    /// reading, and closing process, ensuring that the stream is properly
    /// closed after reading or in case of an error during the read operation.
    ///
    /// - Parameter bufferSize:
    ///     The size of the buffer used for reading data from the stream. Defaults to 1024 bytes.
    /// - Returns: A `Data` object containing all data read from the stream.
    ///     If an error occurs during reading, the data read up until the error is returned.
    func readAllData(bufferSize: Int = 1_024) -> Data {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            buffer.deallocate()
        }

        var data = Data()
        open()
        while hasBytesAvailable {
            let bytesRead = read(buffer, maxLength: bufferSize)
            if bytesRead < 0 {
                close()
                return data
            }
            data.append(buffer, count: bytesRead)
        }
        close()

        return data
    }
}
