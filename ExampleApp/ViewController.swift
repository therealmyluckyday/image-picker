//
//  ViewController.swift
//  ExampleApp
//
//  Created by Peter Stajger on 04/09/2017.
//  Copyright © 2017 Inloop. All rights reserved.
//

import UIKit
import ImagePicker
import Photos


///
/// This is an example view controller that shows how Image Picker can be used
///
class ViewController: UITableViewController {

    private var allowsFirstResponser = false
    private var currentInputView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.window?.tintColor = UIColor.green
        
        //configure global appearance. If you wish to specify appearance per
        //instance simple set appearance() on the instance itself. It will
        //have a precedense over global appearance
        ImagePickerController.appearance().backgroundColor = UIColor.black
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.keyboardDismissMode = .onDrag
    }

    @objc func presentPickerModally() {
        print("presenting modally")
        
        let vc = ImagePickerController()
        
        let actionNib = UINib(nibName: "IconWithTextCell", bundle: nil)
        vc.cellRegistrator.register(nib: actionNib, forActionItemAt: 0)
        vc.cellRegistrator.register(nib: actionNib, forActionItemAt: 1)
        
        let imageNib = UINib(nibName: "ImageCell", bundle: nil)
        vc.cellRegistrator.registerNibForAssetItems(imageNib)
        
        let videoNib = UINib(nibName: "VideoCell", bundle: nil)
        vc.cellRegistrator.register(nib: videoNib, forAssetItemOf: .video)
        
        vc.layoutConfiguration.scrollDirection = .vertical
        vc.layoutConfiguration.showsCameraItem = false
        vc.layoutConfiguration.numberOfAssetItemsInRow = 3
        
        presentPickerModally(vc)
    }
    
    @objc func presentPickerModallyCustomFetch() {
        print("presenting modally")
        
        let vc = ImagePickerController()
        vc.layoutConfiguration.scrollDirection = .vertical
        vc.layoutConfiguration.showsCameraItem = false
        vc.layoutConfiguration.showsFirstActionItem = false
        vc.layoutConfiguration.showsSecondActionItem = false
        vc.cellRegistrator.registerNibForAssetItems(UINib(nibName: "ImageCell", bundle: nil))
        vc.assetsFetchResultBlock = {
            guard let collection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: nil).firstObject else {
                //you can return nil if you did not find desired fetch result, default fetch result will be used.
                return nil
            }
            return PHAsset.fetchAssets(in: collection, options: nil)
        }
        
        presentPickerModally(vc)
    }
    
    @objc func presentPickerAsInputViewPhotosAs1Col() {
        print("presenting as input view")
        
        let vc = ImagePickerController()
        vc.cellRegistrator.registerNibForActionItems(UINib(nibName: "IconWithTextCell", bundle: nil))
        vc.cellRegistrator.registerNibForAssetItems(UINib(nibName: "ImageCell", bundle: nil))
        vc.layoutConfiguration.numberOfAssetItemsInRow = 1
        
        presentPickerAsInputView(vc)
    }
    
    @objc func presentPickerAsInputView() {
        print("presenting as input view")
        let vc = ImagePickerController()
        presentPickerAsInputView(vc)
    }
    
    @objc func presentPickerAsInputViewPhotosConfiguration() {
        
        let vc = ImagePickerController()
        vc.cellRegistrator.registerNibForActionItems(UINib(nibName: "IconWithTextCell", bundle: nil))
        vc.cellRegistrator.registerNibForCameraItem(UINib(nibName: "CameraCell", bundle: nil))
        vc.cellRegistrator.registerNibForAssetItems(UINib(nibName: "ImageCell", bundle: nil))
        vc.captureSettings.cameraMode = .photo
        
        presentPickerAsInputView(vc)
    }
    
    @objc func presentPickerAsInputViewLivePhotosConfiguration() {
        
        let vc = ImagePickerController()
        vc.cellRegistrator.registerNibForActionItems(UINib(nibName: "IconWithTextCell", bundle: nil))
        vc.cellRegistrator.registerNibForCameraItem(UINib(nibName: "LivePhotoCameraCell", bundle: nil))
        vc.cellRegistrator.register(nib: UINib(nibName: "VideoCell", bundle: nil), forAssetItemOf: .video)
        vc.cellRegistrator.registerNibForAssetItems(UINib(nibName: "ImageCell", bundle: nil))
        vc.captureSettings.cameraMode = .photoAndLivePhoto
        vc.captureSettings.savesCapturedAssetToPhotoLibrary = true
        
        presentPickerAsInputView(vc)
    }
    
    private func presentPickerAsInputView(_ vc: ImagePickerController) {
        
        vc.delegate = self
        vc.dataSource = self
        
        //if you want to present view as input view, you have to set flexible height
        //to adopt natural keyboard height or just set an layout constraint height
        //for specific height.
        vc.view.autoresizingMask = .flexibleHeight
        currentInputView = vc.view
        
        allowsFirstResponser = true
        becomeFirstResponder()
    }
    
    private func presentPickerModally(_ vc: ImagePickerController) {
        
        vc.delegate = self
        vc.dataSource = self
        
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Dismiss", style: .done, target: self, action: #selector(dismissPresentedImagePicker(sender:)))
        let nc = UINavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    @objc dynamic func dismissPresentedImagePicker(sender: UIBarButtonItem) {
        navigationController?.visibleViewController?.dismiss(animated: true, completion: nil)
    }
    
    override var canBecomeFirstResponder: Bool {
        return allowsFirstResponser
    }
    
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result == true {
            currentInputView = nil
        }
        return result
    }
    
    override var inputView: UIView? {
        return currentInputView
    }
    
}

