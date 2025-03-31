#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Represents a triangle in the Delaunay triangulation
public struct Triangle: Hashable, Equatable {
    public let p1: Point
    public let p2: Point
    public let p3: Point
    
    public init(p1: Point, p2: Point, p3: Point) {
        self.p1 = p1
        self.p2 = p2
        self.p3 = p3
    }
    
    /// The three edges of the triangle
    public var edges: [Edge] {
        return [
            Edge(p1: p1, p2: p2),
            Edge(p1: p2, p2: p3),
            Edge(p1: p3, p2: p1)
        ]
    }
    
    /// Check if the triangle contains a point
    public func contains(_ point: Point) -> Bool {
        // Barycentric coordinate method
        let denominator = ((p2.y - p3.y) * (p1.x - p3.x) + (p3.x - p2.x) * (p1.y - p3.y))
        
        // Check if triangle is degenerate
        if abs(denominator) < Double.ulpOfOne {
            return false
        }
        
        let a = ((p2.y - p3.y) * (point.x - p3.x) + (p3.x - p2.x) * (point.y - p3.y)) / denominator
        let b = ((p3.y - p1.y) * (point.x - p3.x) + (p1.x - p3.x) * (point.y - p3.y)) / denominator
        let c = 1 - a - b
        
        // Check if point is inside triangle
        return a >= 0 && a <= 1 && b >= 0 && b <= 1 && c >= 0 && c <= 1
    }
    
    /// Calculate the circumcenter of the triangle
    public var circumcenter: Point {
        // Calculate perpendicular bisector of two edges
        let abMidpoint = Point(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
        let bcMidpoint = Point(x: (p2.x + p3.x) / 2, y: (p2.y + p3.y) / 2)
        
        // Calculate perpendicular slopes
        let abSlope = (p2.x - p1.x) != 0 ? (p2.y - p1.y) / (p2.x - p1.x) : .infinity
        let bcSlope = (p3.x - p2.x) != 0 ? (p3.y - p2.y) / (p3.x - p2.x) : .infinity
        
        let abPerpSlope = abSlope != 0 ? (abSlope != .infinity ? -1 / abSlope : 0) : .infinity
        let bcPerpSlope = bcSlope != 0 ? (bcSlope != .infinity ? -1 / bcSlope : 0) : .infinity
        
        // Handle vertical and horizontal lines specially
        if abPerpSlope == .infinity {
            if bcPerpSlope == 0 {
                return Point(x: abMidpoint.x, y: bcMidpoint.y)
            } else {
                let bcIntercept = bcMidpoint.y - bcPerpSlope * bcMidpoint.x
                return Point(x: abMidpoint.x, y: bcPerpSlope * abMidpoint.x + bcIntercept)
            }
        } else if bcPerpSlope == .infinity {
            if abPerpSlope == 0 {
                return Point(x: bcMidpoint.x, y: abMidpoint.y)
            } else {
                let abIntercept = abMidpoint.y - abPerpSlope * abMidpoint.x
                return Point(x: bcMidpoint.x, y: abPerpSlope * bcMidpoint.x + abIntercept)
            }
        } else {
            // Calculate intercepts for perpendicular lines
            let abIntercept = abMidpoint.y - abPerpSlope * abMidpoint.x
            let bcIntercept = bcMidpoint.y - bcPerpSlope * bcMidpoint.x
            
            // Calculate intersection of two perpendicular bisectors
            if abPerpSlope == bcPerpSlope {
                // Parallel lines, use the midpoint of the third edge
                return Point(x: (p3.x + p1.x) / 2, y: (p3.y + p1.y) / 2)
            } else {
                let x = (bcIntercept - abIntercept) / (abPerpSlope - bcPerpSlope)
                let y = abPerpSlope * x + abIntercept
                return Point(x: x, y: y)
            }
        }
    }
    
    /// Calculate the squared radius of the circumscribed circle
    public var circumradiusSquared: Double {
        let center = circumcenter
        return center.squaredDistance(to: p1)
    }
    
    /// Check if a point is within the circumcircle of the triangle
    public func isPointInCircumcircle(_ point: Point) -> Bool {
        let center = circumcenter
        let radiusSquared = circumradiusSquared
        
        return point.squaredDistance(to: center) < radiusSquared + Double.ulpOfOne
    }
    
    /// Return the area of the triangle using the cross product method
    public var area: Double {
        let v1x = p2.x - p1.x
        let v1y = p2.y - p1.y
        let v2x = p3.x - p1.x
        let v2y = p3.y - p1.y
        
        let crossProduct = abs(v1x * v2y - v1y * v2x)
        return crossProduct / 2
    }
    
    public static func ==(lhs: Triangle, rhs: Triangle) -> Bool {
        let lhsSet = Set([lhs.p1, lhs.p2, lhs.p3])
        let rhsSet = Set([rhs.p1, rhs.p2, rhs.p3])
        return lhsSet == rhsSet
    }
    
    public func hash(into hasher: inout Hasher) {
        // Hash in a way that is order-independent
        var points = [p1, p2, p3]
        points.sort { p1, p2 in
            if p1.x == p2.x {
                return p1.y < p2.y
            }
            return p1.x < p2.x
        }
        
        for point in points {
            hasher.combine(point)
        }
    }
}