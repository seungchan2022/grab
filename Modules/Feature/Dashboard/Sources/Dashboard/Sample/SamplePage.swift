import ComposableArchitecture
import SwiftUI

// MARK: - SamplePage

struct SamplePage {
  @Bindable var store: StoreOf<SampleReducer>
}

extension SamplePage { }

// MARK: View

extension SamplePage: View {
  var body: some View {
    VStack {
      Spacer()
      HStack {
        Spacer()
        Text("Sample Page!")
        Button(action: { store.send(.onTapBack) }) {
          Text("Back Page")
        }
        Spacer()
      }
      Spacer()
    }
  }
}
