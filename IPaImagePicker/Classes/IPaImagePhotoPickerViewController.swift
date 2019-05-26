//
//  IPaImagePhotoPickerViewController.swift
//  Pods
//
//  Created by IPa Chen on 2017/8/18.
//
//

import UIKit
import IPaImageTool
class IPaImagePhotoPickerViewController: IPaImagePickerContentViewController {
    var photoCount = 0
    override var source:IPaImagePickerSource {
        get {
            return .camera
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        refreshTitle()
    }
    func refreshTitle() {
        self.navigationItem.title = (maxPhotoCount > 0) ? "\(self.selectedIndexPaths.count)/\(maxPhotoCount)": ""
    }
    override func resultPhoto(at indexPath:IndexPath) -> IPaImagePickerResultPhoto {
        let imagePicker = navigationController as! IPaImagePickerController

        return IPaImagePickerPathResultPhoto((imagePicker.tempPhotoPath as NSString).appendingPathComponent("\(indexPath.item)"))
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func loadImage(at index: Int, complete: @escaping (UIImage?) -> ()) {
        let imagePicker = navigationController as! IPaImagePickerController
        let path = imagePicker.tempPhotoPath
        let filePath = (path as NSString).appendingPathComponent("\(index)")
        let image = UIImage(contentsOfFile: filePath)
        complete(image)
    }
    
    //MARK: IPaImagePickerContent override
    override func numberOfItems() -> Int {
        return photoCount
    }
    override func updateCell(_ cell:IPaImagePickerCollectionViewCell,indexPath:IndexPath) {
        

        let imagePicker = navigationController as! IPaImagePickerController
        let path = imagePicker.tempPhotoPath
        let imageView = cell.photoImageView!
        let thumbnailFilePath = (path as NSString).appendingPathComponent("\(indexPath.item)_\(imageView.bounds.size.width)_\(imageView.bounds.size.height)")
        if let image = UIImage(contentsOfFile: thumbnailFilePath) {
            imageView.image = image
        }
        else {
            let filePath = (path as NSString).appendingPathComponent("\(indexPath.item)")
            if let image = UIImage(contentsOfFile: filePath) {
                
                let thumbnailImage = image.image(fitSize:imageView.bounds.size)
                imageView.image = thumbnailImage
                if let data = thumbnailImage.jpegData(compressionQuality: 1)  {
                    do {
                        let url = URL(fileURLWithPath: thumbnailFilePath)
                        try data.write(to: url)
                        
                    }
                    catch {
                        
                    }
                }
            }
        }
    
    }
}
