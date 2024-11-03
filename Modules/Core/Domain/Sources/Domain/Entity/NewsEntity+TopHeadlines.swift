import Foundation

// MARK: - NewsEntity.TopHeadlines

extension NewsEntity {
  public enum TopHeadlines { }
}

extension NewsEntity.TopHeadlines {
  public struct Request: Equatable, Sendable, Codable {

    public let country: String
    public let apiKey: String

    public init(
      country: String = "us",
      apiKey: String = "5a2ec50f09d14922ad3ca1bdb0a43425")
    {
      self.country = country
      self.apiKey = apiKey
    }

    private enum CodingKeys: String, CodingKey {
      case country
      case apiKey
    }
  }

  public struct Response: Equatable, Sendable, Codable {
    public let status: String
    public let totalResultCount: Int?
    public let itemList: [Item]

    private enum CodingKeys: String, CodingKey {
      case status
      case totalResultCount = "totalResults"
      case itemList = "articles"
    }
  }

  public struct Item: Equatable, Sendable, Codable {
    public let title: String?
    public let description: String?
    public let url: String

    private enum CodingKeys: String, CodingKey {
      case title
      case description
      case url
    }
  }
}
