import Combine
import Domain
import Foundation

// MARK: - NewsUseCasePlatform

public struct NewsUseCasePlatform {
  let baseURL: String

  public init(baseURL: String = "https://newsapi.org/v2/top-headlines") {
    self.baseURL = baseURL
  }
}

// MARK: NewsUseCase

extension NewsUseCasePlatform: NewsUseCase {
  public var news: (NewsEntity.TopHeadlines.Request) async throws -> NewsEntity.TopHeadlines.Response {
    { req in
      guard var urlComponents = URLComponents(string: baseURL) else {
        throw CompositeErrorRepository.invalidTypeCasting
      }

      // 쿼리 파라미터 추가
      urlComponents.queryItems = [
        URLQueryItem(name: "country", value: req.country),
        URLQueryItem(name: "apiKey", value: req.apiKey),
      ]

      // URL 생성 실패 시 에러 반환
      guard let url = urlComponents.url else {
        throw CompositeErrorRepository.networkUnknown
      }

      // URLSession 비동기 데이터 요청
      let (data, response) = try await URLSession.shared.data(from: url)

      // 응답 코드 확인
      guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
        throw CompositeErrorRepository.networkUnknown
      }

      // 데이터 디코딩
      let decodedResponse = try JSONDecoder().decode(NewsEntity.TopHeadlines.Response.self, from: data)
      return decodedResponse
    }
  }
}
