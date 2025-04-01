#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif os(Windows)
import ucrt
#endif

import Foundation
import Testing
@testable import DelaunayTriangulation

// This file provides math functions for all tests
