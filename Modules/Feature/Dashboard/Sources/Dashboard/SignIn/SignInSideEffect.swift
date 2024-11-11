import Architecture
import ComposableArchitecture
import Domain
import LinkNavigator

// MARK: - SignInSideEffect

struct SignInSideEffect {
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

extension SignInSideEffect {
  var signIn: (AuthEntity.Email.Request) -> Effect<SignInReducer.Action> {
    { req in
      .run { send in
        do {
          try await useCaseGroup.authUseCase.signInEmail(req)
          await send(SignInReducer.Action.fetchSignIn(.success(true)))
        } catch {
          await send(SignInReducer.Action.fetchSignIn(.failure(.other(error))))
        }
      }
    }
  }

  var routeToSignUp: () -> Void {
    {
      navigator.next(
        linkItem: .init(path: Link.Dashboard.Path.signUp.rawValue, items: .none),
        isAnimated: true)
    }
  }

  var routeToHome: () -> Void {
    {
      navigator.next(
        linkItem: .init(path: Link.Dashboard.Path.me.rawValue, items: .none),
        isAnimated: true)
    }
  }
}
