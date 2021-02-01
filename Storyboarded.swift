//
//  Storyboarded.swift
//  MVPDemo2
//
//  Created by Bibin on 19/02/19.
//  Copyright © 2019 Bibin. All rights reserved.
//

import UIKit

enum Storyboard {
    case splash,
    home,
    business,
    details,
    login,
    category,
    payment,
    filter,
    postBusiness,
    search
    
    var instance: UIStoryboard {
        guard self != .postBusiness else { return .init(name: String(describing: self).capitalizedFirst, bundle: .main) }
        return .init(name: String(describing: self).capitalized, bundle: .main)
    }
}

protocol Storyboarded {
    static var storyboard: Storyboard { get }
    static func instantiate() -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate() -> Self {
        let identifier = String(describing: self)
        return storyboard.instance.instantiateViewController(withIdentifier: identifier) as! Self
    }
}
