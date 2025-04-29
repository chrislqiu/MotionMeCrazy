//
//  ShareScoreView.swift
//  MotionMeCrazy
//
//  Created by Jillian Urgello on 4/29/25.
//

import SwiftUI
import UIKit

struct ShareScoreView: UIViewControllerRepresentable {
    let message: String
    let image: UIImage
    
    //var items: [Any] = [message, image]
    //var excludedActivityTypes: [UIActivity.ActivityType]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        var items: [Any] = [message, image]
        var excludedActivityTypes: [UIActivity.ActivityType]? = nil
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.excludedActivityTypes = excludedActivityTypes
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
