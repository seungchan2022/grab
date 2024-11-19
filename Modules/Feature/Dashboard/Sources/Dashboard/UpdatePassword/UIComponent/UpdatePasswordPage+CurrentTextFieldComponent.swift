import ComposableArchitecture
import SwiftUI

// MARK: - UpdatePasswordPage.CurrentTextFieldComponent

extension UpdatePasswordPage {
  struct CurrentTextFieldComponent {
    @Bindable var store: StoreOf<UpdatePasswordReducer>

    @FocusState var isActive
    let errorMessage: String?
  }
}

extension UpdatePasswordPage.CurrentTextFieldComponent { }

// MARK: - UpdatePasswordPage.CurrentTextFieldComponent + View

extension UpdatePasswordPage.CurrentTextFieldComponent: View {
  var body: some View {
    VStack(alignment: .leading) {
      ZStack(alignment: .leading) {
        SecureField("", text: $store.currPasswordText)
          .padding(.leading)
          .frame(maxWidth: .infinity)
          .frame(height: 55).focused($isActive)
          .background(.gray.opacity(0.1), in: .rect(cornerRadius: 16))
          .opacity(store.isShowCurrPassword ? .zero : 1)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled(true)

        TextField("", text: $store.currPasswordText)
          .padding(.leading)
          .frame(maxWidth: .infinity)
          .frame(height: 55).focused($isActive)
          .background(.gray.opacity(0.1), in: .rect(cornerRadius: 16))
          .opacity(store.isShowCurrPassword ? 1 : .zero)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled(true)

        Text("현재 비밀번호")
          .padding(.leading)
          .offset(y: (isActive || !store.currPasswordText.isEmpty) ? -50 : .zero)
          .animation(.spring, value: isActive)
          .foregroundStyle(isActive ? Color.blue : .secondary)
          .onTapGesture {
            isActive = true
          }
      }
      .overlay(alignment: .trailing) {
        Button(action: { store.isShowCurrPassword.toggle() }) {
          Image(systemName: store.isShowCurrPassword ? "eye.fill" : "eye.slash.fill")
            .padding(16)
            .foregroundStyle(store.isShowCurrPassword ? .primary : .secondary)
        }
      }

      if let errorMessage {
        Text(errorMessage)
          .font(.footnote)
          .foregroundColor(.red)
          .padding(.leading)
      }
    }
  }
}

// MARK: - UpdatePasswordPage.CurrentTextFieldComponent.ViewState

extension UpdatePasswordPage.CurrentTextFieldComponent {
  struct ViewState: Equatable { }
}
