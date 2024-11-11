import ComposableArchitecture
import SwiftUI

// MARK: - MePage

struct MePage {
  @Bindable var store: StoreOf<MeReducer>
}

extension MePage { }

// MARK: View

extension MePage: View {
  var body: some View {
    ScrollView {
      VStack {
        ItemComponent(
          viewState: .init(user: store.user),
          nameTapAction: {
            store.updateUserName = ""
            store.isShowUpdateUserNameAlert = true
          },
          passwordTapAction: {
            store.send(.routeToUpdatePassword)
          },
          signOutTapAction: {
            store.send(.onTapSignOut)
          },
          deleteTapAction: {
            store.passwordText = ""
            store.isShowDeleteUserAlert = true
          })
      }
    }
    .alert(
      "이름을 변경하시겠습니까?",
      isPresented: $store.isShowUpdateUserNameAlert)
    {
      TextField("이름", text: $store.updateUserName)
        .autocorrectionDisabled(true)
        .textInputAutocapitalization(.never)

      Button(action: { store.send(.onTapUpdateUserName) }) {
        Text("확인")
      }

      Button(role: .cancel, action: { store.isShowUpdateUserNameAlert = false }) {
        Text("취소")
      }
    } message: {
      Text("변경하고 싶은 이름을 작성하시고, 확인 버튼을 눌러주세요.")
    }
    .alert(
      "로그아웃을 하시겠습니까?",
      isPresented: $store.isShowSignOutAlert)
    {
      Button(action: { store.send(.onTapSignOut) }) {
        Text("확인")
      }

      Button(role: .cancel, action: { store.isShowSignOutAlert = false }) {
        Text("취소")
      }
    } message: {
      Text("로그아웃을 하려면 확인 버튼을 눌러주세요.")
    }
    .alert(
      "계정을 탈퇴하시겟습니까?",
      isPresented: $store.isShowDeleteUserAlert)
    {
      SecureField("비밀번호", text: $store.passwordText)
        .autocorrectionDisabled(true)
        .textInputAutocapitalization(.never)

      Button(action: {
        store.send(.onTapDeleteUser)
        store.send(.deleteUserInfo)
        store.send(.deleteUserProfileImage)
      }) {
        Text("확인")
      }

      Button(role: .cancel, action: { store.isShowDeleteUserAlert = false }) {
        Text("취소")
      }
    } message: {
      Text("계정을 탈퇴 하려면 현재 비밀번호를 입력하고, 확인 버튼을 눌러주세요.")
    }
    .toolbar(.hidden, for: .navigationBar)
    .onAppear {
      store.send(.getUser)
    }
    .onDisappear {
      store.send(.teardown)
    }
  }
}
