import Architecture
import Foundation
import LinkNavigator

struct MeRouteBuilder<RootNavigator: RootNavigatorType> {

  @MainActor
  static func generate() -> RouteBuilderOf<RootNavigator> {
    let matchPath = Link.Dashboard.Path.me.rawValue

    return .init(matchPath: matchPath) { navigator, _, diContainer -> RouteViewController? in
      guard let env: DashboardSideEffect = diContainer.resolve() else { return .none }

      return WrappingController(matchPath: matchPath) {
        MePage(
          store: .init(
            initialState: MeReducer.State(),
            reducer: {
              MeReducer(
                sideEffect: .init(
                  useCaseGroup: env,
                  navigator: navigator))
            }))
      }
    }
  }
}
