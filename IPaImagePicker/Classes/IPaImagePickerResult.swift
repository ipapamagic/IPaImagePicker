//
//  IPaImagePickerResult.swift
//  Pods
//
//  Created by IPa Chen on 2017/8/20.
//
//

import UIKit
import Photos
import IPaBlockOperation
@objc open class IPaImagePickerResult:NSObject {
    open var photoCount:Int {
        get {
            return photos.count
        }
    }
    var photos = [IPaImagePickerResultPhoto]()
    init(_ photos:[IPaImagePickerResultPhoto]) {
        self.photos = photos
    }
    open func requestAnyPhoto(_ block:@escaping (UIImage?) -> ())
    {
        guard let photo = photos.first else {
            block(nil)
            return
        }
        photo.requestPhoto(block)
    }
    open func enumeratePhotos(_ block:@escaping (UIImage,Int,UnsafeMutablePointer<ObjCBool>)->(),complete:(() -> ())? = nil)
    {
        var index = 0
        var stop:ObjCBool = false
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInteractive
        var lastOperation:IPaBlockOperation?
        for photo in photos {
            let operation = IPaBlockOperation(block: {
                complete in
                photo.requestPhoto({
                    image in
                    if let image = image {
                        block(image,index,&stop)
                    }
                    index += 1
                    if stop.boolValue {
                        operationQueue.cancelAllOperations()
                    }
                    complete()
                })
            })
            if let lastOperation = lastOperation {
                operation.addDependency(lastOperation)
            }
            operationQueue.addOperation(operation)
            lastOperation = operation
        }
        if let lastOperation = lastOperation {
            lastOperation.completionBlock = {
                DispatchQueue.main.async {
                    if let complete = complete {
                        complete()
                    }
                }
            }
        }
    }
}


public protocol IPaImagePickerResultPhoto {
    func requestPhoto(_ block:@escaping (UIImage?)->())
    
}
open class IPaImagePickerPathResultPhoto:IPaImagePickerResultPhoto
{
    var path:String = ""
    init(_ path:String) {
        self.path = path
    }
    open func requestPhoto(_ block: @escaping (UIImage?) -> ()) {
        block(UIImage(contentsOfFile: path))
    }
}

open class IPaImagePickerAssetResultPhoto:IPaImagePickerResultPhoto
{
    static let imageManager = PHImageManager()
    static var _imageOptions:PHImageRequestOptions?
    static var imageOptions:PHImageRequestOptions {
        get {
            if _imageOptions == nil {
                let options = PHImageRequestOptions()
                options.isNetworkAccessAllowed = true
                options.deliveryMode = .highQualityFormat
                
                _imageOptions = options
            }
            return _imageOptions!
        }
    }
    var asset:PHAsset
    init(_ asset:PHAsset) {
        self.asset = asset
    }
    
    open func requestPhoto(_ block: @escaping (UIImage?) -> ()) {
       let option = IPaImagePickerAssetResultPhoto.imageOptions
        option.progressHandler = {
            progress,error,stop,info in
            if error != nil {
                block(nil)
            }
        }
        IPaImagePickerAssetResultPhoto.imageManager.requestImageData(for: asset, options: IPaImagePickerAssetResultPhoto.imageOptions, resultHandler: {
            imageData,dataUTI,orientation,info in
            guard let imageData = imageData else {
                return
            }
            block(UIImage(data: imageData))
        })
    }

}
