import Architecture
import Dashboard
import Domain
import Foundation
import LinkNavigator
import Platform

// MARK: - AppSideEffect

struct AppSideEffect: DependencyType, DashboardSideEffect {
  let toastViewModel: ToastViewActionType
  let sampleUseCase: SampleUseCase
}
