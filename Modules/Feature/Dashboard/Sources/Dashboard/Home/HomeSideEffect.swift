import Architecture
import Domain
import Foundation
import LinkNavigator

// MARK: - HomeSideEffect

struct HomeSideEffect {
  let useCaseGroup: DashboardSideEffect
  let navigator: RootNavigatorType
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
