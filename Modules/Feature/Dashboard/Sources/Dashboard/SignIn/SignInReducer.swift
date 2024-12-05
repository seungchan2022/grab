import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - SignInReducer

@Reducer
struct SignInReducer {

  // MARK: Public

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: state.id, id: $0) })

      case .onTapSignIn:
        state.fetchSignIn.isLoading = true
        return sideEffect
          .signIn(.init(email: state.emailText, password: state.passwordText))
          .cancellable(pageID: state.id, id: CancelID.requestSignIn, cancelInFlight: true)

      case .onTapResetPassword:
        state.fetchResetPassword.isLoading = true
        return sideEffect
          .resetPassword(state.resetEmailText)
          .cancellable(pageID: state.id, id: CancelID.requestResetPassword, cancelInFlight: true)

      case .onTapKakaoSignIn:
        state.fetchKakaoSignIn.isLoading = true
        return sideEffect
          .signInKakao()
          .cancellable(pageID: state.id, id: CancelID.requestKakaoSignIn, cancelInFlight: true)

      case .fetchSignIn(let result):
        state.fetchSignIn.isLoading = false
        switch result {
        case .success:
          sideEffect.routeToHome()
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .fetchResetPassword(let result):
        state.fetchResetPassword.isLoading = false
        switch result {
        case .success:
          sideEffect.useCaseGroup.toastViewModel.send(message: "재설정 링크가 발송되었습니다.")
          state.isShowResetPassword = false
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .fetchKakaoSignIn(let result):
        state.fetchKakaoSignIn.isLoading = false
        switch result {
        case .success(let success):
          switch success {
          case true:
            sideEffect.routeToHome()
            sideEffect.useCaseGroup.toastViewModel.send(message: "로그인 성공")

          case false:
            sideEffect.useCaseGroup.toastViewModel.send(errorMessage: "로그인 실패")
          }
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .routeToSignUp:
        sideEffect.routeToSignUp()
        return .none

      case .routeToHome:
        sideEffect.routeToHome()
        return .none

      case .throwError(let error):
        sideEffect.useCaseGroup.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }

  // MARK: Internal

  let sideEffect: SignInSideEffect
}

extension SignInReducer {

  @ObservableState
  struct State: Equatable, Identifiable, Sendable {
    let id: UUID

    var emailText = ""
    var passwordText = ""

    var resetEmailText = ""

    var isShowPassword = false

    var isShowResetPassword = false

    var fetchSignIn: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
    var fetchResetPassword: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
    var fetchKakaoSignIn: FetchState.Data<Bool?> = .init(isLoading: false, value: . none)

    init(id: UUID = UUID()) {
      self.id = id
    }
  }

  enum Action: BindableAction, Equatable, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case onTapSignIn
    case onTapResetPassword
    case onTapKakaoSignIn

    case fetchSignIn(Result<Bool, CompositeErrorRepository>)
    case fetchResetPassword(Result<Bool, CompositeErrorRepository>)
    case fetchKakaoSignIn(Result<Bool, CompositeErrorRepository>)

    case routeToSignUp
    case routeToHome

    case throwError(CompositeErrorRepository)
  }
}

// MARK: SignInReducer.CancelID

extension SignInReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestSignIn
    case requestResetPassword
    case requestGoogleSignIn
    case requestKakaoSignIn
  }
}
