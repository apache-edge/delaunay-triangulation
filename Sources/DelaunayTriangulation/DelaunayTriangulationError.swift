#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Errors that can occur during triangulation
public enum DelaunayTriangulationError: Error, CustomStringConvertible, Equatable {
    /// Thrown when attempting to triangulate points that lie on a line
    case collinearPoints
    
    /// Thrown when input contains duplicate points
    case duplicatePoints
    
    /// Thrown when attempting to create a triangle with invalid vertices (e.g., duplicate vertices)
    case invalidTriangle
    
    /// Thrown when a numerical calculation error occurred (e.g., during circle center calculation)
    case numericalError(String)
    
    /// General error with custom message
    case general(String)
    
    public var description: String {
        switch self {
        case .collinearPoints:
            return "All input points are collinear (lie on a straight line)"
        case .duplicatePoints:
            return "Input contains duplicate points"
        case .invalidTriangle:
            return "Invalid triangle: duplicate vertices or collinear points"
        case .numericalError(let message):
            return "Numerical calculation error: \(message)"
        case .general(let message):
            return message
        }
    }
    
    public static func ==(lhs: DelaunayTriangulationError, rhs: DelaunayTriangulationError) -> Bool {
        switch (lhs, rhs) {
        case (.collinearPoints, .collinearPoints),
             (.duplicatePoints, .duplicatePoints),
             (.invalidTriangle, .invalidTriangle):
            return true
        case (.numericalError(let lhsMsg), .numericalError(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.general(let lhsMsg), .general(let rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }
}