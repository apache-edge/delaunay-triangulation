#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Represents an edge in the Delaunay triangulation
public struct Edge: Hashable, Equatable {
    public let p1: Point
    public let p2: Point
    
    public init(p1: Point, p2: Point) {
        // Sort points to ensure that an edge is uniquely represented
        // regardless of the order in which the points are specified
        if p1.x < p2.x || (p1.x == p2.x && p1.y <= p2.y) {
            self.p1 = p1
            self.p2 = p2
        } else {
            self.p1 = p2
            self.p2 = p1
        }
    }
    
    public static func ==(lhs: Edge, rhs: Edge) -> Bool {
        return lhs.p1 == rhs.p1 && lhs.p2 == rhs.p2
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(p1)
        hasher.combine(p2)
    }
    
    /// Calculate the midpoint of the edge
    public var midpoint: Point {
        return Point(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }
    
    /// Calculate the squared length of the edge
    public var squaredLength: Double {
        return p1.squaredDistance(to: p2)
    }
    
    /// Calculate the length of the edge
    public var length: Double {
        return sqrt(squaredLength)
    }
}