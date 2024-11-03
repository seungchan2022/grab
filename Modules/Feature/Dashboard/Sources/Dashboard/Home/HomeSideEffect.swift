import Architecture
import ComposableArchitecture
import Domain
import Foundation
import LinkNavigator

// MARK: - HomeSideEffect

struct HomeSideEffect {
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

extension HomeSideEffect {
  var fire: () async throws -> SampleEntity {
    useCaseGroup.sampleUseCase.fire
  }

  var routeToNext: () -> Void {
    {
      navigator.next(
        linkItem: .init(
          path: Link.Dashboard.Path.sample.rawValue,
          items: .none),
        isAnimated: true)
    }
  }
}
