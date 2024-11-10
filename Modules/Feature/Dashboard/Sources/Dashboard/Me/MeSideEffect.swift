import Architecture
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

extension MeSideEffect { }
