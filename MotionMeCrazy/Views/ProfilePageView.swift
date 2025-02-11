import SwiftUI

struct ProfilePageView: View {
    @State private var username: String
    let userid: Int
    @State private var isEditing: Bool = false
    @State private var newUsername: String = ""

    init(username: String, userid: Int) {
        _username = State(initialValue: username)
        self.userid = userid
    }

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()
            VStack {
                CustomHeader(config: CustomHeaderConfig(title: "Profile Page"))
                CustomText(config: CustomTextConfig(title: username))
                CustomText(config: CustomTextConfig(title: String(userid)))
                CustomButton(config: CustomButtonConfig(title: "Edit", width: 100)  {
                    isEditing.toggle()})
                .alert("Edit Username", isPresented: $isEditing) {
                    TextField("Enter a new username", text: $newUsername)
                    Button("Cancel", action: {isEditing.toggle()})
                    Button("Submit", action: submit)
                } message: {
                    Text("Please enter a new username")
                }
                
            }
        }
        
    }
    func submit() {
        // TODO: save new username to db
        username = newUsername
    }
}

#Preview {
    ProfilePageView(username: "raquel", userid: 12345)
}
