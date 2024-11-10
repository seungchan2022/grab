import Architecture
import ComposableArchitecture
import Domain
import Foundation

@Reducer
struct SignInReducer {

  // MARK: Lifecycle

  init(sideEffect: SignInSideEffect) {
    self.sideEffect = sideEffect
  }

  // MARK: Internal

  @ObservableState
  struct State: Equatable, Identifiable {
    let id: UUID

    var emailText = ""
    var passwordText = ""

    var resetEmailText = ""

    var isShowPassword = false

    var isShowResetPassword = false

    var fetchSignIn: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)

    init(id: UUID = UUID()) {
      self.id = id
    }
  }

  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case teardown

    case onTapSignIn
    case onTapResetPassword

    case fetchSignIn(Result<Bool, CompositeErrorRepository>)
    case fetchResetPassword(Result<Bool, CompositeErrorRepository>)

    case routeToSignUp
    case routeToHome

    case throwError(CompositeErrorRepository)
  }

  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestSignIn
    case requestResetPassword
    case requestGoogleSignIn
  }

  var body: some Reducer<State, Action> {
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
        return .none

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
        return .none

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

  // MARK: Private

  private let sideEffect: SignInSideEffect
}
