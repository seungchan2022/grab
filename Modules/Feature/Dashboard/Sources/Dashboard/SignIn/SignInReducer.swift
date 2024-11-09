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
        return .none

      case .onTapResetPassword:
        return .none

      case .fetchSignIn(let result):
        return .none

      case .fetchResetPassword(let result):
        return .none

      case .routeToSignUp:
        sideEffect.routeToSignUp()
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
