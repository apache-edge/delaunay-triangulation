#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

#if canImport(Glibc)
import Glibc
#elseif os(Windows)
import ucrt
#endif

/// Represents a 2D point in the Delaunay triangulation
public struct Point: Hashable, Equatable {
    public let x: Double
    public let y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    /// Calculate squared distance to another point
    public func squaredDistance(to other: Point) -> Double {
        let dx = x - other.x
        let dy = y - other.y
        return dx * dx + dy * dy
    }
    
    /// Calculate Euclidean distance to another point
    public func distance(to other: Point) -> Double {
        return sqrt(squaredDistance(to: other))
    }
    
    public static func ==(lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}