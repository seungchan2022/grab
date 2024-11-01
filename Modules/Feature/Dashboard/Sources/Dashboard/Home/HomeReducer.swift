import Architecture
import ComposableArchitecture
import Foundation

// MARK: - HomeReducer

@Reducer
struct HomeReducer {
  let sideEffect: HomeSideEffect

  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: state.id, id: $0) })

      case .onTapNext:
        sideEffect.routeToNext()
        return .none
      }
    }
  }
}

extension HomeReducer {
  @ObservableState
  struct State: Equatable, Identifiable, Sendable {
    let id: UUID

    init(id: UUID = UUID()) {
      self.id = id
    }
  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case onTapNext
  }
}

// MARK: HomeReducer.CancelID

extension HomeReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
  }
}
