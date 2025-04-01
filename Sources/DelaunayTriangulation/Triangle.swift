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
    
    /// Initialize a triangle with three points
    /// - Parameters:
    ///   - p1: First point
    ///   - p2: Second point
    ///   - p3: Third point
    /// - Throws: DelaunayTriangulationError if the triangle is invalid
    public init(p1: Point, p2: Point, p3: Point) throws {
        // Check for duplicate vertices
        if p1 == p2 || p2 == p3 || p3 == p1 {
            throw DelaunayTriangulationError.invalidTriangle
        }
        
        // Check for collinearity
        let area = abs((p1.x * (p2.y - p3.y) + p2.x * (p3.y - p1.y) + p3.x * (p1.y - p2.y)) / 2.0)
        if area < Double.ulpOfOne {
            throw DelaunayTriangulationError.invalidTriangle
        }
        
        self.p1 = p1
        self.p2 = p2
        self.p3 = p3
    }
    
    /// Initialize a triangle without validation (use with caution, mainly for internal use)
    /// - Parameters:
    ///   - p1: First point
    ///   - p2: Second point
    ///   - p3: Third point
    ///   - skipValidation: Flag to skip validation (always pass true)
    public init(p1: Point, p2: Point, p3: Point, skipValidation: Bool) {
        assert(skipValidation, "This initializer should only be used with skipValidation = true")
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
    
    /// Check if a point is on any edge of the triangle
    public func isPointOnEdge(_ point: Point) -> Bool {
        for edge in edges {
            if isPointOnLine(point, lineStart: edge.p1, lineEnd: edge.p2) {
                return true
            }
        }
        return false
    }
    
    /// Helper function to check if a point is on a line segment
    private func isPointOnLine(_ point: Point, lineStart: Point, lineEnd: Point) -> Bool {
        // First check if point is within the bounding box of the line
        let xMin = min(lineStart.x, lineEnd.x)
        let xMax = max(lineStart.x, lineEnd.x)
        let yMin = min(lineStart.y, lineEnd.y)
        let yMax = max(lineStart.y, lineEnd.y)
        
        if point.x < xMin || point.x > xMax || point.y < yMin || point.y > yMax {
            return false
        }
        
        // Check if point is on the line
        let crossProduct = abs((point.y - lineStart.y) * (lineEnd.x - lineStart.x) - 
                               (point.x - lineStart.x) * (lineEnd.y - lineStart.y))
        
        // If the cross product is close to zero, the point is on the line
        return crossProduct < Double.ulpOfOne * 10
    }
    
    /// Calculate the circumcenter of the triangle
    public var circumcenter: Point {
        do {
            return try calculateCircumcenter()
        } catch {
            // Fallback calculation for robustness
            // This shouldn't happen for valid triangles, but provides a failsafe
            let midpointAB = Point(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
            let midpointBC = Point(x: (p2.x + p3.x) / 2, y: (p2.y + p3.y) / 2)
            let midpointCA = Point(x: (p3.x + p1.x) / 2, y: (p3.y + p1.y) / 2)
            
            return Point(x: (midpointAB.x + midpointBC.x + midpointCA.x) / 3,
                         y: (midpointAB.y + midpointBC.y + midpointCA.y) / 3)
        }
    }
    
    /// Calculate the circumcenter using more robust methods
    private func calculateCircumcenter() throws -> Point {
        // Calculate perpendicular bisector of two edges
        let abMidpoint = Point(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
        let bcMidpoint = Point(x: (p2.x + p3.x) / 2, y: (p2.y + p3.y) / 2)
        
        // Calculate perpendicular slopes with better numerical stability
        let epsilon = 1e-10
        
        // Check for vertical/horizontal lines to avoid division by zero or near-zero
        let dx1 = p2.x - p1.x
        let dy1 = p2.y - p1.y
        let dx2 = p3.x - p2.x
        let dy2 = p3.y - p2.y
        
        // Handle nearly vertical lines
        if abs(dx1) < epsilon {
            // AB is nearly vertical
            if abs(dx2) < epsilon {
                // Both lines are nearly vertical - can't determine intersection
                throw DelaunayTriangulationError.numericalError("Both edges are nearly vertical")
            }
            
            // Calculate perpendicular slope for BC (horizontal if BC is vertical)
            let bcPerpSlope = abs(dy2) < epsilon ? Double.infinity : -dx2 / dy2
            
            // Calculate intersection
            if abs(bcPerpSlope) < epsilon {
                // BC perpendicular is nearly horizontal
                return Point(x: abMidpoint.x, y: bcMidpoint.y)
            } else if !bcPerpSlope.isFinite {
                // BC perpendicular is nearly vertical
                return Point(x: bcMidpoint.x, y: abMidpoint.y)
            } else {
                // BC has normal slope
                let bcIntercept = bcMidpoint.y - bcPerpSlope * bcMidpoint.x
                return Point(x: abMidpoint.x, y: bcPerpSlope * abMidpoint.x + bcIntercept)
            }
        } else if abs(dx2) < epsilon {
            // BC is nearly vertical
            
            // Calculate perpendicular slope for AB
            let abPerpSlope = abs(dy1) < epsilon ? Double.infinity : -dx1 / dy1
            
            // Calculate intersection
            if abs(abPerpSlope) < epsilon {
                // AB perpendicular is nearly horizontal
                return Point(x: bcMidpoint.x, y: abMidpoint.y)
            } else if !abPerpSlope.isFinite {
                // AB perpendicular is nearly vertical
                return Point(x: abMidpoint.x, y: bcMidpoint.y)
            } else {
                // AB has normal slope
                let abIntercept = abMidpoint.y - abPerpSlope * abMidpoint.x
                return Point(x: bcMidpoint.x, y: abPerpSlope * bcMidpoint.x + abIntercept)
            }
        }
        
        // Handle nearly horizontal lines
        if abs(dy1) < epsilon {
            // AB is nearly horizontal
            let _ = Double.infinity
            
            if abs(dy2) < epsilon {
                // Both lines are nearly horizontal
                throw DelaunayTriangulationError.numericalError("Both edges are nearly horizontal")
            }
            
            // Calculate perpendicular slope for BC
            let bcPerpSlope = abs(dx2) < epsilon ? 0 : -dx2 / dy2
            
            // Calculate intersection
            if abs(bcPerpSlope) < epsilon {
                // BC perpendicular is nearly horizontal
                return Point(x: abMidpoint.x, y: bcMidpoint.y)
            } else {
                // BC has normal slope
                let bcIntercept = bcMidpoint.y - bcPerpSlope * bcMidpoint.x
                return Point(x: abMidpoint.x, y: bcPerpSlope * abMidpoint.x + bcIntercept)
            }
        } else if abs(dy2) < epsilon {
            // BC is nearly horizontal
            let _ = Double.infinity
            
            // Calculate perpendicular slope for AB
            let abPerpSlope = abs(dx1) < epsilon ? 0 : -dx1 / dy1
            
            // Calculate intersection
            if abs(abPerpSlope) < epsilon {
                // AB perpendicular is nearly horizontal
                return Point(x: bcMidpoint.x, y: abMidpoint.y)
            } else {
                // AB has normal slope
                let abIntercept = abMidpoint.y - abPerpSlope * abMidpoint.x
                return Point(x: bcMidpoint.x, y: abPerpSlope * bcMidpoint.x + abIntercept)
            }
        }
        
        // Standard case - calculate perpendicular slopes
        let abSlope = dy1 / dx1
        let bcSlope = dy2 / dx2
        
        let abPerpSlope = -1 / abSlope
        let bcPerpSlope = -1 / bcSlope
        
        // Check if perpendicular lines are parallel (or nearly so)
        if abs(abPerpSlope - bcPerpSlope) < epsilon {
            // Use the third edge as fallback
            let caMidpoint = Point(x: (p3.x + p1.x) / 2, y: (p3.y + p1.y) / 2)
            let dx3 = p1.x - p3.x
            let dy3 = p1.y - p3.y
            
            if abs(dx3) < epsilon || abs(dy3) < epsilon {
                // The third edge is also problematic
                throw DelaunayTriangulationError.numericalError("Cannot calculate circumcenter reliably")
            }
            
            let caSlope = dy3 / dx3
            let caPerpSlope = -1 / caSlope
            
            // Try intersecting perpendicular of CA with AB
            if abs(caPerpSlope - abPerpSlope) >= epsilon {
                let abIntercept = abMidpoint.y - abPerpSlope * abMidpoint.x
                let caIntercept = caMidpoint.y - caPerpSlope * caMidpoint.x
                
                let x = (caIntercept - abIntercept) / (abPerpSlope - caPerpSlope)
                let y = abPerpSlope * x + abIntercept
                return Point(x: x, y: y)
            }
            
            // As a last resort, return the center of the triangle
            return Point(x: (p1.x + p2.x + p3.x) / 3, y: (p1.y + p2.y + p3.y) / 3)
        }
        
        // Calculate intercepts for perpendicular lines
        let abIntercept = abMidpoint.y - abPerpSlope * abMidpoint.x
        let bcIntercept = bcMidpoint.y - bcPerpSlope * bcMidpoint.x
        
        // Calculate intersection of two perpendicular bisectors
        let x = (bcIntercept - abIntercept) / (abPerpSlope - bcPerpSlope)
        let y = abPerpSlope * x + abIntercept
        
        return Point(x: x, y: y)
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
    
    /// Check if the triangle is degenerate (has zero area)
    public var isDegenerate: Bool {
        return area < Double.ulpOfOne
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