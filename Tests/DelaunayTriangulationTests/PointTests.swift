import Testing
#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
@testable import DelaunayTriangulation

struct PointTests {
    @Test func distance() {
        let p1 = Point(x: 0, y: 0)
        let p2 = Point(x: 3, y: 4)
        
        #expect(p1.distance(to: p2) == 5)
        #expect(p1.squaredDistance(to: p2) == 25)
    }
    
    @Test func equality() {
        let p1 = Point(x: 1.5, y: 2.5)
        let p2 = Point(x: 1.5, y: 2.5)
        let p3 = Point(x: 1.5, y: 3.0)
        
        #expect(p1 == p2)
        #expect(p1 != p3)
    }
    
    @Test func hashing() {
        let p1 = Point(x: 2, y: 3)
        let p2 = Point(x: 2, y: 3)
        let p3 = Point(x: 3, y: 2)
        
        let dict = [p1: "Point 1", p3: "Point 3"]
        
        #expect(dict[p2] == "Point 1")
        #expect(dict[p3] == "Point 3")
    }
}