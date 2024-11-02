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
    VStack {
      Spacer()
      HStack {
        Spacer()
        Text("Home Page!")

        Button(action: { store.send(.onTapNext) }) {
          Text("Next Page")
        }

        Spacer()
      }
      Spacer()
    }
  }
}
