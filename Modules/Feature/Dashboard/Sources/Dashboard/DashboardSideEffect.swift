import Architecture
import Domain
import Foundation

public protocol DashboardSideEffect {
  var toastViewModel: ToastViewActionType { get }
  var sampleUseCase: SampleUseCase { get }
}
