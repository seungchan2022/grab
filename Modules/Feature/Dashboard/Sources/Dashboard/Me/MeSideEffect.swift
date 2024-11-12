import Architecture
import ComposableArchitecture
import Domain
import LinkNavigator

// MARK: - MeSideEffect

struct MeSideEffect {
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

extension MeSideEffect {
  var getUser: () -> Effect<MeReducer.Action> {
    {
      .run { send in
        let response = await useCaseGroup.authUseCase.me()
        await send(MeReducer.Action.fetchUser(.success(response)))
      }
    }
  }

  var signOut: () -> Effect<MeReducer.Action> {
    {
      .run { send in
        do {
          try await useCaseGroup.authUseCase.signOut()
          await send(MeReducer.Action.fetchSignOut(.success(true)))
        } catch {
          await send(MeReducer.Action.fetchSignOut(.failure(.other(error))))
        }
      }
    }
  }

  var deleteUser: (String) -> Effect<MeReducer.Action> {
    { currPassword in
      .run { send in
        do {
          try await useCaseGroup.authUseCase.deleteUser(currPassword)
          await send(MeReducer.Action.fetchDeleteUser(.success(true)))
        } catch {
          await send(MeReducer.Action.fetchDeleteUser(.failure(.other(error))))
        }
      }
    }
  }

  var updateUserName: (String) -> Effect<MeReducer.Action> {
    { newName in
      .run { send in
        do {
          try await useCaseGroup.authUseCase.updateUserName(newName)
          await send(MeReducer.Action.fetchUpdateUserName(.success(true)))
        } catch {
          await send(MeReducer.Action.fetchUpdateUserName(.failure(.other(error))))
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

  var routeToUpdatePassword: () -> Void {
    {
      navigator.fullSheet(
        linkItem: .init(path: Link.Dashboard.Path.updatePassword.rawValue, items: .none),
        isAnimated: true,
        prefersLargeTitles: .none)
    }
  }
}
