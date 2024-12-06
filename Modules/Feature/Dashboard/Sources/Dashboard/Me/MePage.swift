import Architecture
import ComposableArchitecture
import DesignSystem
import SwiftUI

// MARK: - MePage

struct MePage {
  @Bindable var store: StoreOf<MeReducer>
}

extension MePage {
  private var tabNavigationComponentViewState: TabNavigationComponent.ViewState {
    .init(activeMatchPath: Link.Dashboard.Path.me.rawValue)
  }

  @MainActor
  private var isLoading: Bool {
    store.fetchUser.isLoading
  }
}

// MARK: View

extension MePage: View {
  var body: some View {
    VStack(spacing: .zero) {
      DesignSystemNavigation(
        barItem: .init(moreActionList: [.init(
          image: Image(systemName: "gearshape"),
          action: { store.send(.routeToUpdateAuth) })]),
        largeTitle: "Me")
      {
        VStack {
          Text("Me Page")

          Text(store.user.email ?? "1")
          Text(store.user.userName ?? "2")
        }
      }

      TabNavigationComponent(
        viewState: tabNavigationComponentViewState,
        tapAction: { store.send(.routeToTabBarItem($0)) })
    }
    .toolbar(.hidden, for: .navigationBar)
    .ignoresSafeArea(.all, edges: .bottom)
    .setRequestFlightView(isLoading: isLoading)
    .onAppear {
      store.send(.getUser)
    }
    .onDisappear {
      store.send(.teardown)
    }
  }
}
