//
//  Animate.swift
//  Quickerala
//
//  Created by Bibin on 20/09/19.
//  Copyright © 2019 Bibin. All rights reserved.
//

import UIKit

public extension Animation {
    
    enum ScaleMode { case down, up, normal, to(x: CGFloat, y: CGFloat) }
    
    /// Direction of animation.
    enum Direction: CaseIterable { case left, right, top, bottom }
    
    static func fadeIn(duration: TimeInterval = 0.3) -> Animation {
        return Animation(duration: duration) { $0.alpha = 1 }
    }

    static func fadeOut(duration: TimeInterval = 0.3) -> Animation {
        return Animation(duration: duration) { $0.alpha = 0 }
    }

    static func resize(to size: CGSize, duration: TimeInterval = 0.3) -> Animation {
        return Animation(duration: duration) { $0.bounds.size = size }
    }

    static func move(byX x: CGFloat, y: CGFloat, duration: TimeInterval = 0.3) -> Animation {
        return Animation(duration: duration) {
            $0.center.x += x
            $0.center.y += y
        }
    }
    
    /// Performs a shake animation on the view.
    static func shake(duration: TimeInterval = 0.08) -> Animation {
        return .init(duration: duration) {
            let positionKey = "position"
            let shake = CABasicAnimation(keyPath: positionKey)
            shake.duration = duration
            shake.repeatCount = 2
            shake.autoreverses = true
            shake.fromValue = CGPoint(x: $0.center.x - 5, y: $0.center.y)
            shake.toValue = CGPoint(x: $0.center.x + 5, y: $0.center.y)
            $0.layer.add(shake, forKey: positionKey)
        }
    }
    
     /// Performs a scale animation on the view.
    static func scale(_ mode: ScaleMode, duration: TimeInterval = 0.15, options: UIView.AnimationOptions = .curveEaseOut) -> Animation {
        return .init(duration: duration, options: options) {
            switch mode {
            case .down: $0.transform = .init(scaleX: 0.92, y: 0.92)
            case .up: $0.transform = .init(scaleX: 1.08, y: 1.08)
            case .normal: $0.transform = .identity
            case .to(let x, let y): $0.transform = .init(scaleX: x, y: y)
            }
        }
    }
    
    static func spin(duration: TimeInterval = 1.0) -> Animation {
        return .init(duration: duration) {
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = CGFloat(.pi * 2.0)
            rotateAnimation.duration = duration
            rotateAnimation.repeatCount = 1
            $0.layer.add(rotateAnimation, forKey: nil)
        }
    }
    
}

// MARK: - Public

public struct Animation {
    public let duration: TimeInterval
    public let delay: TimeInterval
    public let options: UIView.AnimationOptions
    public let closure: (UIView) -> Void

    public init(duration: TimeInterval, delay: TimeInterval = 0.0, options: UIView.AnimationOptions = [], closure: @escaping (UIView) -> Void) {
        self.duration = duration
        self.delay = 0.0
        self.options = options
        self.closure = closure
    }
}

public final class AnimationToken {
    private let view: UIView
    private let animations: [Animation]
    private let mode: AnimationMode
    private var isValid = true

    internal init(view: UIView, animations: [Animation], mode: AnimationMode) {
        self.view = view
        self.animations = animations
        self.mode = mode
    }

    deinit {
        perform {}
    }

    internal func perform(completionHandler: @escaping () -> Void) {
        guard isValid else {
            return
        }

        isValid = false

        switch mode {
        case .inSequence:
            view.performAnimations(animations, completionHandler: completionHandler)
        case .inParallel:
            view.performAnimationsInParallel(animations, completionHandler: completionHandler)
        }
    }
}

public func animate(_ tokens: [AnimationToken]) {
    guard !tokens.isEmpty else {
        return
    }

    var tokens = tokens
    let token = tokens.removeFirst()

    token.perform {
        animate(tokens)
    }
}

public func animate(_ tokens: AnimationToken...) {
    animate(tokens)
}

public extension UIView {
    @discardableResult func animate(_ animations: [Animation]) -> AnimationToken {
        return AnimationToken(
            view: self,
            animations: animations,
            mode: .inSequence
        )
    }

    @discardableResult func animate(_ animations: Animation...) -> AnimationToken {
        return animate(animations)
    }

    @discardableResult func animate(inParallel animations: [Animation]) -> AnimationToken {
        return AnimationToken(
            view: self,
            animations: animations,
            mode: .inParallel
        )
    }

    @discardableResult func animate(inParallel animations: Animation...) -> AnimationToken {
        return animate(inParallel: animations)
    }
}

// MARK: - Internal

internal enum AnimationMode {
    case inSequence
    case inParallel
}

internal extension UIView {
    func performAnimations(_ animations: [Animation], completionHandler: @escaping () -> Void) {
        guard !animations.isEmpty else {
            return completionHandler()
        }

        var animations = animations
        let animation = animations.removeFirst()
        
        UIView.animate(withDuration: animation.duration,
                       delay: animation.delay,
                       options: animation.options,
                       animations: {
                        animation.closure(self)
        }, completion: { _ in
            self.performAnimations(animations, completionHandler: completionHandler)
        })
    }

    func performAnimationsInParallel(_ animations: [Animation], completionHandler: @escaping () -> Void) {
        guard !animations.isEmpty else {
            return completionHandler()
        }

        let animationCount = animations.count
        var completionCount = 0

        let animationCompletionHandler = {
            completionCount += 1

            if completionCount == animationCount {
                completionHandler()
            }
        }

        for animation in animations {
            UIView.animate(withDuration: animation.duration,
                           delay: animation.delay,
                           options: animation.options,
                           animations: {
                            animation.closure(self)
            }, completion: { _ in
                animationCompletionHandler()
            }) 
        }
    }
}

protocol FadeTranslationAnimatable {
    /// Adds a delayed animation based on indexPath.
    /// - Parameters:
    ///     - direction: Initial position of the cell before animation starts. Default from .bottom.
    ///     - indexPath: IndexPath of the cell. This is used to calculate the delay for each indexPath.
    func fadeTranslationAnimation(from direction: Animation.Direction, after delay: TimeInterval)
}

extension FadeTranslationAnimatable where Self: UIView {

    func fadeTranslationAnimation(from direction: Animation.Direction, after delay: TimeInterval) {
        let xTranslation: CGFloat, yTranslation: CGFloat
    
        switch direction {
        case .left:
            xTranslation = -(frame.width / 2)
            yTranslation = 0
        case .right:
            xTranslation = frame.width / 2
            yTranslation = 0
        case .top:
            xTranslation = 0
            yTranslation = -(frame.height * 2)
        case .bottom:
            xTranslation = 0
            yTranslation = frame.height * 2
        }
        
        transform = CGAffineTransform(translationX: xTranslation, y: yTranslation)
        alpha = 0
        
        let delay = delay // min(0.3, 0.05 * Double(indexPath.row))
        UIView.animate(withDuration: 0.5, delay: delay, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            self.transform = .identity
            self.alpha = 1
        })
    }
    
    func fadeTranslate(from direction: Animation.Direction, at indexPath: IndexPath) {
        fadeTranslationAnimation(from: direction, after: min(0.3, 0.05 * Double(indexPath.row)))
    }
}

extension UITableViewCell: FadeTranslationAnimatable {}

extension UICollectionViewCell: FadeTranslationAnimatable {}
