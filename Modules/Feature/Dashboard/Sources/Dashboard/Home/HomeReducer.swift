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

      case .getItemWithCombine:
        state.fetchItemWithCombine.isLoading = true
        return sideEffect
          .getItemWithCombine(.init())
          .cancellable(pageID: state.id, id: CancelID.requestItemWithCombine, cancelInFlight: true)

      case .fetchItemWithCombine(let result):
        state.fetchItemWithCombine.isLoading = false
        switch result {
        case .success(let item):
          state.fetchItemWithCombine.value = item
          state.itemList = state.itemList + item.itemList
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .getItemWithAsync:
        state.fetchItemWithAsync.isLoading = true
        return sideEffect
          .getItemWithAsync(.init())
          .cancellable(pageID: state.id, id: CancelID.requestItemWithCombine, cancelInFlight: true)

      case .fetchItemWithAsync(let result):
        state.fetchItemWithAsync.isLoading = false
        switch result {
        case .success(let item):
          state.fetchItemWithAsync.value = item
          state.itemList = state.itemList + item.itemList
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
  struct State: Equatable, Identifiable, Sendable {
    let id: UUID

    init(id: UUID = UUID()) {
      self.id = id
    }

    var itemList: [NewsEntity.TopHeadlines.Item] = []

    var fetchItemWithCombine: FetchState.Data<NewsEntity.TopHeadlines.Response?> = .init(isLoading: false, value: .none)

    var fetchItemWithAsync: FetchState.Data<NewsEntity.TopHeadlines.Response?> = .init(isLoading: false, value: .none)
  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case getItemWithCombine
    case fetchItemWithCombine(Result<NewsEntity.TopHeadlines.Response, CompositeErrorRepository>)

    case getItemWithAsync
    case fetchItemWithAsync(Result<NewsEntity.TopHeadlines.Response, CompositeErrorRepository>)

    case onTapNext

    case throwError(CompositeErrorRepository)
  }
}

// MARK: HomeReducer.CancelID

extension HomeReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestItemWithCombine
    case requestItemWithAsync
  }
}
