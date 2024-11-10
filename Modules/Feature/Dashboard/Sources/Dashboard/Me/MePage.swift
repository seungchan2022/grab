import ComposableArchitecture
import SwiftUI

// MARK: - MePage

struct MePage {
  @Bindable var store: StoreOf<MeReducer>
}

extension MePage { }

// MARK: View

extension MePage: View {
  var body: some View {
    Text("Me Page")
  }
}
