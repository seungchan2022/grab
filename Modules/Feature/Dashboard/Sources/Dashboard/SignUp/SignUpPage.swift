import ComposableArchitecture
import DesignSystem
import Functor
import SwiftUI

// MARK: - SignUpPage

struct SignUpPage {
  @Bindable var store: StoreOf<SignUpReducer>

}

extension SignUpPage {
  @MainActor
  private var isActiveSignUp: Bool {
    Validator.validateEmail(email: store.emailText)
      && Validator.validatePassword(password: store.passwordText)
      && isValidConfirmPassword(text: store.confirmPasswordText)
  }

  @MainActor
  private var isLoading: Bool {
    store.fetchSignUp.isLoading
  }

  @MainActor
  private func isValidConfirmPassword(text: String) -> Bool {
    store.passwordText == text
  }
}

// MARK: View

extension SignUpPage: View {
  var body: some View {
    DesignSystemNavigation(
      barItem: .init(backAction: .init(image: Image(systemName: "chevron.left"), action: { store.send(.routeToBack) })),
      largeTitle: "Sign Up")
    {
      VStack(spacing: 48) {
        TextFieldComponent(
          viewState: .init(),
          text: $store.emailText,
          isShowText: .constant(false),
          placeholder: "이메일",
          errorMessage: store.isValidEmail ? .none : "유효한 이메일 주소 x",
          isSecure: false)
          .onChange(of: store.emailText) { _, new in
            store.isValidEmail = Validator.validateEmail(email: new)
          }

        TextFieldComponent(
          viewState: .init(),
          text: $store.passwordText,
          isShowText: $store.isShowPassword,
          placeholder: "비밀번호",
          errorMessage: store.isValidPassword ? .none : "영어대문자, 숫자, 특수문자를 모두 사용하여 8 ~ 20자리로 설정해주세요.",
          isSecure: true)
          .onChange(of: store.passwordText) { _, new in
            store.isValidPassword = Validator.validatePassword(password: new)
          }

        TextFieldComponent(
          viewState: .init(),
          text: $store.confirmPasswordText,
          isShowText: $store.isShowConfirmPassword,
          placeholder: "비밀번호 확인",
          errorMessage: store.isValidConfirmPassword ? .none : "비밀번호가 일치하지 않습니다.",
          isSecure: true)
          .onChange(of: store.confirmPasswordText) { _, new in
            store.isValidConfirmPassword = isValidConfirmPassword(text: new)
          }

        Button(action: { store.send(.onTapSignUp) }) {
          Text("회원 가입")
            .foregroundStyle(.white)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(.blue)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(isActiveSignUp ? 1.0 : 0.3)
        }
        .disabled(!isActiveSignUp)
      }
      .padding(16)
    }
    .toolbarVisibility(.hidden, for: .navigationBar)
    .setRequestFlightView(isLoading: isLoading)
    .onAppear { }
    .onDisappear {
      store.send(.teardown)
    }
  }
}
