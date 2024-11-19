import ComposableArchitecture
import DesignSystem
import Functor
import SwiftUI

// MARK: - UpdatePasswordPage

struct UpdatePasswordPage {
  @Bindable var store: StoreOf<UpdatePasswordReducer>
}

extension UpdatePasswordPage {
  @MainActor
  private var isActiveUpdatePassword: Bool {
    Validator.validatePassword(password: store.newPasswordText)
      && isValidConfirmPassword(text: store.confirmPasswordText)
  }

  @MainActor
  private var isLoading: Bool {
    store.fetchUpdatePassword.isLoading
  }

  @MainActor
  private func isValidConfirmPassword(text: String) -> Bool {
    store.newPasswordText == text
  }
}

// MARK: View

extension UpdatePasswordPage: View {
  var body: some View {
    VStack {
      DesignSystemNavigation(
        barItem: .init(
          backAction: .init(image: Image(systemName: "xmark"), action: { }),
          title: "비밀번호 변경",
          moreActionList: []),
        isShowDivider: true)
      {
        VStack(spacing: 48) {
          TextFieldComponent(
            viewState: .init(),
            text: $store.currPasswordText,
            isShowText: $store.isShowCurrPassword,
            placeholder: "현재 비밀번호",
            errorMessage: .none,
            isSecure: true)

          TextFieldComponent(
            viewState: .init(),
            text: $store.newPasswordText,
            isShowText: $store.isShowNewPassword,
            placeholder: "변경할 비밀번호",
            errorMessage: store.isValidPassword ? .none : "영어대문자, 숫자, 특수문자를 모두 사용하여 8 ~ 20자리로 설정해주세요.",
            isSecure: true)
            .onChange(of: store.newPasswordText) { _, new in
              store.isValidPassword = Validator.validatePassword(password: new)
            }

          TextFieldComponent(
            viewState: .init(),
            text: $store.confirmPasswordText,
            isShowText: $store.isShowConfirmPassword,
            placeholder: "현재 비밀번호",
            errorMessage: store.isValidConfirmPassword ? .none : "비밀번호가 일치하지 않습니다.",
            isSecure: true)
            .onChange(of: store.confirmPasswordText) { _, new in
              store.isValidConfirmPassword = isValidConfirmPassword(text: new)
            }

          Button(action: { store.send(.onTapUpdatePassword) }) {
            Text("비밀번호 변경")
              .foregroundStyle(.white)
              .frame(height: 50)
              .frame(maxWidth: .infinity)
              .background(.blue)
              .clipShape(RoundedRectangle(cornerRadius: 8))
              .opacity(isActiveUpdatePassword ? 1.0 : 0.3)
          }
          .disabled(!isActiveUpdatePassword)
        }
        .padding(.top, 16)
        .padding(16)
      }
    }
    .toolbar(.hidden, for: .navigationBar)
    .setRequestFlightView(isLoading: isLoading)
    .onAppear { }
    .onDisappear {
      store.send(.teardown)
    }
  }
}
