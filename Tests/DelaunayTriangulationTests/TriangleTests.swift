import Testing
#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
@testable import DelaunayTriangulation

struct TriangleTests {
    @Test func triangleProperties() throws {
        let p1 = Point(x: 0, y: 0)
        let p2 = Point(x: 3, y: 0)
        let p3 = Point(x: 0, y: 4)
        let triangle = try Triangle(p1: p1, p2: p2, p3: p3)
        
        #expect(triangle.area == 6)
        
        // Check edges
        let edges = triangle.edges
        #expect(edges.count == 3)
        #expect(edges.contains(Edge(p1: p1, p2: p2)))
        #expect(edges.contains(Edge(p1: p2, p2: p3)))
        #expect(edges.contains(Edge(p1: p3, p2: p1)))
    }
    
    @Test func circumcircle() throws {
        // Test with a right triangle where we know the exact circumcenter
        let p1 = Point(x: 0, y: 0)
        let p2 = Point(x: 1, y: 0)
        let p3 = Point(x: 0, y: 1)
        let triangle = try Triangle(p1: p1, p2: p2, p3: p3)
        
        let center = triangle.circumcenter
        #expect(abs(center.x - 0.5) < 1e-10)
        #expect(abs(center.y - 0.5) < 1e-10)
        
        let radius = sqrt(0.5)
        #expect(abs(sqrt(triangle.circumradiusSquared) - radius) < 1e-10)
        
        // Test point in circumcircle
        let inside = Point(x: 0.5, y: 0.2)
        #expect(triangle.isPointInCircumcircle(inside))
        
        // Test point outside circumcircle
        let outside = Point(x: 1.5, y: 1.5)
        #expect(!triangle.isPointInCircumcircle(outside))
        
        // Test point exactly on circumcircle
        let onCircle = Point(x: 1, y: 1)
        #expect(triangle.isPointInCircumcircle(onCircle))
    }
    
    @Test func containsPoint() throws {
        let p1 = Point(x: 0, y: 0)
        let p2 = Point(x: 3, y: 0)
        let p3 = Point(x: 0, y: 3)
        let triangle = try Triangle(p1: p1, p2: p2, p3: p3)
        
        // Test point inside triangle
        let inside = Point(x: 1, y: 1)
        #expect(triangle.contains(inside))
        
        // Test point outside triangle
        let outside = Point(x: 2, y: 2)
        #expect(!triangle.contains(outside))
        
        // Test point on edge
        let onEdge = Point(x: 1.5, y: 0)
        #expect(triangle.contains(onEdge))
        
        // Test vertex
        #expect(triangle.contains(p1))
    }
    
    @Test func triangleEquality() throws {
        let t1 = try Triangle(p1: Point(x: 0, y: 0), p2: Point(x: 1, y: 0), p3: Point(x: 0, y: 1))
        let t2 = try Triangle(p1: Point(x: 1, y: 0), p2: Point(x: 0, y: 1), p3: Point(x: 0, y: 0))
        let t3 = try Triangle(p1: Point(x: 0, y: 0), p2: Point(x: 2, y: 0), p3: Point(x: 0, y: 1))
        
        #expect(t1 == t2) // Same triangle with different point order
        #expect(t1 != t3) // Different triangle
    }
    
    @Test func triangleHashing() throws {
        let t1 = try Triangle(p1: Point(x: 0, y: 0), p2: Point(x: 1, y: 0), p3: Point(x: 0, y: 1))
        let t2 = try Triangle(p1: Point(x: 1, y: 0), p2: Point(x: 0, y: 1), p3: Point(x: 0, y: 0))
        
        let dict = [t1: "Triangle 1"]
        
        #expect(dict[t2] == "Triangle 1")
    }
}