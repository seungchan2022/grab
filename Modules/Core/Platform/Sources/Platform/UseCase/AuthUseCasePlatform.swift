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
        _ = try await Auth.auth().createUser(withEmail: req.email, password: req.password)
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }
}
