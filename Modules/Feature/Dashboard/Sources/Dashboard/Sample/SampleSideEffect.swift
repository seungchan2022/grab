import Architecture
import ComposableArchitecture
import Domain
import Foundation
import LinkNavigator

// MARK: - SampleSideEffect

struct SampleSideEffect {
  let useCaseGroup: DashboardSideEffect
  let main: AnySchedulerOf<DispatchQueue>
  let navigator: RootNavigatorType

  init(
    useCaseGroup: DashboardSideEffect,
    main: AnySchedulerOf<DispatchQueue> = .main,
    navigator: RootNavigatorType)
  {
    self.useCaseGroup = useCaseGroup
    self.main = main
    self.navigator = navigator
  }
}

extension SampleSideEffect {
  var routeToBack: () -> Void {
    {
      navigator.back(isAnimated: true)
    }
  }
}
