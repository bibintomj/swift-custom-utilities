//
//  MediaUploadViewController.swift
//  Quickerala
//
//  Created by Bibin on 19/08/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import UIKit

final class MediaUploadViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    private var uploadAllBarButton: UIBarButtonItem = .init(title: "Upload All",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(handlerUploadAll(_:)))
    
    var presenter: MediaUploadPresenter! {
        didSet { presenter?.attach(view: self) }
    }
    
    override func initialSetup() {
        title = "Upload"
        self.navigationController?.presentationController?.delegate = self
        setUpTableView()
    }
    
    override func configureUI() {
        self.tableView.backgroundText = self.presenter.files.isEmpty ? "Nothing to upload" : nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.handlerUploadAll(uploadAllBarButton)
    }
    
    override var leftBarButtons: [UIBarButtonItem] {
        return [.init(barButtonSystemItem: .stop, target: self, action: #selector(dismiss(_:)))]
    }
    
    override var rightBarButtons: [UIBarButtonItem] {
        return [uploadAllBarButton]
    }
}

private extension MediaUploadViewController {
    func setUpTableView() {
        self.tableView.register(MediaUploadTableViewCell.self)
        self.tableView.tableFooterView = .init()
        self.tableView.backgroundText = presenter.files.isEmpty ? "Nothing to upload" : nil
        self.uploadAllBarButton.isEnabled = !presenter.files.isEmpty
    }
    
    @objc func dismiss(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
        self.presenter.removeNonUploadingFiles()
    }
    
    @objc func handlerUploadAll(_ sender: UIBarButtonItem) {
        sender.isEnabled = false
        presenter.files.upload(in: .parallel)
    }
}

extension MediaUploadViewController: MediaUploadView {
    func uploadFinished(for file: Uploadable, at indexPath: IndexPath) {
        executeInMainThread(1) {
            self.tableView?.deleteRows(at: [indexPath], with: .top)
            self.tableView.backgroundText = self.presenter.files.isEmpty ? "All uploads are finished." : nil
            self.uploadAllBarButton.isEnabled = !self.presenter.files.isEmpty
            if self.presenter.files.isEmpty {
                executeInMainThread(1.5) { self.dismiss() }
            }
        }
    }
}

extension MediaUploadViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.presenter.removeNonUploadingFiles()
    }
}

extension MediaUploadViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MediaUploadTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.attach(uploadItem: presenter.files[indexPath.row])
        cell.deleteHandler = self.presenter.onFinishUpload(item:)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.files[indexPath.row].startUpload { status in
            Log.debug(">>>>> COMPLETED ", status)
        }
    }
}

extension MediaUploadViewController: Storyboarded {
    static var storyboard: Storyboard { return .business }
}
