import Foundation

public protocol NewsUseCase: Sendable {

  var news: (NewsEntity.TopHeadlines.Request) async throws -> NewsEntity.TopHeadlines.Response { get }

  var search: (NewsEntity.Search.Request) async throws -> NewsEntity.Search.Response { get }
}
