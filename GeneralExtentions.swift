//
//  Extentions.swift
//  Quickerala
//
//  Created by Bibin on 24/05/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import UIKit

// MARK: - UserDefaults
extension UserDefaults {
    
    /// Set Codable object into UserDefaults
    /// - Parameter value: Codable Object to store in userdefaults
    /// - Parameter defaultName: Key sreing
    func set<T: Codable>(value: T, forKey defaultName: String) throws {
        let jsonData = try JSONEncoder().encode(value)
        set(jsonData, forKey: defaultName)
    }
    
    /// Get Codable object into UserDefaults
    ///
    /// - Parameters:
    ///   - type: Codable Object
    ///   - forKey: Key string
    /// - Throws: UserDefaults Error
    public func get<T: Codable>(_ type: T.Type, forKey defaultName: String) throws -> T? {
        
        guard let result = value(forKey: defaultName) as? Data else {
            return nil
        }
        
        return try JSONDecoder().decode(type, from: result)
    }
    
    /// Returns the selected Environment
//    var environment: Deployment.Environment {
//        get {
//            if string(forKey: #function) == nil { set(Deployment.Environment.staging.url, forKey: #function) }
//            return Deployment.Environment.init(with: string(forKey: #function)!)
//        }
//        set { set(newValue.url, forKey: #function) }
//    }
    
    /// Will be true at first app launch.
    var isInitialAppLaunch: Bool {
        get {
            // if no value present, it means it is initial Launch.
            guard value(forKey: #function) != nil else { return true }
            return bool(forKey: #function)
        }
        set { set(newValue, forKey: #function) }
    }
}

// MARK: - BaseView
extension BaseView where Self: UIViewController {
    func showProgress() { executeInMainThread { CActivityIndicator.show() } }
    func hideProgress() { executeInMainThread { CActivityIndicator.hide() } }
}

extension BaseView where Self: BaseViewController {
    func show(_ warning: WarningItem) {
        executeInMainThread {
            guard self.view != nil else { return }
            let warningView = WarningView.instantiate()
            warningView.warning = warning
            warningView.present(on: self.view)
        }
    }
    
    func dismiss() {
        guard navigationController?.popViewController(animated: true) != nil else {
            dismiss(animated: true)
            return
        }
    }
}

// MARK: - String
extension String {
    // return first letter of string
    subscript (i: Int) -> Character {
      return self[index(startIndex, offsetBy: i)]
    }
    /// Removes whitespaces & newlines from both ends of a string.
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Checks whether the string is email using regular expression.
    var isEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    var isURL: Bool {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return false }
        let matches = detector.matches(in: self,
                                       options: [],
                                       range: NSRange(location: 0, length: self.utf16.count))
        return (!matches.isEmpty && URL(string: self) != nil)
    }
    
    var isValidContact: Bool {
        let phoneNumberRegex = "^[6-9]\\d{9}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
        let isValidPhone = phoneTest.evaluate(with: self)
        return isValidPhone
    }
    
    /// Replaces HTML content in a string with corresponding UTF8 character.
    var unescapingEntities: String {
        guard let data = data(using: .utf8) else { return "" }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else { return "" }
        return attributedString.string
    }
    
    var capitalizedFirst: String { return prefix(1).capitalized + dropFirst() }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.width)
    }
    
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    
    func stripHtml() -> String {
        let strippedText = self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        return strippedText
    }
    
    var camelCasingToSentence: String {
        return unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                if !$0.isEmpty { return ($0 + " " + String($1)) }
            }
            return $0 + String($1)
        }
    }
}

// MARK: - UIView
extension UIView {
    
