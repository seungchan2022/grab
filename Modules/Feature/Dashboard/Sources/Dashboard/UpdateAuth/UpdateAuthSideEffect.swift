import Architecture
import ComposableArchitecture
import Domain
import LinkNavigator

// MARK: - UpdateAuthSideEffect

struct UpdateAuthSideEffect {
  let useCaseGroup: DashboardSideEffect
  let navigator: RootNavigatorType

  init(
    useCaseGroup: DashboardSideEffect,
    navigator: RootNavigatorType)
  {
    self.useCaseGroup = useCaseGroup
    self.navigator = navigator
  }
}

extension UpdateAuthSideEffect {
  var getUser: () -> Effect<UpdateAuthReducer.Action> {
    {
      .run { send in
        let response = await useCaseGroup.authUseCase.me()
        await send(UpdateAuthReducer.Action.fetchUser(.success(response)))
      }
    }
  }

  var signOut: () -> Effect<UpdateAuthReducer.Action> {
    {
      .run { send in
        do {
          try await useCaseGroup.authUseCase.signOut()
          await send(UpdateAuthReducer.Action.fetchSignOut(.success(true)))
        } catch {
          await send(UpdateAuthReducer.Action.fetchSignOut(.failure(.other(error))))
        }
      }
    }
  }

  var deleteUser: (String) -> Effect<UpdateAuthReducer.Action> {
    { currPassword in
      .run { send in
        do {
          try await useCaseGroup.authUseCase.deleteUser(currPassword)
          await send(UpdateAuthReducer.Action.fetchDeleteUser(.success(true)))
        } catch {
          await send(UpdateAuthReducer.Action.fetchDeleteUser(.failure(.other(error))))
        }
      }
    }
  }

  var updateUserName: (String) -> Effect<UpdateAuthReducer.Action> {
    { newName in
      .run { send in
        do {
          try await useCaseGroup.authUseCase.updateUserName(newName)
          await send(UpdateAuthReducer.Action.fetchUpdateUserName(.success(true)))
        } catch {
          await send(UpdateAuthReducer.Action.fetchUpdateUserName(.failure(.other(error))))
        }
      }
    }
  }

  var routeToSignIn: () -> Void {
    {
      navigator.replace(
        linkItem: .init(path: Link.Dashboard.Path.signIn.rawValue, items: .none),
        isAnimated: false)
    }
  }

  var routeToBack: () -> Void {
    {
      navigator.back(isAnimated: true)
    }
  }

  var routeToUpdatePassword: () -> Void {
    {
      navigator.fullSheet(
        linkItem: .init(path: Link.Dashboard.Path.updatePassword.rawValue, items: .none),
        isAnimated: true,
        prefersLargeTitles: .none)
    }
  }
}
