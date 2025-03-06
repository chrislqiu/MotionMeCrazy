//
//  ApiHelper.swift
//  MotionMeCrazy
//
//  Created by Ethan Donahue on 3/6/25.
//

import Foundation
import UIKit

struct APIHelper {
    static func getBaseURL() -> String {
        #if targetEnvironment(simulator)
        return "http://localhost:3000"
        #else
        //replace with your Macbook's/laptop's private ip address
        //run 'ipconfig getifaddr en0' in terminal and paste below
        return "http://192.168.1.11:3000"
        #endif
    }
}
