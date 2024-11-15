import Architecture
import ComposableArchitecture
import Domain
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

  var signOut: () -> Effect<HomeReducer.Action> {
    {
      .run { send in
        do {
          try await useCaseGroup.authUseCase.signOut()
          await send(HomeReducer.Action.fetchSignOut(.success(true)))
        } catch {
          await send(HomeReducer.Action.fetchSignOut(.failure(.other(error))))
        }
      }
    }
  }

  var routeToSignIn: () -> Void {
    {
      navigator.replace(
        linkItem: .init(path: Link.Dashboard.Path.signIn.rawValue, items: .none),
        isAnimated: false)
    }
  }

  var routeToTabBarItem: (String) -> Void {
    { path in
      guard path != Link.Dashboard.Path.home.rawValue else { return }
      navigator.replace(linkItem: .init(path: path), isAnimated: false)
    }
  }
}
