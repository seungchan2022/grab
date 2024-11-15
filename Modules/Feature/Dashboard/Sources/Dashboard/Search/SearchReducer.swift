import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - SearchReducer

@Reducer
struct SearchReducer {

  // MARK: Public

  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(\.query):
        guard !state.query.isEmpty else {
          state.itemList = []
          return .cancel(pageID: state.id, id: CancelID.requestSearchItem)
        }

        if state.query != state.fetchSearchItem.value?.request.query {
          state.itemList = []
        }
        return .none

      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: state.id, id: $0) })

      case .search(let query):
        guard !query.isEmpty else { return .none }

        state.fetchSearchItem.isLoading = true
        let page = Int(state.itemList.count / state.perPage) + 1
        return sideEffect
          .search(.init(query: query, page: page, perPage: state.perPage))
          .cancellable(pageID: state.id, id: CancelID.requestSearchItem, cancelInFlight: true)

      case .fetchSearchItem(let result):
        state.fetchSearchItem.isLoading = false
        switch result {
        case .success(let item):
          if state.query == item.request.query {
            state.fetchSearchItem.value = item
            state.itemList = state.itemList.merge(item.response.itemList)
          }
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapBack:
        sideEffect.routeToBack()
        return .none

      case .routeToTabBarItem(let matchPath):
        sideEffect.routeToTabBarItem(matchPath)
        return .none

      case .throwError(let error):
        sideEffect.useCaseGroup.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }

  // MARK: Internal

  let sideEffect: SearchSideEffect

}

extension SearchReducer {
  @ObservableState
  struct State: Equatable, Identifiable, Sendable {
    let id: UUID

    var query = ""
    var perPage = 20

    var itemList: [NewsEntity.Search.Item] = []

    var fetchSearchItem: FetchState.Data<NewsEntity.Search.Composite?> = .init(isLoading: false, value: .none)

    init(id: UUID = UUID()) {
      self.id = id
    }
  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case search(String)
    case fetchSearchItem(Result<NewsEntity.Search.Composite, CompositeErrorRepository>)

    case onTapBack

    case routeToTabBarItem(String)

    case throwError(CompositeErrorRepository)
  }

}

// MARK: SearchReducer.CancelID

extension SearchReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestSearchItem
  }
}

extension [NewsEntity.Search.Item] {
  fileprivate func merge(_ target: Self) -> Self {
    let new = target.reduce(self) { curr, next in
      guard !self.contains(where: { $0.url == next.url }) else { return curr }
      return curr + [next]
    }

    return new
  }
}
