import ComposableArchitecture
import SwiftUI

// MARK: - SignUpPage.EmailTextFieldComponent

extension SignUpPage {
  struct EmailTextFieldComponent {
    @Bindable var store: StoreOf<SignUpReducer>
    @FocusState var isActive

    let errorMessage: String?

  }
}

extension SignUpPage.EmailTextFieldComponent { }

// MARK: - SignUpPage.EmailTextFieldComponent + View

extension SignUpPage.EmailTextFieldComponent: View {
  var body: some View {
    VStack(alignment: .leading) {
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

      if let errorMessage {
        Text(errorMessage)
          .font(.footnote)
          .foregroundColor(.red)
          .padding(.leading)
      }
    }
  }
}

// MARK: - SignUpPage.EmailTextFieldComponent.ViewState

extension SignUpPage.EmailTextFieldComponent {
  struct ViewState: Equatable { }
}
