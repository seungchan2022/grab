import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - UpdateAuthReducer

@Reducer
struct UpdateAuthReducer {

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

      case .onTapSignOut:
        state.fetchSignOut.isLoading = true
        return sideEffect
          .signOut()
          .cancellable(pageID: state.id, id: CancelID.requestSignOut, cancelInFlight: true)

      case .onTapUpdateUserName:
        state.fetchUpdateUserName.isLoading = true
        return sideEffect
          .updateUserName(state.updateUserName)
          .cancellable(pageID: state.id, id: CancelID.requestUpdateUserName, cancelInFlight: true)

      case .onTapDeleteUser:
        state.fetchDeleteUser.isLoading = true
        return sideEffect
          .deleteUser(state.passwordText)
          .cancellable(pageID: state.id, id: CancelID.requestDeleteUser, cancelInFlight: true)

      case .onTapDeleteKakaoUser:
        state.fetchDeleteKakaUser.isLoading = true
        return sideEffect
          .deleteKakaoUesr()
          .cancellable(pageID: state.id, id: CancelID.requestDeleteKakaoUser, cancelInFlight: true)

      case .fetchDeleteKakaoUser(let result):
        state.fetchDeleteKakaUser.isLoading = false
        switch result {
        case .success(let success):
          switch success {
          case true:
            sideEffect.useCaseGroup.toastViewModel.send(message: "카카오 유저 삭제 성공")
            sideEffect.routeToSignIn()

          case false:
            sideEffect.useCaseGroup.toastViewModel.send(errorMessage: "카카오 유저 삭제 실패")
          }

          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .deleteUserInfo:
        return .none

      case .deleteUserProfileImage:
        return .none

      case .fetchUser(let result):
        switch result {
        case .success(let user):
          state.user = user ?? .init(uid: "", userName: "", email: "", photoURL: "")
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .fetchSignOut(let result):
        switch result {
        case .success:
          sideEffect.useCaseGroup.toastViewModel.send(message: "로그아웃 되었습니다!")
          sideEffect.routeToSignIn()
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .fetchUpdateUserName(let result):
        state.fetchUpdateUserName.isLoading = false
        switch result {
        case .success:
          sideEffect.useCaseGroup.toastViewModel.send(message: "유저 이름 변경")
          return .run { await $0(.getUser) }

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .fetchDeleteUser(let result):
        state.fetchDeleteUser.isLoading = false
        switch result {
        case .success:
          sideEffect.useCaseGroup.toastViewModel.send(message: "계정이 탈퇴되었습니다!")
          sideEffect.routeToSignIn()
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .fetchDeleteUserInfo(let result):
        return .none

      case .fetchDeleteUserProfileImage(let result):
        return .none

      case .routeToUpdatePassword:
        sideEffect.routeToUpdatePassword()
        return .none

      case .routeToSignIn:
        sideEffect.routeToSignIn()
        return .none

      case .routeToBack:
        sideEffect.routeToBack()
        return .none

      case .throwError(let error):
        sideEffect.useCaseGroup.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }

  // MARK: Internal

  let sideEffect: UpdateAuthSideEffect
}

extension UpdateAuthReducer {

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
    var isShowDeleteKakaoUserAlert = false

    var updateUserName = ""

    var passwordText = ""

    var user: AuthEntity.Me.Response = .init(uid: "", userName: "", email: "", photoURL: "")

    var fetchUser: FetchState.Data<AuthEntity.Me.Response?> = .init(isLoading: false, value: .none)
    var fetchSignOut: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
    var fetchUpdateUserName: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
    var fetchDeleteUser: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
    var fetchDeleteUserInfo: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
    var fetchDeleteUserProfileImage: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)

    var fetchDeleteKakaUser: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)

  }

  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case teardown

    case getUser

    case onTapSignOut
    case onTapUpdateUserName
    case onTapDeleteUser
    case onTapDeleteKakaoUser

    case deleteUserInfo
    case deleteUserProfileImage

    case fetchUser(Result<AuthEntity.Me.Response?, CompositeErrorRepository>)
    case fetchSignOut(Result<Bool, CompositeErrorRepository>)
    case fetchUpdateUserName(Result<Bool, CompositeErrorRepository>)
    case fetchDeleteUser(Result<Bool, CompositeErrorRepository>)
    case fetchDeleteUserInfo(Result<Bool, CompositeErrorRepository>)
    case fetchDeleteUserProfileImage(Result<Bool, CompositeErrorRepository>)

    case fetchDeleteKakaoUser(Result<Bool, CompositeErrorRepository>)

    case routeToUpdatePassword
    case routeToSignIn
    case routeToBack

    case throwError(CompositeErrorRepository)
  }
}

// MARK: UpdateAuthReducer.CancelID

extension UpdateAuthReducer {

  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestUser
    case requestSignOut
    case requestUpdateUserName
    case requestDeleteUser
    case requestDeleteUserInfo
    case requestDeleteUserProfileImage
    case requestDeleteKakaoUser
  }
}
