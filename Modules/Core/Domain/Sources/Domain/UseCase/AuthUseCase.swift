import Foundation

public protocol AuthUseCase: Sendable {
  var signUpEmail: (AuthEntity.Email.Request) async throws -> Void { get }

  var signInEmail: (AuthEntity.Email.Request) async throws -> Void { get }

  var signOut: () async throws -> Void { get }

  var me: () async -> AuthEntity.Me.Response? { get }

  var resetPassword: (String) async throws -> Void { get }
}