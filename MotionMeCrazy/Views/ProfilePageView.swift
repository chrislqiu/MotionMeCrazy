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
    @State private var selectedImage: String = "pfp1"  // Initial profile image
    @State private var showSelector = false  // Controls modal visibility
    let images = ["pfp1", "pfp2"]
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()
            
            VStack(alignment: .center) {
                CustomHeader(config: CustomHeaderConfig(title: "Profile"))
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer()
                
                VStack(alignment: .center, spacing: 10) {
                    Image(selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.darkBlue, lineWidth: 3))
                        .onTapGesture {
                            showSelector.toggle()
                        }
                    
                    CustomText(config: CustomTextConfig(text: username))
                    CustomText(config: CustomTextConfig(text: String(userid)))
                    
                    CustomButton(config: CustomButtonConfig(title: "Edit", width: 100, buttonColor: .darkBlue
) {
                        isEditing.toggle()
                    })
                    .alert("Edit Username", isPresented: $isEditing) {
                        TextField("Enter a new username", text: $newUsername)
                        Button("Cancel", action: { isEditing.toggle() })
                        Button("Submit", action: submit)
                    } message: {
                        Text("Please enter a new username")
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
        }
        .sheet(isPresented: $showSelector) {
            VStack {
                Text("Select Your Profile Picture")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("DarkBlue"))
                    .padding(.top, 20)
                
                LazyVGrid(
                    columns: Array(repeating: .init(.flexible()), count: 3),
                    spacing: 15
                ) {
                    ForEach(images, id: \.self) { imageName in
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(
                                        selectedImage == imageName
                                        ? Color.blue : Color.clear,
                                        lineWidth: 4)
                            )
                            .onTapGesture {
                                selectedImage = imageName
                                showSelector = false  // Close modal after selection
                            }
                    }
                }
                Spacer()
            }
        }
    }
    func submit() {
        // TODO: save new username to db
        username = newUsername
    }
}

#Preview {
    ProfilePageView(username: "test", userid: 12345)
}
