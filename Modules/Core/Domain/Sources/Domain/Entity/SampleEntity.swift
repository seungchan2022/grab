import Foundation

public struct SampleEntity: Codable, Sendable, Equatable {
  public let name: String

  public init(name: String) {
    self.name = name
  }
}
