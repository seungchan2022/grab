import Architecture
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
  var routeToSignUp: () -> Void {
    {
      navigator.next(
        linkItem: .init(path: Link.Dashboard.Path.signUp.rawValue, items: .none),
        isAnimated: true)
    }
  }
}
