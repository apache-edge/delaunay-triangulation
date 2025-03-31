import Testing
#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
@testable import DelaunayTriangulation

struct ErrorHandlingTests {
    @Test func duplicatePoints() {
        // Arrange
        let points = [
            Point(x: 0, y: 0),
            Point(x: 1, y: 0),
            Point(x: 0, y: 1),
            Point(x: 0, y: 0) // Duplicate point
        ]
        
        // Act & Assert
        do {
            let _ = try DelaunayTriangulator.triangulate(points: points)
            #expect(false, "Should have thrown a duplicate points error")
        } catch let error as DelaunayTriangulationError {
            #expect(error == DelaunayTriangulationError.duplicatePoints)
        } catch {
            #expect(false, "Unexpected error type: \(error)")
        }
    }
    
    @Test func collinearPoints() {
        // Arrange
        let points = [
            Point(x: 0, y: 0),
            Point(x: 1, y: 1),
            Point(x: 2, y: 2)
        ]
        
        // Act & Assert
        do {
            let _ = try DelaunayTriangulator.triangulate(points: points)
            #expect(false, "Should have thrown a collinear points error")
        } catch let error as DelaunayTriangulationError {
            #expect(error == DelaunayTriangulationError.collinearPoints)
        } catch {
            #expect(false, "Unexpected error type: \(error)")
        }
    }
    
    @Test func invalidTriangle() {
        // Arrange
        let p1 = Point(x: 0, y: 0)
        let p2 = Point(x: 1, y: 1)
        let p3 = Point(x: 2, y: 2) // Collinear with p1 and p2
        
        // Act & Assert
        do {
            let _ = try Triangle(p1: p1, p2: p2, p3: p3)
            #expect(false, "Should have thrown an invalid triangle error")
        } catch let error as DelaunayTriangulationError {
            #expect(error == DelaunayTriangulationError.invalidTriangle)
        } catch {
            #expect(false, "Unexpected error type: \(error)")
        }
        
        // Test with duplicate vertices
        do {
            let _ = try Triangle(p1: p1, p2: p1, p3: p3)
            #expect(false, "Should have thrown an invalid triangle error")
        } catch let error as DelaunayTriangulationError {
            #expect(error == DelaunayTriangulationError.invalidTriangle)
        } catch {
            #expect(false, "Unexpected error type: \(error)")
        }
    }
    
    @Test func edgeCaseNearlyCollinearPoints() {
        // Arrange - points that are definitely not collinear
        let points = [
            Point(x: 0, y: 0),
            Point(x: 1, y: 0),
            Point(x: 0.5, y: 0.5),  // Clearly not collinear with the other points
            Point(x: 2, y: 0.2)
        ]
        
        // Act
        do {
            let triangles = try DelaunayTriangulator.triangulate(points: points)
            // Assert - should successfully triangulate non-collinear points
            #expect(!triangles.isEmpty)
        } catch {
            #expect(false, "Should not throw for non-collinear points: \(error)")
        }
    }
    
    @Test func collinearityDetection() {
        // Exactly collinear points
        let collinearPoints = [
            Point(x: 0, y: 0),
            Point(x: 1, y: 1),
            Point(x: 2, y: 2),
            Point(x: 3, y: 3)
        ]
        
        #expect(DelaunayTriangulator.areCollinear(collinearPoints))
        
        // Not collinear points
        let nonCollinearPoints = [
            Point(x: 0, y: 0),
            Point(x: 1, y: 1),
            Point(x: 2, y: 0)
        ]
        
        #expect(!DelaunayTriangulator.areCollinear(nonCollinearPoints))
        
        // Edge cases
        #expect(DelaunayTriangulator.areCollinear([]))
        #expect(DelaunayTriangulator.areCollinear([Point(x: 1, y: 1)]))
        #expect(DelaunayTriangulator.areCollinear([Point(x: 1, y: 1), Point(x: 2, y: 2)]))
    }
    
    @Test func errorDescriptions() {
        let collinearError = DelaunayTriangulationError.collinearPoints
        #expect(collinearError.description.contains("collinear"))
        
        let duplicateError = DelaunayTriangulationError.duplicatePoints
        #expect(duplicateError.description.contains("duplicate"))
        
        let invalidTriangleError = DelaunayTriangulationError.invalidTriangle
        #expect(invalidTriangleError.description.contains("Invalid triangle"))
        
        let numericError = DelaunayTriangulationError.numericalError("Test message")
        #expect(numericError.description.contains("Test message"))
        
        let generalError = DelaunayTriangulationError.general("General error")
        #expect(generalError.description == "General error")
    }
    
    @Test func triangleSkipValidation() {
        // This test ensures the skipValidation initializer works as expected
        let p1 = Point(x: 0, y: 0)
        let p2 = Point(x: 1, y: 1)
        let p3 = Point(x: 2, y: 2) // Collinear with p1 and p2
        
        // First verify these points create an invalid triangle
        do {
            let _ = try Triangle(p1: p1, p2: p2, p3: p3)
            #expect(false, "Should have thrown an error")
        } catch {
            // Expected error
        }
        
        // Now use the skipValidation initializer
        let triangle = Triangle(p1: p1, p2: p2, p3: p3, skipValidation: true)
        
        // The triangle should exist but be degenerate
        #expect(triangle.isDegenerate)
        #expect(triangle.area < Double.ulpOfOne)
    }
    
    @Test func pointOnEdge() {
        // Create a triangle
        let p1 = Point(x: 0, y: 0)
        let p2 = Point(x: 10, y: 0)
        let p3 = Point(x: 0, y: 10)
        
        let triangle = try! Triangle(p1: p1, p2: p2, p3: p3)
        
        // Test points on edges
        let pointOnEdge1 = Point(x: 5, y: 0) // On edge p1-p2
        #expect(triangle.isPointOnEdge(pointOnEdge1))
        
        let pointOnEdge2 = Point(x: 0, y: 5) // On edge p1-p3
        #expect(triangle.isPointOnEdge(pointOnEdge2))
        
        let pointOnEdge3 = Point(x: 5, y: 5) // On edge p2-p3
        #expect(triangle.isPointOnEdge(pointOnEdge3))
        
        // Test points not on edges
        let pointInside = Point(x: 3, y: 3)
        #expect(!triangle.isPointOnEdge(pointInside))
        
        let pointOutside = Point(x: 15, y: 15)
        #expect(!triangle.isPointOnEdge(pointOutside))
        
        // Test vertices
        #expect(triangle.isPointOnEdge(p1))
        #expect(triangle.isPointOnEdge(p2))
        #expect(triangle.isPointOnEdge(p3))
    }
}