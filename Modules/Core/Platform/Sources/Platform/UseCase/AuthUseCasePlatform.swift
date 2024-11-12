import Domain
import FirebaseAuth
import Foundation

// MARK: - AuthUseCasePlatform

public struct AuthUseCasePlatform {
  public init() { }
}

// MARK: AuthUseCase

extension AuthUseCasePlatform: AuthUseCase {

  public var signUpEmail: (AuthEntity.Email.Request) async throws -> Void {
    { req in
      do {
        try await Auth.auth().createUser(withEmail: req.email, password: req.password)
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var signInEmail: (AuthEntity.Email.Request) async throws -> Void {
    { req in
      do {
        try await Auth.auth().signIn(withEmail: req.email, password: req.password)
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var signOut: () async throws -> Void {
    {
      do {
        try Auth.auth().signOut()
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var me: () async -> AuthEntity.Me.Response? {
    {
      guard let me = Auth.auth().currentUser else { return .none }
      return me.serialized()
    }
  }

  public var resetPassword: (String) async throws -> Void {
    { email in
      do {
        Auth.auth().languageCode = "ko"

        try await Auth.auth().sendPasswordReset(withEmail: email)
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var deleteUser: (String) async throws -> Void {
    { currPassword in

      guard let me = Auth.auth().currentUser else { return }

      let credential = EmailAuthProvider.credential(withEmail: me.email ?? "", password: currPassword)

      do {
        try await me.reauthenticate(with: credential)
        try await me.delete()
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var updatePassword: (String, String) async throws -> Void {
    { currPassword, newPassword in

      guard let me = Auth.auth().currentUser else { return }

      let credential = EmailAuthProvider.credential(withEmail: me.email ?? "", password: currPassword)

      do {
        try await me.reauthenticate(with: credential)
        try await me.updatePassword(to: newPassword)

      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }
}

extension User {
  fileprivate func serialized() -> AuthEntity.Me.Response {
    .init(
      uid: uid,
      userName: displayName,
      email: email,
      photoURL: photoURL?.absoluteString)
  }
}
