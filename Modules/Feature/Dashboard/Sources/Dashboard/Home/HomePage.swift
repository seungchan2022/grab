import ComposableArchitecture
import Foundation
import SwiftUI

// MARK: - HomePage

struct HomePage {

  @Bindable var store: StoreOf<HomeReducer>
}

extension HomePage { }

// MARK: View

extension HomePage: View {
  var body: some View {
    ScrollView {
      VStack {
        Button(action: { store.send(.onTapSignOut) }) {
          Text("로그아웃")
        }

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
    .onAppear {
      store.send(.getItem)
    }
  }
}
