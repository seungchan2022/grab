import Architecture
import ComposableArchitecture
import Domain
import Foundation
import LinkNavigator

// MARK: - SearchSideEffect

struct SearchSideEffect {
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

extension SearchSideEffect {

  var search: (NewsEntity.Search.Request) -> Effect<SearchReducer.Action> {
    { req in
      .run { send in
        do {
          let item = try await useCaseGroup.newsUseCase.search(req)
          await send(
            SearchReducer.Action.fetchSearchItem(
              .success(.init(request: req, response: item))))
        } catch {
          await send(SearchReducer.Action.fetchSearchItem(
            .failure(.other(error))))
        }
      }
    }
  }

  var routeToBack: () -> Void {
    {
      navigator.back(isAnimated: true)
    }
  }
}
