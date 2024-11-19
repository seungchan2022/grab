import ComposableArchitecture
import SwiftUI

// MARK: - UpdatePasswordPage.PasswordTextFieldComponent

extension UpdatePasswordPage {
  struct PasswordTextFieldComponent {
    @Bindable var store: StoreOf<UpdatePasswordReducer>

    @FocusState var isActive
    let errorMessage: String?
  }
}

extension UpdatePasswordPage.PasswordTextFieldComponent { }

// MARK: - UpdatePasswordPage.PasswordTextFieldComponent + View

extension UpdatePasswordPage.PasswordTextFieldComponent: View {
  var body: some View {
    VStack(alignment: .leading) {
      ZStack(alignment: .leading) {
        SecureField("", text: $store.newPasswordText)
          .padding(.leading)
          .frame(maxWidth: .infinity)
          .frame(height: 55).focused($isActive)
          .background(.gray.opacity(0.1), in: .rect(cornerRadius: 16))
          .opacity(store.isShowNewPassword ? .zero : 1)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled(true)

        TextField("", text: $store.newPasswordText)
          .padding(.leading)
          .frame(maxWidth: .infinity)
          .frame(height: 55).focused($isActive)
          .background(.gray.opacity(0.1), in: .rect(cornerRadius: 16))
          .opacity(store.isShowNewPassword ? 1 : .zero)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled(true)

        Text("변경할 비밀번호")
          .padding(.leading)
          .offset(y: (isActive || !store.newPasswordText.isEmpty) ? -50 : .zero)
          .animation(.spring, value: isActive)
          .foregroundStyle(isActive ? Color.blue : .secondary)
          .onTapGesture {
            isActive = true
          }
      }
      .overlay(alignment: .trailing) {
        Button(action: { store.isShowNewPassword.toggle() }) {
          Image(systemName: store.isShowNewPassword ? "eye.fill" : "eye.slash.fill")
            .padding(16)
            .foregroundStyle(store.isShowNewPassword ? .primary : .secondary)
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

// MARK: - UpdatePasswordPage.PasswordTextFieldComponent.ViewState

extension UpdatePasswordPage.PasswordTextFieldComponent {
  struct ViewState: Equatable { }
}
