import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - UpdatePasswordReducer

@Reducer
struct UpdatePasswordReducer {

  let sideEffect: UpdatePasswordSideEffect

  var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: state.id, id: $0) })

      case .onTapUpdatePassword:
        if state.currPasswordText == state.newPasswordText {
          sideEffect.useCaseGroup.toastViewModel.send(errorMessage: "현재 비밀번호와 다르게 설정해주세요")
          state.fetchUpdatePassword.isLoading = false
          return .none
        }

        state.fetchUpdatePassword.isLoading = true
        return sideEffect
          .updatePassword(state.currPasswordText, state.newPasswordText)
          .cancellable(pageID: state.id, id: CancelID.requestUpdatePassword, cancelInFlight: true)

      case .fetchUpdatePassword(let result):
        state.fetchUpdatePassword.isLoading = false
        switch result {
        case .success:
          sideEffect.useCaseGroup.toastViewModel.send(message: "비밀번호 변경이 완료되었습니다.")
          sideEffect.routeToClose()
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .routeToClose:
        sideEffect.routeToClose()
        return .none

      case .throwError(let error):
        sideEffect.useCaseGroup.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }

}

extension UpdatePasswordReducer {

  @ObservableState
  struct State: Equatable, Identifiable, Sendable {
    let id: UUID

    var currPasswordText = ""
    var newPasswordText = ""
    var confirmPasswordText = ""

    var isValidPassword = true
    var isValidConfirmPassword = true

    var isShowCurrPassword = false
    var isShowNewPassword = false
    var isShowConfirmPassword = false

    var fetchUpdatePassword: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)

    init(id: UUID = UUID()) {
      self.id = id
    }
  }

  enum Action: BindableAction, Equatable, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case onTapUpdatePassword

    case fetchUpdatePassword(Result<Bool, CompositeErrorRepository>)

    case routeToClose

    case throwError(CompositeErrorRepository)
  }
}

// MARK: UpdatePasswordReducer.CancelID

extension UpdatePasswordReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestUpdatePassword
  }
}
