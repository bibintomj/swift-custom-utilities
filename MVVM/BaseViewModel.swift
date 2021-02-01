//
//  BaseViewModel.swift
//  QKDoc
//
//  Created by Lenin Niclavos on 31/03/20.
//  Copyright © 2020 hifx. All rights reserved.
//

import UIKit

/// A Root ViewModel encapsulating basic viewmodel properties.
/// ViewModels as adviced to implement this protocol to maintain.
protocol BaseViewModel: class {
    /// A datasource type of property that will be used to create ViewModel.
    associatedtype DataSource
    /// A datasource property that will be used to create ViewModel.
    var dataSource: DataSource? { get set }
    /// A common initializer for ViewModels.
    /// - Parameter dataSource: A property that will be used to initialize the ViewModel.
    init(with dataSource: DataSource?)
}

protocol ViewModelInitializable {
    /// Type of ViewModel that will be used to create View.
    associatedtype ViewModel: BaseViewModel
    /// ViewModel property for view.
    var viewModel: ViewModel? { get set }
    /// A Common initializer for View using ViewModel
    /// - Parameter viewModel: ViewModel Object to attach to the view.
    init(with viewModel: ViewModel)
    /// A Common initializer for View using a property that will create the ViewModel.
    /// - Parameter dataSource: A datasource property that will be used to create ViewModel, which will be in turn used to create the View.
    init(with dataSource: ViewModel.DataSource)
    /// Use this function to bind the View to ViewModel.
    func bind(to viewModel: ViewModel)
}

extension ViewModelInitializable {
    /// Default implemention to make the function optional.
    func bind(to viewModel: ViewModel) {}
}

/// Default imnplementation in assiciation with Nibloadable protocol.
extension ViewModelInitializable where Self: NibLoadable {
    init(with viewModel: ViewModel) {
        self = .instantiate()
        self.viewModel = viewModel
        self.bind(to: viewModel)
    }
    
    init(with dataSource: ViewModel.DataSource) {
        self = .instantiate()
        self.viewModel = .init(with: dataSource)
        self.bind(to: viewModel!)
    }
}

/// Default imnplementation in association with Storyboarded protocol.
extension ViewModelInitializable where Self: Storyboarded {
    init(with viewModel: ViewModel) {
        self = .instantiate()
        self.viewModel = viewModel
        self.bind(to: viewModel)
    }
    
    init(with dataSource: ViewModel.DataSource) {
        self = .instantiate()
        self.viewModel = .init(with: dataSource)
        self.bind(to: viewModel!)
    }
}
