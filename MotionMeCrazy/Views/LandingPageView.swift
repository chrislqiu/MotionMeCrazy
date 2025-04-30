//
//  LandingPageView.swift
//  MotionMeCrazy
//
//  Created by Chris Qiu on 2/6/25.
//

import SwiftUI

struct LandingPageView: View {
    @EnvironmentObject var appState: AppState
    
    @StateObject private var userViewModel = UserViewModel(userid: 0, username: "", profilePicId: "")
    
    @State private var selectedImage: String = "pfp1"
    @State private var showSelector = false
    @State private var showCopiedMessage = false
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoginMode: Bool = true
    @State private var errorMessage: String?
    @State private var navigateToMainPage = false

    let images = ["pfp1", "pfp2", "pfp3", "pfp4", "pfp5", "pfp6"]

    var body: some View {
        NavigationStack {
            ZStack {
                Image("background")
                    .resizable()
                    .ignoresSafeArea()
                
                if !appState.loading {
                    VStack {
                        Text("Motion Me\nCrazy")
                            .font(.system(size: 48, weight: .heavy))
                            .foregroundColor(Color("DarkBlue"))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 35)
                            .accessibilityIdentifier("appTitle")
                        
                        NavigationLink(
                            destination: MainPageView()
                                .environmentObject(userViewModel)
                                .navigationBarBackButtonHidden(true),
                            isActive: $navigateToMainPage
                        ) {
                            EmptyView()
                        }

                        if appState.offlineMode {
                            NavigationLink(
                                destination: MainPageView()
                                    .environmentObject(userViewModel)
                                    .navigationBarBackButtonHidden(true),
                                isActive: $navigateToMainPage
                            ) {
                                Button(action: {
                                    navigateToMainPage = true
                                }) {
                                    Text(appState.localized("Play Offline"))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 180, height: 50)
                                        .background(Color.blue)
                                        .cornerRadius(25)
                                        .shadow(radius: 5)
                                }
                                .padding(.top, 20)
                                .accessibilityIdentifier("playOfflineButton")
                            }
                            .padding(.top, 20)
                            .accessibilityIdentifier("playOfflineButton")
                        } else {
                            Image(selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(.darkBlue, lineWidth: 3))
                                .onTapGesture {
                                    showSelector.toggle()
                                }
                                .accessibilityIdentifier("profilePicture")
                            
                            Text("Username")
                                .font(.headline)
                                .foregroundColor(.white)
                            TextField("Enter your username", text: $username)
                                .font(.title2)
                                .padding()
                                .frame(width: 250)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                                .multilineTextAlignment(.leading)
                                .accessibilityLabel("usernameField")
                                .foregroundColor(.black)

                            if showCopiedMessage {
                                Text(appState.localized("Copied to clipboard!"))
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .padding(.top, 5)
                                    .accessibilityIdentifier("copyMessage")
                            }
                            
                            if let errorMessage = errorMessage {
                                Text(errorMessage)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                    .padding(.top, 5)
                                    .accessibilityIdentifier("errorMessage")
                            }

                            if isLoginMode {
                                Text("Password")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                SecureField("Enter your password", text: $password)
                                    .font(.title2)
                                    .padding()
                                    .frame(width: 250)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.black)

                                
                                Button(action: {
                                    loginUser()
                                }) {
                                    Text("Login")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 180, height: 50)
                                        .background(Color.blue)
                                        .cornerRadius(25)
                                        .shadow(radius: 5)
                                }
                                .padding(.top, 20)
                                .accessibilityIdentifier("loginButton")
                                
                                Button(action: {
                                    isLoginMode = false
                                }) {
                                    Text("Don't have an account? Sign up!")
                                        .font(.footnote)
                                        .foregroundColor(.blue)
                                        .padding()
                                        .background(Color.white.opacity(0.8))
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                        .padding(.top, 10)
                                }
                            } else {
                                Text("Password")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                SecureField("Enter your password", text: $password)
                                    .font(.title2)
                                    .padding()
                                    .frame(width: 250)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.black)


                                Text("Confirm Password")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                SecureField("Confirm password", text: $confirmPassword)
                                    .font(.title2)
                                    .padding()
                                    .frame(width: 250)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.black)


                                Button(action: {
                                    createUser()
                                }) {
                                    Text("Create Account")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 180, height: 50)
                                        .background(Color.blue)
                                        .cornerRadius(25)
                                        .shadow(radius: 5)
                                }
                                .padding(.top, 20)
                                .accessibilityIdentifier("createAccountButton")
                                
                                Button(action: {
                                    isLoginMode = true
                                }) {
                                    Text("Already have an account? Log in!")
                                        .font(.footnote)
                                        .foregroundColor(.blue)
                                        .padding()
                                        .background(Color.white.opacity(0.8))
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                        .padding(.top, 10)
                                }
                            }

                            Spacer()
                        }
                    }
                }
            }
            .sheet(isPresented: $showSelector) {
                VStack {
                    Text(appState.localized("Select Your Profile Picture"))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("DarkBlue"))
                        .padding(.top, 20)
                        .accessibilityIdentifier("picSelectScreen")
                    
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 15) {
                        ForEach(images, id: \.self) { imageName in
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(
                                        selectedImage == imageName ? Color.blue : Color.clear,
                                        lineWidth: 4
                                    )
                                )
                                .onTapGesture {
                                    selectedImage = imageName
                                    showSelector = false
                                }
                                .accessibilityIdentifier("picOption")
                        }
                    }
                    Spacer()
                }
            }
        }
    }

    func createUser() {
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            return
        }
        
        guard let url = URL(string: APIHelper.getBaseURL() + "/user") else {
            print("Invalid URL")
            return
        }

        let body: [String: Any] = [
            "username": username,
            "profilePicId": selectedImage,
            "password": password,
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Failed to encode JSON")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
                        if let data = data {
                            do {
                                let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                                userViewModel.userid = userResponse.userid
                                userViewModel.username = userResponse.username
                                userViewModel.profilePicId = userResponse.profilepicid
                                self.errorMessage = nil
                            } catch {
                                self.errorMessage = "Failed to parse response"
                                print(error)
                            }
                        }
                        print("User successfully created!")
                        self.errorMessage = nil
                        navigateToMainPage = true
                    } else {
                        self.errorMessage = "Username already exists, please try again"
                    }
                }
            }
        }.resume()
    }

    func loginUser() {
        guard let url = URL(string: APIHelper.getBaseURL() + "/signin") else {
            print("Invalid URL")
            return
        }

        let body: [String: Any] = [
            "username": username,
            "password": password,
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Failed to encode JSON")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
                        if let data = data {
                            do {
                                let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                                userViewModel.userid = userResponse.userid
                                userViewModel.username = userResponse.username
                                userViewModel.profilePicId = userResponse.profilepicid
                                self.errorMessage = nil
                            } catch {
                                self.errorMessage = "Failed to parse response"
                                print(error)
                            }
                        }
                        print("Login successful!")
                        self.errorMessage = nil
                        navigateToMainPage = true
                    } else {
                        self.errorMessage = "Invalid credentials, please try again"
                    }
                }
            }
        }.resume()
    }
}



struct UserResponse: Codable {
    let userid: Int
    let username: String
    let profilepicid: String
}

#Preview {
    LandingPageView()
}


