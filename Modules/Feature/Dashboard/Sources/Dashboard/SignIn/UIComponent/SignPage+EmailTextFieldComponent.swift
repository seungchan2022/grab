import ComposableArchitecture
import SwiftUI

// MARK: - SignInPage.EmailTextFieldComponent

extension SignInPage {
  struct EmailTextFieldComponent {
    @Bindable var store: StoreOf<SignInReducer>
    @FocusState var isActive
  }
}

extension SignInPage.EmailTextFieldComponent { }

// MARK: - SignInPage.EmailTextFieldComponent + View

extension SignInPage.EmailTextFieldComponent: View {
  var body: some View {
    ZStack(alignment: .leading) {
      TextField("", text: $store.emailText)
        .padding(.leading)
        .frame(maxWidth: .infinity)
        .frame(height: 55)
        .focused($isActive)
        .background(.gray.opacity(0.1), in: .rect(cornerRadius: 16))
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)

      Text("이메일")
        .padding(.leading)
        .offset(y: (isActive || !store.emailText.isEmpty) ? -50 : .zero)
        .animation(.spring, value: isActive)
        .foregroundStyle(isActive ? Color.blue : .secondary)
        .onTapGesture {
          isActive = true
        }
    }
  }
}

// MARK: - SignInPage.EmailTextFieldComponent.ViewState

extension SignInPage.EmailTextFieldComponent {
  struct ViewState: Equatable { }
}
