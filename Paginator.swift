//
//  Paginator.swift
//  MMNews
//
//  Created by Bibin on 07/03/2019.
//  Copyright © 2019 Hifx. All rights reserved.
//

import Foundation

struct Paginator {
    var currentPageNumber: Int      = 0
    var totalPageCount: Int         = 1
    var maxItemCountPerPage: Int    = 30
}

extension Paginator {
    var itemsPerPageQueryParams: [String: String] { return ["count": "\(maxItemCountPerPage)"] }
    var nextPageQueryParams: [String: String] { return ["page": "\(currentPageNumber + 1)"] }
    var loadingCompleted: Bool { return currentPageNumber >= totalPageCount }
}

extension Int {
    mutating func incrementOne() {
        self += 1
    }
}
