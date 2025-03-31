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
    public static func triangulate(points: [Point]) -> [Triangle] {
        guard points.count >= 3 else {
            // Cannot form triangles with fewer than 3 points
            return []
        }
        
        // Create a super triangle that contains all points
        let superTriangle = createSuperTriangle(for: points)
        
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
                let newTriangle = Triangle(p1: point, p2: edge.p1, p3: edge.p2)
                triangles.append(newTriangle)
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
    private static func createSuperTriangle(for points: [Point]) -> Triangle {
        guard !points.isEmpty else {
            // Default super triangle for empty point set
            return Triangle(
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
        // with some margin
        let margin = dmax * 10
        
        return Triangle(
            p1: Point(x: midX - margin, y: midY - margin),
            p2: Point(x: midX + margin, y: midY - margin),
            p3: Point(x: midX, y: midY + margin)
        )
    }
    
    /// Calculate the Voronoi diagram from the Delaunay triangulation
    /// - Parameters:
    ///   - points: Original set of points
    ///   - triangles: Delaunay triangulation of the points
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
}

// Helper function to triangulate a set of point tuples
public func triangulate(points: [(Double, Double)]) -> [[(Double, Double)]] {
    let pointObjects = points.map { Point(x: $0.0, y: $0.1) }
    let triangles = DelaunayTriangulator.triangulate(points: pointObjects)
    
    return triangles.map { [($0.p1.x, $0.p1.y), ($0.p2.x, $0.p2.y), ($0.p3.x, $0.p3.y)] }
}