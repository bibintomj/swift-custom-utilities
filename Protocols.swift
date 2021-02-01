//
//  Protocols.swift
//  MMNews
//
//  Created by Bibin on 27/03/2019.
//  Copyright © 2019 Hifx. All rights reserved.
//

import UIKit

/// A protocol to get reuseIdentifier.
protocol ReuseIdentifying {
    static var defaultReuseIdentifier: String { get }
}

extension ReuseIdentifying {
    static var defaultReuseIdentifier: String {
        return String(describing: Self.self)
    }
}

/// Confomed classed will get an easy instantiate function.
protocol NibLoadable: class {
    static var nibName: String { get }
    static func instantiate() -> Self
}

extension NibLoadable {
    static var nibName: String { return String(describing: self) }
    
    static func instantiate() -> Self {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! Self
    }
}

extension UICollectionView {
    
    func register<T: UICollectionViewCell>(_: T.Type) where T: ReuseIdentifying {
        register(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func register<T: UICollectionViewCell>(_: T.Type) where T: ReuseIdentifying, T: NibLoadable {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        
        register(nib, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func registerSupplementary<T: UICollectionReusableView>(view: T.Type,
                                                            for kind: String = UICollectionView.elementKindSectionHeader)
                                                            where T: ReuseIdentifying, T: NibLoadable {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: ReuseIdentifying {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        
        return cell
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(of kind: String = UICollectionView.elementKindSectionHeader,
                                                                       for indexPath: IndexPath) -> T where T: ReuseIdentifying {
        
        guard let reuseableView = dequeueReusableSupplementaryView(ofKind: kind,
                                                                   withReuseIdentifier: T.defaultReuseIdentifier,
                                                                   for: indexPath) as? T else {
            fatalError("Could not dequeue reusable with identifier: \(T.defaultReuseIdentifier)")
        }
        
        return reuseableView
    }
}

extension UITableView {
    func register<T: UITableViewCell>(_: T.Type) where T: ReuseIdentifying {
        register(T.self, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func register<T: UITableViewCell>(_: T.Type) where T: ReuseIdentifying, T: NibLoadable {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        
        register(nib, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func registerHeaderFooterView<T: UITableViewHeaderFooterView>(_: T.Type) where T: ReuseIdentifying, T: NibLoadable {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forHeaderFooterViewReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T where T: ReuseIdentifying {
        guard let cell = dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        return cell
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T where T: ReuseIdentifying {
        guard let headerView = dequeueReusableHeaderFooterView(withIdentifier: T.defaultReuseIdentifier) as? T else {
            fatalError("Could not dequeue HeaderFooterView with identifier: \(T.defaultReuseIdentifier)")
        }
        
        return headerView
    }
}

/// The motivation to create this protocol is to group the text property of UILabel, UITextField, UITextView
@objc protocol TextSettable {
    var text: String! { get set }
}

extension Array where Element: TextSettable {
    /// Clears the text of conformed types.
    func clear() { forEach { $0.text = nil } }
}

extension UILabel: TextSettable {}
extension UITextField: TextSettable {}
extension UITextView: TextSettable {}
extension UIButton: TextSettable {
    var text: String! {
        get { return currentTitle }
        set { setTitle(newValue, for: .normal) }
    }
}
