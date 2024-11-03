import Architecture
import Domain
import Foundation

public protocol DashboardSideEffect: Sendable {
  var toastViewModel: ToastViewActionType { get }
  var newsUseCase: NewsUseCase { get }
}
