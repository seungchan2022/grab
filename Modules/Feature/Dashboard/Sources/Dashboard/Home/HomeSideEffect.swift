import Architecture
import ComposableArchitecture
import Domain
import Foundation
import LinkNavigator

// MARK: - HomeSideEffect

struct HomeSideEffect: Sendable {
  let useCaseGroup: DashboardSideEffect
  let navigator: RootNavigatorType

  init(
    useCaseGroup: DashboardSideEffect,
    navigator: RootNavigatorType)
  {
    self.useCaseGroup = useCaseGroup
    self.navigator = navigator
  }
}

extension HomeSideEffect {
  var getItem: (NewsEntity.TopHeadlines.Request) -> Effect<HomeReducer.Action> {
    { req in
      .run { send in
        do {
          let item = try await useCaseGroup.newsUseCase.news(req)
          await send(HomeReducer.Action.fetchItem(.success(item)))
        } catch {
          await send(HomeReducer.Action.fetchItem(.failure(.other(error))))
        }
      }
    }
  }
}
