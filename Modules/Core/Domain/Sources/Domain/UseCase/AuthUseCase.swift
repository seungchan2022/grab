import Foundation

public protocol AuthUseCase: Sendable {
  var signUpEmail: (AuthEntity.Email.Request) async throws -> Void { get }

  var signInEmail: (AuthEntity.Email.Request) async throws -> Void { get }

  var signOut: () async throws -> Void { get }

  var me: () async -> AuthEntity.Me.Response? { get }

  var resetPassword: (String) async throws -> Void { get }

  var deleteUser: (String) async throws -> Void { get }

  var deleteKakaoUser: () async throws -> Bool { get }

  var updatePassword: (String, String) async throws -> Void { get }

  var updateUserName: (String) async throws -> Void { get }

  var signInKakao: () async throws -> Bool { get }

}
