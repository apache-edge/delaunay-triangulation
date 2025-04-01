import Testing
@testable import DelaunayTriangulation

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif os(Windows)
import ucrt
#endif

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

struct EdgeTests {
    @Test func edgeProperties() {
        let p1 = Point(x: 0, y: 0)
        let p2 = Point(x: 3, y: 4)
        let edge = Edge(p1: p1, p2: p2)
        
        #expect(edge.midpoint.x == 1.5)
        #expect(edge.midpoint.y == 2)
        #expect(edge.length == 5)
        #expect(edge.squaredLength == 25)
    }
    
    @Test func edgeNormalization() {
        let p1 = Point(x: 3, y: 4)
        let p2 = Point(x: 0, y: 0)
        let edge1 = Edge(p1: p1, p2: p2)
        let edge2 = Edge(p1: p2, p2: p1)
        
        // Points should be normalized, so p1 is always the "smaller" point
        #expect(edge1.p1.x == 0)
        #expect(edge1.p1.y == 0)
        #expect(edge1.p2.x == 3)
        #expect(edge1.p2.y == 4)
        
        #expect(edge2.p1.x == 0)
        #expect(edge2.p1.y == 0)
        #expect(edge2.p2.x == 3)
        #expect(edge2.p2.y == 4)
        
        #expect(edge1 == edge2)
    }
    
    @Test func edgeEquality() {
        let e1 = Edge(p1: Point(x: 1, y: 2), p2: Point(x: 3, y: 4))
        let e2 = Edge(p1: Point(x: 3, y: 4), p2: Point(x: 1, y: 2))
        let e3 = Edge(p1: Point(x: 1, y: 2), p2: Point(x: 3, y: 5))
        
        #expect(e1 == e2)
        #expect(e1 != e3)
    }
    
    @Test func edgeHashing() {
        let e1 = Edge(p1: Point(x: 1, y: 2), p2: Point(x: 3, y: 4))
        let e2 = Edge(p1: Point(x: 3, y: 4), p2: Point(x: 1, y: 2))
        
        let dict = [e1: "Edge 1"]
        
        #expect(dict[e2] == "Edge 1")
    }
}