import Architecture
import ComposableArchitecture
import Domain
import LinkNavigator

// MARK: - MeSideEffect

struct MeSideEffect {
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

extension MeSideEffect {
  var getUser: () -> Effect<MeReducer.Action> {
    {
      .run { send in
        let response = await useCaseGroup.authUseCase.me()
        await send(MeReducer.Action.fetchUser(.success(response)))
      }
    }
  }

  var routeToUpdateAuth: () -> Void {
    {
      navigator.next(
        linkItem: .init(
          path: Link.Dashboard.Path.updateAuth.rawValue,
          items: .none),
        isAnimated: true)
    }
  }

  var routeToTabBarItem: (String) -> Void {
    { path in
      guard path != Link.Dashboard.Path.me.rawValue else { return }
      navigator.replace(linkItem: .init(path: path), isAnimated: false)
    }
  }

}
