import ComposableArchitecture
import SwiftUI

// MARK: - SignInPage.PasswordTextFieldComponent

extension SignInPage {
  struct PasswordTextFieldComponent {
    @Bindable var store: StoreOf<SignInReducer>

    @FocusState var isActive
  }
}

extension SignInPage.PasswordTextFieldComponent { }

// MARK: - SignInPage.PasswordTextFieldComponent + View

extension SignInPage.PasswordTextFieldComponent: View {
  var body: some View {
    ZStack(alignment: .leading) {
      SecureField("", text: $store.passwordText)
        .padding(.leading)
        .frame(maxWidth: .infinity)
        .frame(height: 55).focused($isActive)
        .background(.gray.opacity(0.1), in: .rect(cornerRadius: 16))
        .opacity(store.isShowPassword ? .zero : 1)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)

      TextField("", text: $store.passwordText)
        .padding(.leading)
        .frame(maxWidth: .infinity)
        .frame(height: 55).focused($isActive)
        .background(.gray.opacity(0.1), in: .rect(cornerRadius: 16))
        .opacity(store.isShowPassword ? 1 : .zero)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)

      Text("비밀번호")
        .padding(.leading)
        .offset(y: (isActive || !store.passwordText.isEmpty) ? -50 : .zero)
        .animation(.spring, value: isActive)
        .foregroundStyle(isActive ? Color.blue : .secondary)
        .onTapGesture {
          isActive = true
        }
    }
    .overlay(alignment: .trailing) {
      Button(action: { store.isShowPassword.toggle() }) {
        Image(systemName: store.isShowPassword ? "eye.fill" : "eye.slash.fill")
          .padding(16)
          .foregroundStyle(store.isShowPassword ? .primary : .secondary)
      }
    }
  }
}

// MARK: - SignInPage.PasswordTextFieldComponent.ViewState

extension SignInPage.PasswordTextFieldComponent {
  struct ViewState: Equatable { }
}
