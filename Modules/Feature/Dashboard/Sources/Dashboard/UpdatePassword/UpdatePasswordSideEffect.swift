import Architecture
import ComposableArchitecture
import Foundation

// MARK: - UpdatePasswordSideEffect

struct UpdatePasswordSideEffect {
  let useCaseGroup: DashboardSideEffect
  let navigator: RootNavigatorType

}

extension UpdatePasswordSideEffect {

  var updatePassword: (String, String) -> Effect<UpdatePasswordReducer.Action> {
    { currPassword, newPassword in
      .run { send in
        do {
          try await useCaseGroup.authUseCase.updatePassword(currPassword, newPassword)
          await send(UpdatePasswordReducer.Action.fetchUpdatePassword(.success(true)))
        } catch {
          await send(UpdatePasswordReducer.Action.fetchUpdatePassword(.failure(.other(error))))
        }
      }
    }
  }

  var routeToClose: () -> Void {
    {
      navigator.close(isAnimated: true, completeAction: { })
    }
  }
}
