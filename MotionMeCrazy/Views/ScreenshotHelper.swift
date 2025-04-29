//
//  ScreenshotHelper.swift
//  MotionMeCrazy
//
//  Created by Jillian Urgello on 4/29/25.
//

import SwiftUI

extension View {
    func screenshot(size: CGSize = CGSize(width: 250, height: 300)) -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        //let targetSize = controller.view.intrinsicContentSize
        //let targetSize = controller.sizeThatFits(in: UIView.layoutFittingCompressedSize)
        //view?.bounds = CGRect(origin: .zero, size: targetSize)
        
        view?.bounds = CGRect(origin: .zero, size: size)
        view?.backgroundColor = .clear
        
        //let renderer = UIGraphicsImageRenderer(size: targetSize)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
                    view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
