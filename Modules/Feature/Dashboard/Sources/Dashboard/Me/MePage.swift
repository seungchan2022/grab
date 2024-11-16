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
        }
      }

      TabNavigationComponent(
        viewState: tabNavigationComponentViewState,
        tapAction: { store.send(.routeToTabBarItem($0)) })
    }
    .toolbar(.hidden, for: .navigationBar)
    .ignoresSafeArea(.all, edges: .bottom)
    .onAppear {
      store.send(.getUser)
    }
    .onDisappear {
      store.send(.teardown)
    }
  }
}
