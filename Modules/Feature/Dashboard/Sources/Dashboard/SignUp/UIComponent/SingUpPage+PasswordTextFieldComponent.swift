import ComposableArchitecture
import SwiftUI

// MARK: - SignUpPage.PasswordTextFieldComponent

extension SignUpPage {
  struct PasswordTextFieldComponent {
    @Bindable var store: StoreOf<SignUpReducer>
    @FocusState var isActive

    let errorMessage: String?
  }
}

extension SignUpPage.PasswordTextFieldComponent { }

// MARK: - SignUpPage.PasswordTextFieldComponent + View

extension SignUpPage.PasswordTextFieldComponent: View {
  var body: some View {
    VStack(alignment: .leading) {
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

      if let errorMessage {
        Text(errorMessage)
          .font(.footnote)
          .foregroundColor(.red)
          .padding(.leading)
      }
    }
  }
}

// MARK: - SignUpPage.PasswordTextFieldComponent.ViewState

extension SignUpPage.PasswordTextFieldComponent {
  struct ViewState: Equatable { }
}
