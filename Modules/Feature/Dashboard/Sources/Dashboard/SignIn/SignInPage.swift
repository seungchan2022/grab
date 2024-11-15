import ComposableArchitecture
import DesignSystem
import SwiftUI

// MARK: - SignInFocus

enum SignInFocus {
  case email
  case password
}

// MARK: - SignInPage

struct SignInPage {
  @Bindable var store: StoreOf<SignInReducer>

  @FocusState private var isFocused: SignInFocus?

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
      VStack(spacing: 32) {
        TextFieldComponent(
          viewState: .init(),
          title: "이메일 주소",
          placeholder: "이메일",
          isSecure: false,
          toggleAction: .none,
          isFocused: $isFocused,
          focusType: .email,
          text: $store.emailText)

        TextFieldComponent(
          viewState: .init(),
          title: "비밀번호",
          placeholder: "비밀번호",
          isSecure: !store.isShowPassword,
          toggleAction: { store.isShowPassword.toggle() },
          isFocused: $isFocused,
          focusType: .password,
          text: $store.passwordText)

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

          Button(action: { store.send(.routeToSignUp) }) {
            Text("회원 가입")
          }

          Spacer()
        }
        .padding(.top, 8)
      }
      .padding(16)
    }
    .alert(
      "비밀번호 재설정",
      isPresented: $store.isShowResetPassword,
      actions: {
        TextField("이메일", text: $store.resetEmailText)
          .autocorrectionDisabled(true)
          .textInputAutocapitalization(.never)

        Button(role: .cancel, action: { store.isShowResetPassword = false }) {
          Text("취소")
        }

        Button(action: { store.send(.onTapResetPassword) }) {
          Text("확인")
        }
      },
      message: {
        Text("계정과 연결된 이메일 주소를 입력하면, 비밀번호 재설정 링크가 이메일로 전송됩니다.")
      })
    .toolbarVisibility(.hidden, for: .navigationBar)
    .onAppear {
      isFocused = .email
    }
    .onDisappear {
      store.send(.teardown)
    }
  }
}
