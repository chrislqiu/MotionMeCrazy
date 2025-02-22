//
//  UserViewModel.swift
//  MotionMeCrazy
//
//  Created by Rachel La on 2/21/25.
//

import SwiftUI

class UserViewModel: ObservableObject, Identifiable {
    @Published var userid: Int = 0
    @Published var username: String = ""
    @Published var profilePicId: String = ""
}
