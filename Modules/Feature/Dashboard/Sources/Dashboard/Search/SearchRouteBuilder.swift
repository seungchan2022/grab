import Architecture
import Foundation
import LinkNavigator

struct SearchRouteBuilder<RootNavigator: RootNavigatorType> {

  @MainActor
  static func generate() -> RouteBuilderOf<RootNavigator> {
    let matchPath = Link.Dashboard.Path.search.rawValue

    return .init(matchPath: matchPath) { navigator, _, diContainer -> RouteViewController? in
      guard let env: DashboardSideEffect = diContainer.resolve() else { return .none }

      return WrappingController(matchPath: matchPath) {
        SearchPage(
          store: .init(
            initialState: SearchReducer.State(),
            reducer: {
              SearchReducer(
                sideEffect: .init(
                  useCaseGroup: env,
                  navigator: navigator))
            }))
      }
    }
  }
}
