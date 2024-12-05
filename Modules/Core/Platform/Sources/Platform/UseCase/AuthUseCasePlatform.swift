import Architecture
import Domain
import FirebaseAuth
import FirebaseFirestore
import Foundation
import KakaoSDKAuth
import KakaoSDKUser

// MARK: - AuthUseCasePlatform

public struct AuthUseCasePlatform {
  public init() { }
}

// MARK: AuthUseCase

extension AuthUseCasePlatform: AuthUseCase {
  public var signUpEmail: (AuthEntity.Email.Request) async throws -> Void {
    { req in
      do {
        let result = try await Auth.auth().createUser(withEmail: req.email, password: req.password)

        let userName = req.email.components(separatedBy: "@").first ?? ""

        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = userName
        try await changeRequest.commitChanges()

        try await uploadUserData(id: result.user.uid, email: req.email, userName: userName)

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

        UserApi.shared.logout { error in
          if let error {
            Logger.error("Logout failed with error: \(error.localizedDescription)")
          } else {
            Logger.debug("Logout succeeded.")
          }
        }

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
      let userRef = Firestore.firestore().collection("users")

      do {
        try await me.reauthenticate(with: credential)
        try await me.delete()
        try await userRef.document(me.uid).delete()
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

  public var updateUserName: (String) async throws -> Void {
    { newName in
      guard let me = Auth.auth().currentUser else { return }

      let userRef = Firestore.firestore().collection("users")
      do {
        let changeRequest = me.createProfileChangeRequest()
        changeRequest.displayName = newName
        try await changeRequest.commitChanges()
        try await userRef.document(me.uid).updateData(["userName": newName])
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var signInKakao: () async throws -> Bool {
    {
      do {
        if UserApi.isKakaoTalkLoginAvailable() {
          return try await handleLoginWithApp()
        } else {
          return try await handleLoginWithWeb()
        }
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }
}

extension FirebaseAuth.User {
  fileprivate func serialized() -> AuthEntity.Me.Response {
    .init(
      uid: uid,
      userName: displayName,
      email: email,
      photoURL: photoURL?.absoluteString)
  }
}

extension AuthUseCasePlatform {

  @MainActor
  private func handleLoginWithApp() async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      UserApi.shared.loginWithKakaoTalk { _, error in
        if let error {
          Logger.error("Error during login with KakaoTalk: \(error)")
          continuation.resume(throwing: error)
        } else {
          Logger.debug("loginWithKakaoTalk() success.")
          continuation.resume(returning: true)
        }
      }
    }
  }

  @MainActor
  private func handleLoginWithWeb() async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      UserApi.shared.loginWithKakaoAccount { _, error in
        if let error {
          Logger.error("Error during login with KakaoAccount: \(error)")
          continuation.resume(throwing: error)
        } else {
          Logger.debug("loginWithKakaoAccount() success.")
          continuation.resume(returning: true)
        }
      }
    }
  }

  private func uploadUserData(id: String, email: String, userName: String) async throws {
    let user = AuthEntity.Me.Response(uid: id, userName: userName, email: email, photoURL: .none)
    guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
    try await Firestore.firestore().collection("users").document(id).setData(encodedUser)
  }
}
