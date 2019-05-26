//
//  IPaImagePickerController.swift
//  IPaImagePickerController
//
//  Created by IPa Chen on 2016/1/11.
//  Copyright © 2016年 A Magic Studio. All rights reserved.
//

import UIKit
import Photos
@objc public enum IPaImagePickerSource:Int {
    case photoAlbum
    case camera
}

@objc public protocol IPaImagePickerDelegate
{
    func onImagePick(_ sender:IPaImagePickerController,source:IPaImagePickerSource,result:IPaImagePickerResult?)
    
    //return new image to replace original , call loadImageHandler to load image
    @objc optional func onWillLoadImage(_ sender:IPaImagePickerController,source:IPaImagePickerSource,identifier:String,loadImageHandler:(@escaping (UIImage?)->())->()) -> UIImage?
    
}
@objc public enum IPaImagePickerLocalizedKey:Int {
    case cancel
    case photoLibrary
    case camera
}
open class IPaImagePickerController: UINavigationController {
    var pickerDelegate:IPaImagePickerDelegate!
    var maxPhotoCount:Int?
    
    public static var localizationKeyMap:[IPaImagePickerLocalizedKey:String] = [.cancel:"Cancel",.photoLibrary:"Photo Library",.camera:"Camera"]
    lazy var tempPhotoPath:String = {
        guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            return ""
        }
        return (path as NSString).appendingPathComponent("IPaImagePickerTemp")
    }()
    static var bundle:Bundle {
        get {
            let bundle = Bundle(for: IPaImagePickerController.self)
            let bundleUrl = bundle.url(forResource: "IPaImagePicker", withExtension: "bundle")!
            return Bundle(url: bundleUrl)!
        }
    }
    static func createImagePicker(_ delegate:IPaImagePickerDelegate) -> IPaImagePickerController {
        
        let storyboard = UIStoryboard(name: "IPaImagePicker", bundle: IPaImagePickerController.bundle)
        let imagePicker = storyboard.instantiateInitialViewController() as! IPaImagePickerController
        imagePicker.pickerDelegate = delegate
        return imagePicker
    }
    static func createCamera(_ delegate:IPaImagePickerDelegate) -> IPaImagePickerController {
        let bundle = Bundle(for: IPaImagePickerController.self)
        let bundleUrl = bundle.url(forResource: "IPaImagePicker", withExtension: "bundle")!
        let resourceBundle = Bundle(url: bundleUrl)
        let storyboard = UIStoryboard(name: "IPaImagePicker", bundle: resourceBundle)
        let imagePicker = storyboard.instantiateViewController(withIdentifier: "camera") as! IPaImagePickerController
        imagePicker.pickerDelegate = delegate
        return imagePicker
    }
    
    deinit {
        do {
            try FileManager.default.removeItem(atPath: self.tempPhotoPath)
        }
        catch {
            
        }
    }
}
extension IPaImagePickerController
{
    public static func presentImagePicker(from viewController:UIViewController, title:String?,message:String?,maxPhotoCount:Int?,delegate: IPaImagePickerDelegate) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: NSLocalizedString(localizationKeyMap[.cancel]!, comment: "Cancel"), style: .cancel, handler: {
            action in
        })
        alertController.addAction(cancelAction)
        let pictureAction = UIAlertAction(title: NSLocalizedString(localizationKeyMap[.photoLibrary]!, comment: "Photo Library"), style: .default, handler: {
            action in
            let imagePicker = createImagePicker(delegate)
            imagePicker.maxPhotoCount = maxPhotoCount
            viewController.present(imagePicker, animated: true, completion: nil)
        })
        alertController.addAction(pictureAction)
        let cameraAction = UIAlertAction(title: NSLocalizedString(localizationKeyMap[.camera]!, comment: "Camera"), style: .default, handler: {
            action in
            let imagePicker = createCamera(delegate)
            imagePicker.maxPhotoCount = maxPhotoCount
            viewController.present(imagePicker, animated: true, completion: nil)
        })
        alertController.addAction(cameraAction)
        
        viewController.present(alertController, animated: true, completion: nil)
        
        
    }
    public static func presentImagePicker(from viewController:UIViewController, title:String?,message:String?,delegate: IPaImagePickerDelegate) {
        presentImagePicker(from: viewController,title: title, message: message,maxPhotoCount:nil,delegate:delegate)
    }
}
