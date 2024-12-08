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

  public var deleteKakaoUser: () async throws -> Bool {
    {
      try await withCheckedThrowingContinuation { continuation in
        UserApi.shared.me { kakaoUser, error in
          if let error {
            continuation.resume(throwing: error)
            return
          }

          guard
            let email = kakaoUser?.kakaoAccount?.email,
            let password = kakaoUser?.id
          else {
            continuation.resume(throwing: CompositeErrorRepository.incorrectUser)
            return
          }

          guard let me = Auth.auth().currentUser else {
            continuation.resume(throwing: CompositeErrorRepository.incorrectUser)
            return
          }

          let credential = EmailAuthProvider.credential(withEmail: email, password: "\(password)")
          let userRef = Firestore.firestore().collection("users")

          Task {
            do {
              try await unlink()
              try await me.reauthenticate(with: credential)
              try await me.delete()
              try await userRef.document(me.uid).delete()

              continuation.resume(returning: true)
            } catch {
              continuation.resume(throwing: error)
            }
          }
        }
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
      if AuthApi.hasToken() {
        try await withCheckedThrowingContinuation { continuation in
          UserApi.shared.accessTokenInfo { _, error in
            if let error {
              Task {
                do {
                  let result = try await openKakaoService()
                  continuation.resume(returning: result)
                } catch {
                  continuation.resume(throwing: error)
                }
              }
            } else {
              // 토큰 유효성 체크 성공 (필요 시 토큰 갱신됨)
              UserApi.shared.me { kakaoUser, error in
                if let error {
                  Logger.error("기존 회원 로그인 에러 발생: \(error.localizedDescription)")
                  continuation.resume(throwing: error)
                } else {
                  Logger.debug("기존 회원 로그인 진행")
                  guard
                    let email = kakaoUser?.kakaoAccount?.email,
                    let password = kakaoUser?.id
                  else {
                    continuation.resume(throwing: CompositeErrorRepository.incorrectUser)
                    return
                  }

                  Task {
                    do {
                      try await signInEmail(.init(email: email, password: "\(password)"))
                      continuation.resume(returning: true)
                    } catch {
                      Logger.error("Firebase 로그인 실패: \(error.localizedDescription)")
                      continuation.resume(throwing: error)
                    }
                  }
                }
              }
            }
          }
        }
      } else {
        try await openKakaoService()
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
      UserApi.shared.loginWithKakaoTalk { oauthToken, error in
        if let error {
          Logger.error("Error during login with KakaoTalk: \(error)")
          continuation.resume(throwing: error)
        } else {
          Logger.debug("loginWithKakaoTalk() success.")
          if let token = oauthToken {
            Task {
              await uploadKakaoInfoToFirebase()
              continuation.resume(returning: true)
            }
          }
        }
      }
    }
  }

  @MainActor
  private func handleLoginWithWeb() async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      UserApi.shared.loginWithKakaoAccount { oauthToken, error in
        if let error {
          Logger.error("Error during login with KakaoAccount: \(error)")
          continuation.resume(throwing: error)
        } else {
          Logger.debug("loginWithKakaoAccount() success.")
          if let token = oauthToken {
            Task {
              await uploadKakaoInfoToFirebase()
              continuation.resume(returning: true)
            }
          }
        }
      }
    }
  }

  private func uploadUserData(id: String, email: String, userName: String) async throws {
    let user = AuthEntity.Me.Response(uid: id, userName: userName, email: email, photoURL: .none)
    guard let encodedUser = try? Firestore.Encoder().encode(user) else {
      throw CompositeErrorRepository.invalidTypeCasting
    }

    do {
      try await Firestore.firestore().collection("users").document(id).setData(encodedUser)
    } catch {
      throw CompositeErrorRepository.other(error)
    }
  }

  private func uploadKakaoInfoToFirebase() async {
    UserApi.shared.me { kakaoUser, error in
      if let error {
        Logger.error("DEBUG: 카카오톡 사용자 정보가져오기 에러 \(error.localizedDescription)")
      } else {
        Logger.debug("DEBUG: 카카오톡 사용자 정보가져오기 success.")
        guard
          let email = kakaoUser?.kakaoAccount?.email,
          let password = kakaoUser?.id
        else { return }

        Task {
          try await signUpEmail(.init(email: email, password: "\(password)"))
        }
      }
    }
  }

  private func openKakaoService() async throws -> Bool {
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

  private func unlink() async throws {
    UserApi.shared.unlink { error in
      guard let error else { return Logger.debug("unlink() success.") }

      return Logger.error("\(error)")
    }
  }

}
