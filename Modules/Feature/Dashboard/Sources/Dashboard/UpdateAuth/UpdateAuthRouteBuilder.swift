import Architecture
import Foundation
import LinkNavigator

struct UpdataAuthRouteBuilder<RootNavigator: RootNavigatorType> {

  @MainActor
  static func generate() -> RouteBuilderOf<RootNavigator> {
    let matchPath = Link.Dashboard.Path.updateAuth.rawValue

    return .init(matchPath: matchPath) { navigator, _, diContainer -> RouteViewController? in
      guard let env: DashboardSideEffect = diContainer.resolve() else { return .none }

      return WrappingController(matchPath: matchPath) {
        UpdateAuthPage(
          store: .init(
            initialState: UpdateAuthReducer.State(),
            reducer: {
              UpdateAuthReducer(
                sideEffect: .init(
                  useCaseGroup: env,
                  navigator: navigator))
            }))
      }
    }
  }
}
