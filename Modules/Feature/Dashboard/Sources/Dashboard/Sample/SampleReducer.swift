import Architecture
import ComposableArchitecture
import Foundation

// MARK: - SampleReducer

@Reducer
struct SampleReducer {

  // MARK: Public

  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: state.id, id: $0) })

      case .onTapBack:
        sideEffect.routeToBack()
        return .none
      }
    }
  }

  // MARK: Internal

  let sideEffect: SampleSideEffect

}

extension SampleReducer {
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

    case onTapBack
  }

}

// MARK: SampleReducer.CancelID

extension SampleReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
  }
}
