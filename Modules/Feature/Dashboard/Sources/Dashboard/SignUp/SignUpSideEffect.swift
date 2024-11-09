import Architecture
import ComposableArchitecture
import Domain
import LinkNavigator

// MARK: - SignUpSideEffect

struct SignUpSideEffect {
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

extension SignUpSideEffect {
  var signUp: (AuthEntity.Email.Request) -> Effect<SignUpReducer.Action> {
    { req in
      .run { send in
        do {
          try await useCaseGroup.authUseCase.signUpEmail(req)
          await send(SignUpReducer.Action.fetchSignUp(.success(true)))

        } catch {
          await send(SignUpReducer.Action.fetchSignUp(.failure(.other(error))))
        }
      }
    }
  }
}
