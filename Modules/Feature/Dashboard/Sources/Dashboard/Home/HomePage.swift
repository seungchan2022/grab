import Architecture
import ComposableArchitecture
import DesignSystem
import Foundation
import SwiftUI

// MARK: - HomePage

struct HomePage {

  @Bindable var store: StoreOf<HomeReducer>
}

extension HomePage {
  private var tabNavigationComponentViewState: TabNavigationComponent.ViewState {
    .init(activeMatchPath: Link.Dashboard.Path.home.rawValue)
  }
}

// MARK: View

extension HomePage: View {
  var body: some View {
    VStack(spacing: .zero) {
      DesignSystemNavigation(
        barItem: .init(),
        largeTitle: "Home")
      {
        VStack {
          LazyVStack(spacing: 16) {
            ForEach(store.itemList, id: \.url) { item in
              VStack(alignment: .leading, spacing: 8) {
                Text(item.title ?? "")
                  .font(.headline)
                  .foregroundColor(.primary)

                Text(item.description ?? "")
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                  .lineLimit(2)

                Text(item.url)
                  .font(.caption)
                  .foregroundColor(.blue)
              }
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding()
              .background(
                RoundedRectangle(cornerRadius: 12)
                  .fill(Color(.systemGray6)))
            }
          }
          .padding()
        }
      }

      TabNavigationComponent(
        viewState: tabNavigationComponentViewState,
        tapAction: { store.send(.routeToTabBarItem($0)) })
    }
    .toolbarVisibility(.hidden, for: .navigationBar)
    .ignoresSafeArea(.all, edges: .bottom)
    .onAppear {
      store.send(.getItem)
    }
    .onDisappear {
      store.send(.teardown)
    }
  }
}
