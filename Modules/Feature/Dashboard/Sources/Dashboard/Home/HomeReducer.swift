import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - HomeReducer

@Reducer
struct HomeReducer {

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

      case .fetchData(let result):
        switch result {
        case .success(let item):
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapNext:
        sideEffect.routeToNext()
        return .none

      case .throwError(let error):
        sideEffect.useCaseGroup.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }

  // MARK: Internal

  let sideEffect: HomeSideEffect

}

extension HomeReducer {
  @ObservableState
  struct State: Equatable, Identifiable {
    let id: UUID

    init(id: UUID = UUID()) {
      self.id = id
    }

    var fetchData: FetchState.Data<SampleEntity?> = .init(isLoading: false, value: .none)
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case teardown

    case fetchData(Result<SampleEntity?, CompositeErrorRepository>)

    case onTapNext

    case throwError(CompositeErrorRepository)
  }
}

// MARK: HomeReducer.CancelID

extension HomeReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
  }
}