    /// Adds a cornerradius to the view with specified radius.
    var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.cornerRadius  = newValue
            layer.masksToBounds = newValue != 0
            clipsToBounds       = newValue != 0
        }
    }
    
    func roundedCorners() { cornerRadius = frame.height / 2 }
    
    /// Rounds the specific corners of a UIView.
    /// - Parameter corners: Collection of corners to round.
    /// - Parameter cornerRadius: The radius of the roundness.
    func round(corners: UIRectCorner, cornerRadius: Double) {
        
        let size = CGSize(width: cornerRadius, height: cornerRadius)
        let bezierPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: size)
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = self.bounds
        shapeLayer.path = bezierPath.cgPath
        self.layer.mask = shapeLayer
    }
    
    /// Adds a border around the view.
    /// - Parameters:
    ///     - width: Width of the border around the view.
    ///     - color: Color of the border.
    func setBorder(width: CGFloat, color: UIColor) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }
    
    /// Adds shadow to the view.
    /// - Parameters:
    ///     - color: Color of the shadow. Default DarkGray with 0.2 opacity.
    ///     - offset: The offset (in points) of the layer’s shadow.
    func setShadow(color: UIColor = UIColor.black.withAlphaComponent(0.2), offset: CGSize = .init(width: 0, height: 5), radius: CGFloat = 3) {
        executeInMainThread(0.2) { [weak self] in
            self?.layer.shadowColor = color.cgColor
            self?.layer.shadowOpacity = 0
            self?.layer.shadowOffset = offset
            self?.layer.shadowRadius = radius
            self?.layer.shadowPath = UIBezierPath(roundedRect: self?.bounds ?? .zero, cornerRadius: self?.cornerRadius ?? 0).cgPath
            self?.layer.shouldRasterize = true
            self?.layer.rasterizationScale = UIScreen.main.scale
            self?.layer.masksToBounds = false
            self?.layer.needsDisplayOnBoundsChange = true
            
            let animation = CABasicAnimation(keyPath: "shadowOpacity")
            animation.fromValue = self?.layer.shadowOpacity
            animation.toValue = 1.0
            animation.duration = 1.0
            self?.layer.add(animation, forKey: animation.keyPath)
            self?.layer.shadowOpacity = 1.0
        }
    }
    
    /// Adds parallax motion effect to the view.
    func addMotionEffect(relativeOrigin: CGPoint = .init(x: 40, y: 40)) {
        
        let xMotion = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.x", type: .tiltAlongHorizontalAxis)
        xMotion.minimumRelativeValue = -relativeOrigin.x
        xMotion.maximumRelativeValue = relativeOrigin.x
        
        let yMotion = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.y", type: .tiltAlongVerticalAxis)
        yMotion.minimumRelativeValue = -relativeOrigin.y
        yMotion.maximumRelativeValue = relativeOrigin.y
        
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [xMotion, yMotion]
        addMotionEffect(motionEffectGroup)
    }
    
    func gradientBackground(with colors: [UIColor], _ direction: UIColor.Gradient.Direction = .vertical, animated: Bool = true) {
        if animated {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = .fade
            transition.timingFunction = .init(name: .easeInEaseOut) 
            layer.add(transition, forKey: kCATransition)
        }
        let gradientColor = colors.gradient(with: bounds, direction: direction)
        backgroundColor = gradientColor
    }
    
    func setCurvedTopView(_ rect: CGRect) {
        let color = UIColor.red
        let y: CGFloat = 0
        let myBezier = UIBezierPath()
        myBezier.move(to: CGPoint(x: 0, y: y))
        myBezier.addQuadCurve(to: CGPoint(x: rect.width, y: y), controlPoint: CGPoint(x: rect.width / 2, y: rect.height / 3))
        myBezier.addLine(to: CGPoint(x: rect.width, y: rect.height))
        myBezier.addLine(to: CGPoint(x: 0, y: rect.height))
        myBezier.close()
        color.setFill()
        myBezier.fill()
    }
    func roundedMask(with maskView: UIView, invert: Bool = false) {
        self.layer.mask = nil
        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()
        if invert { path.addRect(self.bounds) }
        path.addEllipse(in: maskView.frame)
        maskLayer.path = path
        if invert { maskLayer.fillRule = .evenOdd }
        // Set the mask of the view.
        self.layer.mask = maskLayer
    }
    
    func onChangeFrame(_ handler: @escaping ((CGRect) -> Void)) -> NSKeyValueObservation {
        return observe(\.bounds, options: .new) { _, change in
            guard let newFrame = change.newValue else { return }
            handler(newFrame)
        }
    }
    
    //shake view
    func shake() {
        self.transform = CGAffineTransform(translationX: 20, y: 0)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @discardableResult func addTransitionAnimation(duration: TimeInterval = 0.3, type: CATransitionType = .fade) -> CATransition {
        let transition = CATransition()
        transition.duration = duration
        transition.type = type
        transition.timingFunction = .init(name: .easeInEaseOut)
        layer.add(transition, forKey: kCATransition)
        return transition
    }
}

// MARK: - UIColor
extension UIColor {
    struct Gradient {
        enum Direction { case vertical, horizontal }
    }
    
    static var random: UIColor {
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
    }
    static var gradientOrange: UIColor {
        return UIColor(red: 255.0, green: 161.0, blue: 144.0, alpha: 1.0)
    }
    
