import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

// MARK: - MePage.ItemComponent

extension MePage {
  struct ItemComponent {
    let viewState: ViewState
    let nameTapAction: () -> Void
    let passwordTapAction: () -> Void
    let signOutTapAction: () -> Void
    let deleteTapAction: () -> Void

  }
}

extension MePage.ItemComponent {
  private var userName: String {
    guard let userName = viewState.user.userName
    else { return viewState.user.email?.components(separatedBy: "@").first ?? "" }
    return userName.isEmpty ? viewState.user.email?.components(separatedBy: "@").first ?? "" : userName
  }
}

// MARK: - MePage.ItemComponent + View

extension MePage.ItemComponent: View {
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        VStack(alignment: .leading, spacing: 16) {
          Text("이메일")

          Text(viewState.user.email ?? "")
        }

        Spacer()
      }
      .padding(.horizontal, 16)

      Divider()

      HStack {
        VStack(alignment: .leading, spacing: 16) {
          Text("이름")
          Text(userName)
        }

        Spacer()

        Button(action: { nameTapAction() }) {
          Text("변경")
        }
      }
      .padding(.horizontal, 16)

      Divider()

      HStack {
        VStack(alignment: .leading, spacing: 16) {
          Text("비밀번호")
          Text("************")
        }

        Spacer()

        Button(action: { passwordTapAction() }) {
          Text("변경")
        }
      }
      .padding(.horizontal, 16)

      Divider()

      HStack(spacing: 40) {
        Button(action: { signOutTapAction() }) {
          Text("로그아웃")
        }

        Button(action: { deleteTapAction() }) {
          Text("계정 탈퇴")
        }
      }
      .padding(.top, 64)
    }
  }
}

// MARK: - MePage.ItemComponent.ViewState

extension MePage.ItemComponent {
  struct ViewState: Equatable {
    let user: AuthEntity.Me.Response
  }
}
