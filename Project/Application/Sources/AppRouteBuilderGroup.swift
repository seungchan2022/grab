import Architecture
import Dashboard
import LinkNavigator

struct AppRouteBuilderGroup<RootNavigator: RootNavigatorType> {
  @MainActor
  public func applicationBuilders() -> [RouteBuilderOf<RootNavigator>] {
    DashboardRouteBuilderGroup().release()
  }
}
