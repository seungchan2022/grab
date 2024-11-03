import Combine

public protocol NewsUseCase: Sendable {
  var newsWithCombine: (NewsEntity.TopHeadlines.Request) -> AnyPublisher<
    NewsEntity.TopHeadlines.Response,
    CompositeErrorRepository
  > { get }

  var newsWithAsync: (NewsEntity.TopHeadlines.Request) async throws -> NewsEntity.TopHeadlines.Response { get }

}
