import Testing
@testable import DelaunayTriangulation

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif os(Windows)
import ucrt
#endif

struct DelaunayTriangulationTests {
    @Test func emptyTriangulation() throws {
        let triangles = try DelaunayTriangulator.triangulate(points: [])
        #expect(triangles.isEmpty)
        
        let onePoint = try DelaunayTriangulator.triangulate(points: [Point(x: 1, y: 1)])
        #expect(onePoint.isEmpty)
        
        let twoPoints = try DelaunayTriangulator.triangulate(points: [Point(x: 1, y: 1), Point(x: 2, y: 2)])
        #expect(twoPoints.isEmpty)
    }
    
    @Test func simpleTriangulation() throws {
        // Three points should form exactly one triangle
        let points = [
            Point(x: 0, y: 0),
            Point(x: 1, y: 0),
            Point(x: 0, y: 1)
        ]
        
        let triangles = try DelaunayTriangulator.triangulate(points: points)
        #expect(triangles.count == 1)
        
        let triangle = triangles[0]
        
        // Check that all points are vertices of the triangle
        let vertices = Set([triangle.p1, triangle.p2, triangle.p3])
        #expect(vertices.count == 3)
        #expect(vertices.contains(points[0]))
        #expect(vertices.contains(points[1]))
        #expect(vertices.contains(points[2]))
    }
    
    @Test func squareTriangulation() throws {
        // Four points in a square should form two triangles
        let points = [
            Point(x: 0, y: 0),
            Point(x: 1, y: 0),
            Point(x: 1, y: 1),
            Point(x: 0, y: 1)
        ]
        
        let triangles = try DelaunayTriangulator.triangulate(points: points)
        #expect(triangles.count == 2)
        
        // Collect all edges from the triangulation
        var edges = Set<Edge>()
        for triangle in triangles {
            for edge in triangle.edges {
                edges.insert(edge)
            }
        }
        
        // A triangulation of 4 points should have 5 edges
        #expect(edges.count == 5)
        
        // Check that the perimeter edges are present
        #expect(edges.contains(Edge(p1: points[0], p2: points[1])))
        #expect(edges.contains(Edge(p1: points[1], p2: points[2])))
        #expect(edges.contains(Edge(p1: points[2], p2: points[3])))
        #expect(edges.contains(Edge(p1: points[3], p2: points[0])))
    }
    
    @Test func delaunayProperty() throws {
        // Create a test case where the delaunay property is important
        let points = [
            Point(x: 0, y: 0),
            Point(x: 1, y: 0),
            Point(x: 0.5, y: 0.86), // Top of an equilateral triangle
            Point(x: 0.5, y: 0.1)   // Point inside the triangle, close to bottom edge
        ]
        
        let triangles = try DelaunayTriangulator.triangulate(points: points)
        
        // The Delaunay triangulation should not have an edge from (0,0) to (1,0)
        // because the point (0.5, 0.1) is inside the circumcircle of that triangle
        for triangle in triangles {
            let vertices = Set([triangle.p1, triangle.p2, triangle.p3])
            let hasBottom = vertices.contains(points[0]) && vertices.contains(points[1]) && vertices.contains(points[3])
            
            // If the triangle includes both bottom vertices and the inner point,
            // it shouldn't include the top point
            if hasBottom {
                #expect(!vertices.contains(points[2]))
            }
        }
        
        // Check for each resulting triangle that no other point is in its circumcircle
        for triangle in triangles {
            let vertices = Set([triangle.p1, triangle.p2, triangle.p3])
            
            for point in points {
                if !vertices.contains(point) {
                    #expect(!triangle.isPointInCircumcircle(point), "Point \(point) should not be in circumcircle of triangle \(triangle)")
                }
            }
        }
    }
    
    @Test func voronoiDiagram() throws {
        // Test with a simple square
        let points = [
            Point(x: 0, y: 0),
            Point(x: 1, y: 0),
            Point(x: 1, y: 1),
            Point(x: 0, y: 1)
        ]
        
        let triangles = try DelaunayTriangulator.triangulate(points: points)
        let voronoi = DelaunayTriangulator.voronoiDiagram(from: triangles)
        
        // For a square with 2 triangles, there should be 1 Voronoi edge
        #expect(voronoi.count == 1)
    }
    
    @Test func helperTriangulateFunction() throws {
        let pointTuples = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0)]
        let result = try triangulate(points: pointTuples)
        
        #expect(result.count == 1)
        #expect(result[0].count == 3)
        
        // Check that the result contains all the original points
        // We'll manually check each point since tuples aren't Hashable
        let resultPoints = result[0]
        #expect(resultPoints.contains { $0.0 == 0.0 && $0.1 == 0.0 })
        #expect(resultPoints.contains { $0.0 == 1.0 && $0.1 == 0.0 })
        #expect(resultPoints.contains { $0.0 == 0.0 && $0.1 == 1.0 })
    }
}