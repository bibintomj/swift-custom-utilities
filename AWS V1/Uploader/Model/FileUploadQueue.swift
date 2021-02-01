//
//  MediaUploader.swift
//  Quickerala
//
//  Created by Bibin on 19/08/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import Foundation

/// Holds the files to upload.
final class FileUploadQueue {
    private static var _items: [File] = []
    static var items: [File] {
        return _items
    }
}

extension FileUploadQueue {
    
    /// Adds a file to the queue
    ///
    /// - Parameter items: Collection of files to add to queue.
    static func add(_ items: [File]) { _items += items }
    
    /// Removes a particular file from queue.
    ///
    /// - Parameter item: Item to remove from the queue. If multiple present, all will be removed.
    static func remove(_ item: File) {
        guard let index = _items.firstIndex(where: { $0.type == item.type && $0.localUrl == item.localUrl }) else {
            return
        }
        _items.remove(at: index)
    }
}