    static var applicationPrimaryColor: UIColor {
        if #available(iOS 11.0, *) {
            return UIColor(named: "Application Orange") ?? #colorLiteral(red: 1, green: 0.4352941176, blue: 0, alpha: 1)
        } else {  return #colorLiteral(red: 1, green: 0.4352941176, blue: 0, alpha: 1)  }
    }
    
    static var applicationSecondaryColor: UIColor { #colorLiteral(red: 1, green: 0.6261816327, blue: 0, alpha: 1) }
    
    static func applicationGradient(with size: CGSize, direction: UIColor.Gradient.Direction = .vertical) -> UIColor {
        let colors = [applicationSecondaryColor, applicationPrimaryColor]
        let frame: CGRect = .init(origin: .zero, size: size)
        return colors.gradient(with: frame, direction: direction) ?? colors.first!
    }
    
}

// MARK: - Array
extension Array where Element: UIColor {
    func gradient(with frame: CGRect, direction: UIColor.Gradient.Direction) -> UIColor? {
        // create the background layer that will hold the gradient
        let backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.frame = frame
        // we create an array of CG colors from out UIColor array
        let cgColors = map { $0.cgColor }
        backgroundGradientLayer.colors = cgColors
        
        backgroundGradientLayer.startPoint = direction == .horizontal ? CGPoint(x: 0, y: 0.5) : CGPoint(x: 0.5, y: 0)
        backgroundGradientLayer.endPoint   = direction == .horizontal ? CGPoint(x: 1, y: 0.5) : CGPoint(x: 0.5, y: 1)
        
        UIGraphicsBeginImageContext(backgroundGradientLayer.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        backgroundGradientLayer.render(in: context)
        let backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard backgroundColorImage != nil else { return nil }
        
        return UIColor(patternImage: backgroundColorImage!)
    }
}

// MARK: - Dictionary
extension Dictionary {
    /// Overloading += for adding two dictionaries
    static func += (lhs: inout [Key: Value], rhs: [Key: Value]) { rhs.forEach({ lhs[$0] = $1}) }
    
    static func + (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
        var combined = lhs
        combined += rhs
        return combined
    }
}

protocol CBackgroundTextSettable {
    var customTag: Int { get }
    var backgroundView: UIView? { get set }
    var backgroundText: String? { get set }
}

extension CBackgroundTextSettable {
    var customTag: Int { return 7766 }
}

extension CBackgroundTextSettable where Self: UIView {
    
    var backgroundText: String? {
        get { return (viewWithTag(customTag) as? UILabel)?.text }
        
        set {
            guard newValue != nil else {
                backgroundView = nil
                return
            }
            
            if let existingLabel = viewWithTag(customTag) as? UILabel {
                existingLabel.text = newValue
                return
            }
            
            let label = UILabel(frame: bounds)
//            label.center = center
//            label.center.y *= 0.8//label.center.y * 0.8
//            label.frame.size.height = 100 // reducing height to 80%, to raise the label from center.
            label.font = UIFont.heading.withSize(20)
            label.backgroundColor = .clear
            label.textColor = .lightGray
            label.lineBreakMode = .byWordWrapping
            label.textAlignment = .center
            label.numberOfLines = 0
            label.tag = customTag
            label.text = newValue
            backgroundView = label
        }
    }
}

extension UITableView: CBackgroundTextSettable {}

extension UICollectionView: CBackgroundTextSettable {}

// MARK: - URL
extension URL {
    /// This will open a URL if possible.
    @discardableResult func open() -> Bool {
        guard UIApplication.shared.canOpenURL(self) else { return false }
        if #available(iOS 10, *) { UIApplication.shared.open(self)
        } else { UIApplication.shared.openURL(self) }
        return true
    }
}

// MARK: - UINavigationBar
extension UINavigationBar {
    /// Changes the navigation bar to transparent,
    var isTransparent: Bool {
        get { return self.isTranslucent }
        set {
            
            self.setBackgroundImage(newValue ? UIImage() : nil, for: .default)
            self.shadowImage = newValue ? UIImage() : nil
            self.isTranslucent = newValue
        }
    }
}

// MARK: - UIImage
extension UIImage {
    
    /// Creates and returns a UIImage.
    /// - Parameters:
    ///     - color: Color of the expected image.
    static func with(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    /// Masks a UIImage with color.
    /// - Parameters:
    ///     - color: Color to mask on to the image.
    func withMask(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil,
                                width: Int(width), height: Int(height),
                                bitsPerComponent: 8,
                                bytesPerRow: 0,
                                space: colorSpace,
                                bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() { return UIImage(cgImage: cgImage)
        } else { return nil }
    }
}

// MARK: - UIImageView
extension UIImageView {
    
