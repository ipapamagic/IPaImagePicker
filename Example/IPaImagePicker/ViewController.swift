//
//  ViewController.swift
//  IPaImagePicker
//
//  Created by ipapamagic@gmail.com on 05/26/2019.
//  Copyright (c) 2019 ipapamagic@gmail.com. All rights reserved.
//

import UIKit
import IPaImagePicker
class ViewController: UIViewController {

    @IBOutlet weak var resultImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        IPaImagePickerController.localizationKeyMap[.camera] = "相機camera"
        IPaImagePickerController.localizationKeyMap[.photoLibrary] = "照片庫"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onPickImage(_ sender: Any) {
        IPaImagePickerController.presentImagePicker(from: self, title: "IPaImagePicker", message: "Pick a image", delegate: self)
    }
}

extension ViewController:IPaImagePickerDelegate
{
    func onImagePick(_ sender: IPaImagePickerController, source: IPaImagePickerSource, result: IPaImagePickerResult?) {
        if let result = result {
            var images = [UIImage]()
            self.resultImageView.animationDuration = 2
            result.enumeratePhotos({ (image, index, stop) in
                if index == 0 {
                    self.resultImageView.image = image
                }
                images.append(image)
            }, complete: {
                self.resultImageView.animationImages = images
                self.resultImageView.startAnimating()
            })
           
            
            
        }
    }
}
