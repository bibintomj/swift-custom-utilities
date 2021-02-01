//
//  MediaUploadPresenter.swift
//  Quickerala
//
//  Created by Bibin on 23/08/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import Foundation

protocol MediaUploadView: BaseView {
    func uploadFinished(for file: Uploadable, at indexPath: IndexPath)
}

final class MediaUploadPresenter: BasePresenter {
    weak var view: MediaUploadView!
    
    var files: [File] { FileUploadQueue.items }

    func onFinishUpload(item: Uploadable) {
        guard let file = item as? File else { return }
        guard let index: Int = self.files.firstIndex(of: file) else { return }
        FileUploadQueue.remove(file)
        self.view.uploadFinished(for: item, at: .init(row: index, section: 0))
    }
    
    func removeNonUploadingFiles() {
        let nonUploadingFiles: [File] = FileUploadQueue.items.compactMap {
            if case .uploading = $0.status { return nil
            } else { return $0 }
        }
        nonUploadingFiles.forEach { FileUploadQueue.remove($0) }
    }
}
