//
//  UIBarButtonItem+Badge.swift
//  Quickerala
//
//  Created by Bibin on 03/10/19.
//  Copyright © 2019 Bibin. All rights reserved.
//

import UIKit

private extension CAShapeLayer {
    func drawCircleAtLocation(location: CGPoint,
                              withRadius radius: CGFloat,
                              andColor color: UIColor,
                              filled: Bool) {
        fillColor = filled ? color.cgColor : UIColor.white.cgColor
        strokeColor = color.cgColor
        let origin = CGPoint(x: location.x - radius, y: location.y - radius)
        path = UIBezierPath(ovalIn: CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2))).cgPath
    }
}

private var handle: UInt8 = 0

extension UIBarButtonItem {
    var badgeValue: Int {
        get {
            if let text = badgeLayer?.sublayers?.filter({ $0 is CATextLayer }).first as? CATextLayer {
                return Int((text.string as? String ?? "")) ?? .zero
            }
            return .zero
        }
        set {
            guard newValue != 0 else {
                self.removeBadge(); return
            }
            if let text = badgeLayer?.sublayers?.filter({ $0 is CATextLayer }).first as? CATextLayer {
                text.string = "\(newValue)"
            } else {
                self.addBadge(number: newValue)
            }
        }
    }
}

private extension UIBarButtonItem {
    private var badgeLayer: CAShapeLayer? {
        if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
            return b as? CAShapeLayer
        } else {
            return nil
        }
    }
    
    private func addBadge(number: Int,
                          withOffset offset: CGPoint = .zero,
                          andColor color: UIColor = .applicationPrimaryColor,
                          andFilled filled: Bool = true) {
        executeInMainThread(1) {
            guard let view = self.value(forKey: "view") as? UIView else { return }
            
            self.badgeLayer?.removeFromSuperlayer()
            
            // Initialize Badge
            let badge = CAShapeLayer()
            let radius = CGFloat(10)
            let location = CGPoint(x: view.frame.width - (radius + offset.x), y: (radius + offset.y))
            badge.drawCircleAtLocation(location: location, withRadius: radius, andColor: color, filled: filled)
            badge.opacity = 0.9
            view.layer.addSublayer(badge)
            
            // Initialiaze Badge's label
            let label = CATextLayer()
            label.string = "\(number)"
            label.alignmentMode = .center
            label.fontSize = 11
            label.font = UIFont.with(size: 11, .bold)
            label.frame = CGRect(origin: CGPoint(x: location.x - 10, y: 5), size: CGSize(width: radius * 2, height: radius * 2))
            label.foregroundColor = filled ? UIColor.white.cgColor : color.cgColor
            label.backgroundColor = UIColor.clear.cgColor
            label.contentsScale = UIScreen.main.scale
            badge.addSublayer(label)
            
            // Save Badge as UIBarButtonItem property
            objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
    }
    
    private func updateBadge(number: Int) {
        if let text = badgeLayer?.sublayers?.filter({ $0 is CATextLayer }).first as? CATextLayer {
            text.string = "\(number)"
        }
    }
    
    private func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
    }
}
