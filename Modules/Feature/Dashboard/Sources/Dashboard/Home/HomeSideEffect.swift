import Architecture
import Combine
import CombineExt
import ComposableArchitecture
import Domain
import Foundation
import LinkNavigator

// MARK: - HomeSideEffect

struct HomeSideEffect: Sendable {
  let useCaseGroup: DashboardSideEffect
  let main: AnySchedulerOf<DispatchQueue>
  let navigator: RootNavigatorType

  init(
    useCaseGroup: DashboardSideEffect,
    main: AnySchedulerOf<DispatchQueue> = .main,
    navigator: RootNavigatorType)
  {
    self.useCaseGroup = useCaseGroup
    self.main = main
    self.navigator = navigator
  }
}

extension HomeSideEffect {
  var getItemWithCombine: (NewsEntity.TopHeadlines.Request) -> Effect<HomeReducer.Action> {
    { req in
      .publisher {
        useCaseGroup.newsUseCase
          .newsWithCombine(req)
          .receive(on: main)
          .mapToResult()
          .map(HomeReducer.Action.fetchItemWithCombine)
      }
    }
  }

  var getItemWithAsync: (NewsEntity.TopHeadlines.Request) -> Effect<HomeReducer.Action> {
    { req in
      .run { send in
        do {
          let item = try await useCaseGroup.newsUseCase.newsWithAsync(req)

          await send(HomeReducer.Action.fetchItemWithAsync(.success(item)))
        } catch {
          await send(HomeReducer.Action.fetchItemWithAsync(.failure(error.serialized())))
        }
      }
    }
  }

  var routeToNext: () -> Void {
    {
      navigator.next(
        linkItem: .init(
          path: Link.Dashboard.Path.sample.rawValue,
          items: .none),
        isAnimated: true)
    }
  }
}
