import ComposableArchitecture
import DesignSystem
import SwiftUI

// MARK: - SignInPage

struct SignInPage {
  @Bindable var store: StoreOf<SignInReducer>

  @Environment(\.colorScheme) var colorScheme
}

extension SignInPage {

  @MainActor
  private var isActiveSignIn: Bool {
    !store.emailText.isEmpty && !store.passwordText.isEmpty
  }

}

// MARK: View

extension SignInPage: View {
  var body: some View {
    DesignSystemNavigation(
      barItem: .init(),
      largeTitle: "Sign In")
    {
      VStack(spacing: 48) {
        TextFieldComponent(
          viewState: .init(),
          text: $store.emailText,
          isShowText: .constant(false),
          placeholder: "이메일",
          isSecure: false)

        TextFieldComponent(
          viewState: .init(),
          text: $store.passwordText,
          isShowText: $store.isShowPassword,
          placeholder: "비밀번호",
          isSecure: true)

        Button(action: { store.send(.onTapSignIn) }) {
          Text("로그인")
            .foregroundStyle(.white)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(.blue)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(isActiveSignIn ? 1.0 : 0.3)
        }
        .disabled(!isActiveSignIn)

        HStack {
          Spacer()
          Button(action: {
            store.resetEmailText = ""
            store.isShowResetPassword = true
          }) {
            Text("비밀번호 재설정")
          }

          Spacer()

          Divider()

          Spacer()

          Button(action: {
            store.emailText = ""
            store.passwordText = ""
            store.send(.routeToSignUp)
          }) {
            Text("회원 가입")
          }

          Spacer()
        }
        .padding(.top, 8)
      }
      .padding(16)
    }
    .sheet(isPresented: $store.isShowResetPassword, content: {
      ResetPasswordComponent(
        store: store,
        tapAction: { store.send(.onTapResetPassword) })
        .presentationDetents([.fraction(0.4)])
    })

    .toolbarVisibility(.hidden, for: .navigationBar)
    .onAppear { }
    .onDisappear {
      store.send(.teardown)
    }
  }
}
