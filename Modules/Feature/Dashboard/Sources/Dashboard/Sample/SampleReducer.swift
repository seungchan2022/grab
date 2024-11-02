import Architecture
import ComposableArchitecture
import Domain
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

      case .throwError(let error):
        sideEffect.useCaseGroup.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }

  // MARK: Internal

  let sideEffect: SampleSideEffect

}

extension SampleReducer {
  @ObservableState
  struct State: Equatable, Identifiable {
    let id: UUID

    init(id: UUID = UUID()) {
      self.id = id
    }
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case teardown

    case onTapBack

    case throwError(CompositeErrorRepository)
  }

}

// MARK: SampleReducer.CancelID

extension SampleReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
  }
}
