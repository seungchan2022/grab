import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - SignUpReducer

@Reducer
struct SignUpReducer {

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

      case .onTapSignUp:
        state.fetchSignUp.isLoading = true
        return sideEffect
          .signUp(.init(email: state.emailText, password: state.passwordText))
          .cancellable(pageID: state.id, id: CancelID.requestSignUp, cancelInFlight: true)

      case .fetchSignUp(let result):
        state.fetchSignUp.isLoading = false
        switch result {
        case .success:
          sideEffect.useCaseGroup.toastViewModel.send(message: "성공")
          sideEffect.routeToBack()
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

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

  let sideEffect: SignUpSideEffect
}

extension SignUpReducer {

  @ObservableState
  struct State: Equatable, Identifiable, Sendable {
    let id: UUID

    var emailText = ""
    var passwordText = ""
    var confirmPasswordText = ""

    var isValidEmail = true
    var isValidPassword = true
    var isValidConfirmPassword = true

    var isShowPassword = false
    var isShowConfirmPassword = false

    var fetchSignUp: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)

    init(id: UUID = UUID()) {
      self.id = id
    }
  }

  enum Action: BindableAction, Equatable, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case onTapSignUp
    case fetchSignUp(Result<Bool, CompositeErrorRepository>)

    case routeToBack

    case throwError(CompositeErrorRepository)
  }
}

// MARK: SignUpReducer.CancelID

extension SignUpReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestSignUp
  }
}
