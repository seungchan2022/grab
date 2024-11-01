import Foundation
import LinkNavigator

final class AppContainer {

  // MARK: Lifecycle

  init(dependency: AppSideEffect = AppSideEffect.generate()) {
    linkNavigator = .init(
      routeBuilderItemList: [],
      dependency: dependency)
  }

  // MARK: Internal

  let linkNavigator: SingleLinkNavigator

}
