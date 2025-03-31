#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Main class for Delaunay triangulation
public struct DelaunayTriangulator {
    
    /// Calculate the Delaunay triangulation for a set of points
    /// - Parameter points: Array of points to triangulate
    /// - Returns: Array of triangles forming the Delaunay triangulation
    /// - Throws: DelaunayTriangulationError if the input is invalid or if numerical issues are encountered
    public static func triangulate(points: [Point]) throws -> [Triangle] {
        // Validate input
        if points.count < 3 {
            return []
        }
        
        // Check for duplicate points
        var uniquePoints = Set<Point>()
        for point in points {
            if uniquePoints.contains(point) {
                throw DelaunayTriangulationError.duplicatePoints
            }
            uniquePoints.insert(point)
        }
        
        // Check for collinearity - either with 3 points or for all points
        if points.count == 3 {
            let area = abs((points[0].x * (points[1].y - points[2].y) + 
                           points[1].x * (points[2].y - points[0].y) + 
                           points[2].x * (points[0].y - points[1].y)) / 2.0)
            if area < Double.ulpOfOne {
                throw DelaunayTriangulationError.collinearPoints
            }
        } else if points.count > 3 && areCollinear(points) {
            throw DelaunayTriangulationError.collinearPoints
        }
        
        // Create a super triangle that contains all points
        let superTriangle = try createSuperTriangle(for: points)
        
        // Start with the super triangle
        var triangles = [superTriangle]
        
        // Add each point one at a time
        for point in points {
            // Find all triangles whose circumcircle contains the point
            var badTriangles: [Triangle] = []
            
            for triangle in triangles {
                if triangle.isPointInCircumcircle(point) {
                    badTriangles.append(triangle)
                }
            }
            
            // Find the boundary of the polygonal hole
            var polygon: [Edge] = []
            
            for triangle in badTriangles {
                for edge in triangle.edges {
                    // Check if the edge is shared with any other bad triangle
                    let isShared = badTriangles.contains { t in
                        if t == triangle { return false }
                        return t.edges.contains(edge)
                    }
                    
                    // If the edge is not shared, it is part of the boundary
                    if !isShared {
                        polygon.append(edge)
                    }
                }
            }
            
            // Remove bad triangles
            triangles.removeAll { badTriangles.contains($0) }
            
            // Create new triangles from the point and each edge of the polygon
            for edge in polygon {
                do {
                    // Create a new triangle and add it
                    let newTriangle = try Triangle(p1: point, p2: edge.p1, p3: edge.p2)
                    triangles.append(newTriangle)
                } catch {
                    // Skip triangles that would be invalid (should be rare)
                    // This can happen due to numerical precision issues
                    continue
                }
            }
        }
        
        // Remove triangles that share vertices with the super triangle
        let superTriangleVertices = Set([superTriangle.p1, superTriangle.p2, superTriangle.p3])
        
        return triangles.filter { triangle in
            let triangleVertices = Set([triangle.p1, triangle.p2, triangle.p3])
            return triangleVertices.intersection(superTriangleVertices).isEmpty
        }
    }
    
    /// Create a "super triangle" that contains all the input points
    /// - Parameter points: The points to enclose
    /// - Returns: A triangle that contains all input points
    /// - Throws: DelaunayTriangulationError if the super triangle creation fails
    private static func createSuperTriangle(for points: [Point]) throws -> Triangle {
        guard !points.isEmpty else {
            // Default super triangle for empty point set
            return try Triangle(
                p1: Point(x: -1000, y: -1000),
                p2: Point(x: 1000, y: -1000),
                p3: Point(x: 0, y: 1000)
            )
        }
        
        // Find the bounds of the point set
        var minX = Double.infinity
        var minY = Double.infinity
        var maxX = -Double.infinity
        var maxY = -Double.infinity
        
        for point in points {
            minX = min(minX, point.x)
            minY = min(minY, point.y)
            maxX = max(maxX, point.x)
            maxY = max(maxY, point.y)
        }
        
        let dx = maxX - minX
        let dy = maxY - minY
        let dmax = max(dx, dy)
        let midX = (minX + maxX) / 2
        let midY = (minY + maxY) / 2
        
        // Make the super triangle large enough to contain all points
        // with a significant margin
        let margin = dmax * 10
        
        return try Triangle(
            p1: Point(x: midX - margin, y: midY - margin),
            p2: Point(x: midX + margin, y: midY - margin),
            p3: Point(x: midX, y: midY + margin)
        )
    }
    
    /// Calculate the Voronoi diagram from the Delaunay triangulation
    /// - Parameter triangles: Delaunay triangulation of a set of points
    /// - Returns: An array of edges representing the Voronoi diagram
    public static func voronoiDiagram(from triangles: [Triangle]) -> [Edge] {
        var voronoiEdges = Set<Edge>()
        
        // Dictionary to store adjacency information between triangles
        var adjacentTriangles: [Triangle: Set<Triangle>] = [:]
        
        // Build adjacency list
        for i in 0..<triangles.count {
            for j in (i+1)..<triangles.count {
                let t1 = triangles[i]
                let t2 = triangles[j]
                
                // Check if triangles share an edge
                let t1Vertices = Set([t1.p1, t1.p2, t1.p3])
                let t2Vertices = Set([t2.p1, t2.p2, t2.p3])
                let shared = t1Vertices.intersection(t2Vertices)
                
                if shared.count == 2 {
                    // Triangles share an edge
                    adjacentTriangles[t1, default: []].insert(t2)
                    adjacentTriangles[t2, default: []].insert(t1)
                }
            }
        }
        
        // For each pair of adjacent triangles, add an edge between their circumcenters
        for (triangle, adjacent) in adjacentTriangles {
            let c1 = triangle.circumcenter
            
            for adjTriangle in adjacent {
                let c2 = adjTriangle.circumcenter
                voronoiEdges.insert(Edge(p1: c1, p2: c2))
            }
        }
        
        return Array(voronoiEdges)
    }
    
    /// Check if a set of points are collinear (all lie on a single line)
    /// - Parameter points: Array of points to check
    /// - Returns: True if all points are collinear, false otherwise
    public static func areCollinear(_ points: [Point]) -> Bool {
        if points.count <= 2 {
            return true // Any two points are always collinear
        }
        
        // Take the first two points and use them to define a line
        let p1 = points[0]
        let p2 = points[1]
        
        // Check if all other points are on this line
        for i in 2..<points.count {
            let p3 = points[i]
            
            // Calculate area of triangle formed by three points
            // If area is (nearly) zero, points are collinear
            let area = abs((p1.x * (p2.y - p3.y) + p2.x * (p3.y - p1.y) + p3.x * (p1.y - p2.y)) / 2.0)
            
            if area > Double.ulpOfOne {
                return false // Found a point not on the line
            }
        }
        
        return true
    }
}

// Helper function to triangulate a set of point tuples
public func triangulate(points: [(Double, Double)]) throws -> [[(Double, Double)]] {
    let pointObjects = points.map { Point(x: $0.0, y: $0.1) }
    let triangles = try DelaunayTriangulator.triangulate(points: pointObjects)
    
    return triangles.map { [($0.p1.x, $0.p1.y), ($0.p2.x, $0.p2.y), ($0.p3.x, $0.p3.y)] }
}