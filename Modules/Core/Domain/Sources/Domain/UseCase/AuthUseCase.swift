import Foundation

public protocol AuthUseCase: Sendable {
  var signUpEmail: (AuthEntity.Email.Request) async throws -> Void { get }

  var signInEmail: (AuthEntity.Email.Request) async throws -> Void { get }

  var signOut: () async throws -> Void { get }
}
