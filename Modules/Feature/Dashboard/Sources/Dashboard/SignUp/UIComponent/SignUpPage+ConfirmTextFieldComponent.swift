import ComposableArchitecture
import SwiftUI

// MARK: - SignUpPage.ConfirmTextFieldComponent

extension SignUpPage {
  struct ConfirmTextFieldComponent {
    @Bindable var store: StoreOf<SignUpReducer>
    @FocusState var isActive

    let errorMessage: String?
  }
}

extension SignUpPage.ConfirmTextFieldComponent { }

// MARK: - SignUpPage.ConfirmTextFieldComponent + View

extension SignUpPage.ConfirmTextFieldComponent: View {
  var body: some View {
    VStack(alignment: .leading) {
      ZStack(alignment: .leading) {
        SecureField("", text: $store.confirmPasswordText)
          .padding(.leading)
          .frame(maxWidth: .infinity)
          .frame(height: 55).focused($isActive)
          .background(.gray.opacity(0.1), in: .rect(cornerRadius: 16))
          .opacity(store.isShowConfirmPassword ? .zero : 1)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled(true)

        TextField("", text: $store.confirmPasswordText)
          .padding(.leading)
          .frame(maxWidth: .infinity)
          .frame(height: 55).focused($isActive)
          .background(.gray.opacity(0.1), in: .rect(cornerRadius: 16))
          .opacity(store.isShowConfirmPassword ? 1 : .zero)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled(true)

        Text("비밀번호 확인")
          .padding(.leading)
          .offset(y: (isActive || !store.confirmPasswordText.isEmpty) ? -50 : .zero)
          .animation(.spring, value: isActive)
          .foregroundStyle(isActive ? Color.blue : .secondary)
          .onTapGesture {
            isActive = true
          }
      }
      .overlay(alignment: .trailing) {
        Button(action: { store.isShowConfirmPassword.toggle() }) {
          Image(systemName: store.isShowConfirmPassword ? "eye.fill" : "eye.slash.fill")
            .padding(16)
            .foregroundStyle(store.isShowConfirmPassword ? .primary : .secondary)
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

// MARK: - SignUpPage.ConfirmTextFieldComponent.ViewState

extension SignUpPage.ConfirmTextFieldComponent {
  struct ViewState: Equatable { }
}
