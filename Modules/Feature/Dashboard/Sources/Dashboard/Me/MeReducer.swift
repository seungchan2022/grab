import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - MeReducer

@Reducer
struct MeReducer {

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

      case .getUser:
        state.fetchUser.isLoading = false
        return sideEffect
          .getUser()
          .cancellable(pageID: state.id, id: CancelID.requestUser, cancelInFlight: true)

      case .fetchUser(let result):
        switch result {
        case .success(let user):
          state.user = user ?? .init(uid: "", userName: "", email: "", photoURL: "")
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .routeToUpdateAuth:
        sideEffect.routeToUpdateAuth()
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

  let sideEffect: MeSideEffect
}

extension MeReducer {

  @ObservableState
  struct State: Equatable, Identifiable, Sendable {

    // MARK: Lifecycle

    init(id: UUID = UUID()) {
      self.id = id
    }

    // MARK: Internal

    let id: UUID

    var isShowUpdateUserNameAlert = false
    var isShowSignOutAlert = false
    var isShowDeleteUserAlert = false

    var updateUserName = ""

    var passwordText = ""

    var user: AuthEntity.Me.Response = .init(uid: "", userName: "", email: "", photoURL: "")

    var fetchUser: FetchState.Data<AuthEntity.Me.Response?> = .init(isLoading: false, value: .none)
    var fetchSignOut: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
    var fetchUpdateUserName: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
    var fetchDeleteUser: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
    var fetchDeleteUserInfo: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
    var fetchDeleteUserProfileImage: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)

  }

  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case teardown

    case getUser

    case fetchUser(Result<AuthEntity.Me.Response?, CompositeErrorRepository>)

    case routeToUpdateAuth

    case routeToTabBarItem(String)

    case throwError(CompositeErrorRepository)
  }
}

// MARK: MeReducer.CancelID

extension MeReducer {

  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestUser
  }
}
