import Architecture
import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

// MARK: - SearchPage

struct SearchPage {
  @Bindable var store: StoreOf<SearchReducer>
}

extension SearchPage {
  @MainActor
  private var isLoading: Bool {
    store.fetchSearchItem.isLoading
  }

  @MainActor
  private var itemList: [NewsEntity.Search.Item] {
    store.itemList.filter { $0.url != "https://removed.com" }
  }

  private var tabNavigationComponentViewState: TabNavigationComponent.ViewState {
    .init(activeMatchPath: Link.Dashboard.Path.search.rawValue)
  }
}

// MARK: View

extension SearchPage: View {
  var body: some View {
    VStack(spacing: .zero) {
      DesignSystemNavigation(
        barItem: .init(),
        largeTitle: "Search")
      {
        VStack {
          SearchBar(
            viewState: .init(text: $store.query),
            throttleAction: { })

          if store.itemList.isEmpty {
            VStack {
              Image(systemName: "magnifyingglass")
                .resizable()
                .fontWeight(.light)
                .frame(width: 150, height: 150)

              Text("Search for the information you want to find.")
                .font(.body)
            }
            .padding(.top, 120)
          }

          LazyVStack(spacing: 16) {
            ForEach(itemList, id: \.url) { item in
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
              .onAppear {
                guard let last = itemList.last, last.url == item.url else { return }
                guard !store.fetchSearchItem.isLoading else { return }
                store.send(.search(store.query))
              }
            }
          }
          .padding()
        }
      }

      TabNavigationComponent(
        viewState: tabNavigationComponentViewState,
        tapAction: { store.send(.routeToTabBarItem($0)) })
    }
    .setRequestFlightView(isLoading: isLoading)
    .onChange(of: store.query) { _ , new in
      store.send(.search(new))
    }
    .ignoresSafeArea(.all, edges: .bottom)
    .onAppear {
      store.send(.search(store.query))
    }
    .onDisappear {
      store.send(.teardown)
    }
  }
}
