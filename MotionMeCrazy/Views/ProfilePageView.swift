import SwiftUI

struct ProfilePageView: View {
    @ObservedObject var userViewModel: UserViewModel

    @State private var newUsername: String = ""
    @State private var isEditing: Bool = false
    @State private var showSelector = false  // Controls modal visibility
    @State private var errorMessage: String?  // For displaying errors

    let images = ["pfp1", "pfp2", "pfp3", "pfp4", "pfp5", "pfp6"]
    var body: some View {
        NavigationStack {
            ZStack {
                Image("background")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack(alignment: .center) {
                    CustomHeader(config: CustomHeaderConfig(title: "Profile"))
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 10) {
                        Image(userViewModel.profilePicId)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(.darkBlue, lineWidth: 3))
                            .onTapGesture {
                                showSelector.toggle()
                            }.accessibilityIdentifier("profilePicture")
                        
                        CustomText(config: CustomTextConfig(text: userViewModel.username))
                            .accessibilityIdentifier("username")
                        CustomText(
                            config: CustomTextConfig(text: "User ID: \(userViewModel.userid)")
                        ).accessibilityIdentifier("userid")
                        
                        CustomButton(
                            config: CustomButtonConfig(
                                title: "Edit", width: 100,
                                buttonColor: .darkBlue
                            ) {
                                isEditing.toggle()
                            }
                        )
                        .accessibilityIdentifier("Edit")
                        .alert("Edit Username", isPresented: $isEditing) {
                            TextField(
                                "Enter a new username", text: $newUsername
                            )
                            .accessibilityIdentifier("editUsernameField")
                            Button("Cancel", action: { isEditing.toggle() })
                            Button("Submit", action: submit)
                                .accessibilityIdentifier("submitUsernameButton")
                        } message: {
                            Text("Please enter a new username")
                        }
                        CustomButton(
                            config: CustomButtonConfig(
                                title: "Stats",
                                width: 100,
                                buttonColor: .darkBlue,
                                destination: AnyView(StatisticsPageView(userViewModel: userViewModel))  // Ensure type erasure with AnyView
                            )
                        ).accessibilityIdentifier("statsButton")
                        
                    }
                    Spacer()
                }
                .frame(
                    maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
            }
            .sheet(isPresented: $showSelector) {
                VStack {
                    Text("Select Your Profile Picture")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("DarkBlue"))
                        .padding(.top, 20)
                        .accessibilityIdentifier("profilePictureSelector")
                    
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
                                            userViewModel.profilePicId == imageName
                                            ? Color.blue : Color.clear,
                                            lineWidth: 4)
                                )
                                .onTapGesture {
                                    userViewModel.profilePicId = imageName
                                    showSelector = false  // Close modal after selection
                                    updateUser()
                                }.accessibilityIdentifier(imageName)
                        }
                    }
                    Spacer()
                }
            }
        }
    }
    func submit() {
        userViewModel.username = newUsername
        updateUser()
    }
    
    func updateUser() {
        guard let url = URL(string: "http://localhost:3000/user?userId=\(userViewModel.userid)") else {
            print("Invalid URL")
            return
        }

        let body: [String: Any] = [
            "newUsername": userViewModel.username,
            "newProfilePicId": userViewModel.profilePicId,
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body)
        else {
            print("Failed to encode JSON")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    self.errorMessage = "Network error, please try again"
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        print("User information successfully updated!")
                        self.errorMessage = nil
                    } else {
                        self.errorMessage =
                        "Username already exists, please try again"
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    
   // ProfilePageView(username: "user", userid: 69, profilePicId: "pfp2")
    
}
