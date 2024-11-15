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

      case .onTapSignOut:
        state.fetchSignOut.isLoading = true
        return sideEffect
          .signOut()
          .cancellable(pageID: state.id, id: CancelID.requestSignOut, cancelInFlight: true)

      case .fetchSignOut(let result):
        switch result {
        case .success:
          sideEffect.useCaseGroup.toastViewModel.send(message: "로그아웃 되었습니다!")
          sideEffect.routeToSignIn()
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .getItem:
        state.fetchItem.isLoading = true
        return sideEffect
          .getItem(.init())
          .cancellable(pageID: state.id, id: CancelID.requestItem, cancelInFlight: true)

      case .fetchItem(let result):
        state.fetchItem.isLoading = false
        switch result {
        case .success(let item):
          state.fetchItem.value = item
          state.itemList = state.itemList.merge(item.itemList)
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

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

    var fetchItem: FetchState.Data<NewsEntity.TopHeadlines.Response?> = .init(isLoading: false, value: .none)

    var fetchSignOut: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case onTapSignOut
    case fetchSignOut(Result<Bool, CompositeErrorRepository>)

    case getItem
    case fetchItem(Result<NewsEntity.TopHeadlines.Response, CompositeErrorRepository>)

    case routeToTabBarItem(String)

    case throwError(CompositeErrorRepository)
  }
}

// MARK: HomeReducer.CancelID

extension HomeReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestItem
    case requestSignOut
  }
}

extension [NewsEntity.TopHeadlines.Item] {
  fileprivate func merge(_ target: Self) -> Self {
    let new = target.reduce(self) { curr, next in
      guard !self.contains(where: { $0.url == next.url }) else { return curr }
      return curr + [next]
    }

    return new
  }
}