extension ViewController : ImagePickerControllerDelegate {
    
    public func imagePicker(controller: ImagePickerController, didSelectActionItemAt index: Int) {
        print("did select action \(index)")
    }
    
    public func imagePicker(controller: ImagePickerController, didFinishPicking asset: PHAsset) {
        print("selected assets: \(controller.selectedAssets.count)")
    }
    
    public func imagePicker(controller: ImagePickerController, didTake image: UIImage) {
        print("did take image \(image.size)")
    }
    
    func imagePicker(controller: ImagePickerController, willDisplayActionItem cell: UICollectionViewCell, at index: Int) {
        switch cell {
        case let iconWithTextCell as IconWithTextCell:
            switch index {
            case 0:
                iconWithTextCell.titleLabel.text = "Camera"
                iconWithTextCell.imageView.image = #imageLiteral(resourceName: "ic-camera")
            case 1:
                iconWithTextCell.titleLabel.text = "Photo Library"
                iconWithTextCell.imageView.image = #imageLiteral(resourceName: "ic-photo")
            default: break
            }
        default:
            break
        }
    }
    
    func imagePicker(controller: ImagePickerController, willDisplayAssetItem cell: ImagePickerAssetCell, asset: PHAsset) {
        switch cell {
        
        case let videoCell as VideoCell:
            videoCell.label.text = ViewController.durationFormatter.string(from: asset.duration)
        
        case let imageCell as ImageCell:
            if asset.mediaSubtypes.contains(.photoLive) {
                imageCell.subtypeImageView.image = #imageLiteral(resourceName: "icon-live")
            }
            else if asset.mediaSubtypes.contains(.photoPanorama) {
                imageCell.subtypeImageView.image = #imageLiteral(resourceName: "icon-pano")
            }
            else if #available(iOS 10.2, *), asset.mediaSubtypes.contains(.photoDepthEffect) {
                imageCell.subtypeImageView.image = #imageLiteral(resourceName: "icon-depth")
            }
        default:
            break
        }
    }
    
    static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
}

extension ViewController: ImagePickerControllerDataSource {
    
    func imagePicker(controller: ImagePickerController, viewForAuthorizationStatus status: PHAuthorizationStatus) -> UIView {
        let infoLabel = UILabel(frame: .zero)
        infoLabel.backgroundColor = UIColor.green
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
        switch status {
        case .restricted:
            infoLabel.text = "Access is restricted\n\nPlease open Settings app and update privacy settings."
        case .denied:
            infoLabel.text = "Access is denied by user\n\nPlease open Settings app and update privacy settings."
        default:
            break
        }
        return infoLabel
    }
    
}

let data = [
    [
        ("Modally - no camera", #selector(ViewController.presentPickerModally)),
        ("Modally - only photos", #selector(ViewController.presentPickerModallyCustomFetch))],
    [
        ("Input view - default", #selector(ViewController.presentPickerAsInputView)),
        ("Input view - 1 photo cols", #selector(ViewController.presentPickerAsInputViewPhotosAs1Col)),
        ("Input view - photos configuration", #selector(ViewController.presentPickerAsInputViewPhotosConfiguration)),
        ("Input view - live photos configuration", #selector(ViewController.presentPickerAsInputViewLivePhotosConfiguration))]
]
let selectors = [#selector(ViewController.presentPickerAsInputView)]

extension ViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.text = data[indexPath.section][indexPath.row].0
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        perform(data[indexPath.section][indexPath.row].1)
    }
    
}
