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

  var signOut: () -> Effect<MeReducer.Action> {
    {
      .run { send in
        do {
          try await useCaseGroup.authUseCase.signOut()
          await send(MeReducer.Action.fetchSignOut(.success(true)))
        } catch {
          await send(MeReducer.Action.fetchSignOut(.failure(.other(error))))
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
}
