import Architecture
import ComposableArchitecture
import Domain
import Foundation

@Reducer
struct SignUpReducer {

  // MARK: Lifecycle

  init(sideEffect: SignUpSideEffect) {
    self.sideEffect = sideEffect
  }

  // MARK: Internal

  @ObservableState
  struct State: Equatable, Identifiable {
    let id: UUID

    var emailText = ""
    var passwordText = ""
    var confirmPasswordText = ""

    var isValidEmail = true
    var isValidPassword = true
    var isValidConfirmPassword = true

    var isShowPassword = false
    var isShowConfirmPassword = false

    init(id: UUID = UUID()) {
      self.id = id
    }
  }

  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case teardown

    case onTapSignUp
    case fetchSignUp(Result<Bool, CompositeErrorRepository>)

    case routeToSignIn

    case throwError(CompositeErrorRepository)
  }

  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestSignUp
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

      case .onTapSignUp:
        return .none

      case .fetchSignUp(let result):
        return .none

      case .routeToSignIn:
        return .none

      case .throwError(let error):
        sideEffect.useCaseGroup.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }

  // MARK: Private

  private let sideEffect: SignUpSideEffect
}