    var maskColor: UIColor {
        get { return tintColor }
        set { image = image?.withMask(color: newValue) }
    }
    
    /// This will download the image in background and will update the imageView once completed. No caching.
    /// - Parameters:
    ///     - url: Remote URL of the image to download display.
    func setImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async { self.image = image }
        }.resume()
    }
}

// MARK: - Date
extension Date {
    static var now: Date { return Date() }
}

// MARK: - UIViewController
extension UIViewController {
    
    /// Returns top most viewController visible to user, in the hierarchy.
    static var top: UIViewController? {
        guard   let window = UIApplication.shared.keyWindow,
            let rootViewController = window.rootViewController else {
                return nil
        }
        
        var topController = rootViewController
        
        topController = (topController as? UINavigationController)?.topViewController ?? topController
        topController = (topController as? UITabBarController)?.selectedViewController ?? topController
        
        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }
        
        topController = (topController as? UINavigationController)?.topViewController ?? topController
        topController = (topController as? UITabBarController)?.selectedViewController ?? topController
        
        return topController
    }
    
    @discardableResult func alert(with message: String) -> UIAlertController {
        
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let autoDismiss = { (interval: TimeInterval) in
            executeInMainThread(interval) { alert.dismiss(animated: true) }
        }
        executeInMainThread { self.present(alert, animated: true) { autoDismiss(2) } }
        return alert
    }
    
    @discardableResult func alert(with title: String = "",
                                  message: String = "",
                                  primaryActionTitle: String = "OK",
                                  primaryAction: (() -> Void)? = nil,
                                  secondaryActionTitle: String = "Cancel",
                                  secondaryAction: (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: secondaryActionTitle, style: .default, handler: { _ in secondaryAction?() }))
        alert.addAction(.init(title: primaryActionTitle, style: .default, handler: { _ in primaryAction?() }))
        alert.preferredAction = alert.actions.first!
        present(alert, animated: true)
        return alert
    }
}

extension UIScrollView {
    
    /// This is a conveniance function to observe the content size change in a scrollview(collectionView, tableView, textView)
    ///
    /// - Parameter handler: gets called every time there is an update in content size
    /// - Returns: KVO value. Observation is stopped this value is deinited.
    func onChangeContentSize(_ handler: @escaping ((CGSize) -> Void)) -> NSKeyValueObservation {
        return observe(\.contentSize, options: .new) { _, change in
            guard let contentSize = change.newValue else { return }
            handler(contentSize)
        }
    }
}

extension KeyedDecodingContainer {
    public func safeDecode<T>(_ type: T.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> T? where T: Decodable {
        return try? decodeIfPresent(type, forKey: key)
    }
    
    public func safeDecodeInt(forKey key: KeyedDecodingContainer<K>.Key) -> Int? {
        if let decoded = try? decodeIfPresent(Int.self, forKey: key) { return decoded
        } else if let decoded = try? decodeIfPresent(String.self, forKey: key) {
            if decoded.trimmed.isEmpty { return 0 }
            return Int(decoded)
        }
        return nil
    }
    
    public func safeDecodeInt(forKey key: KeyedDecodingContainer<K>.Key) -> Int {
        return safeDecodeInt(forKey: key) ?? 0
    }
    
    public func safeDecodeDouble(forKey key: KeyedDecodingContainer<K>.Key) -> Double? {
        if let decoded = try? decodeIfPresent(Double.self, forKey: key) { return decoded
        } else if let decoded = try? decodeIfPresent(String.self, forKey: key) {
            if decoded.trimmed.isEmpty { return 0 }
            return Double(decoded)
        }
        return nil
    }
    
    public func safeDecodeString(forKey key: KeyedDecodingContainer<K>.Key) -> String? {
        if let decoded = try? decodeIfPresent(String.self, forKey: key) { return decoded
        } else if let decoded = try? decodeIfPresent(Int.self, forKey: key) { return "\(decoded)"
        }
        return nil
    }
    
    public func safeDecodeString(forKey key: KeyedDecodingContainer<K>.Key) -> String {
        return safeDecodeString(forKey: key) ?? ""
    }
}

extension Bundle {
    var applicationName: String {
        return Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    }
    
    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
    
    var fullVersionNumber: String { return "\(versionNumber)(\(buildNumber))" }
}
