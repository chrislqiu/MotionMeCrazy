//
//  UserViewModel.swift
//  MotionMeCrazy
//
//  Created by Rachel La on 2/21/25.
//

import SwiftUI

class UserViewModel: ObservableObject, Identifiable {
    @Published var userid: Int
    @Published var username: String
    @Published var profilePicId: String

    init(userid: Int, username: String, profilePicId: String) {
        self.userid = userid
        self.username = username
        self.profilePicId = profilePicId
    }
}
