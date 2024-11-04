import Foundation

public protocol NewsUseCase: Sendable {

  var news: (NewsEntity.TopHeadlines.Request) async throws -> NewsEntity.TopHeadlines.Response { get }

}
