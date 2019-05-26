//
//  IPaImagePickerContentViewController.swift
//  IPaImagePickerContentViewController
//
//  Created by IPa Chen on 2016/1/10.
//  Copyright © 2016年 A Magic Studio. All rights reserved.
//

import UIKit
import Photos
import IPaDesignableUI
class IPaImagePickerContentViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,IPaImagePickerPreviewViewControllerDelegate {
    @IBOutlet weak var contentCollectionView: UICollectionView!
    var selectedIndexPaths = [IndexPath]()
    var source:IPaImagePickerSource {
        get {
            return .photoAlbum
        }
    }
    lazy var photoCellItemSize:CGSize = {
        return refreshPhotoCellItemSize()
    }()
    lazy var confirmBarButtonItem:UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(IPaImagePickerContentViewController.onConfirm(_:)))
        barButtonItem.isEnabled = false
        return barButtonItem
    }()
    var maxPhotoCount:Int {
        get {
            let imagePicker = navigationController as! IPaImagePickerController
            return imagePicker.maxPhotoCount ?? 0
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
         let nib = UINib(nibName: "IPaImagePickerCollectionViewCell", bundle: IPaImagePickerController.bundle)
        contentCollectionView.register(nib, forCellWithReuseIdentifier: "photoCell")
        // Do any additional setup after loading the view.
        confirmBarButtonItem.isEnabled = selectedIndexPaths.count > 0
        self.navigationItem.rightBarButtonItem = self.confirmBarButtonItem
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.photoCellItemSize = refreshPhotoCellItemSize()
        contentCollectionView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)  
        contentCollectionView.reloadData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func resultPhoto(at indexPath:IndexPath) -> IPaImagePickerResultPhoto {
        return IPaImagePickerPathResultPhoto("")
    }
    @IBAction func onConfirm(_ sender: Any) {
        let imagePicker = navigationController as! IPaImagePickerController
        let selectedPhoto:[IPaImagePickerResultPhoto] = selectedIndexPaths.map({
            indexPath in
            return resultPhoto(at: indexPath)
            
        })
        let result = IPaImagePickerResult(selectedPhoto)
        imagePicker.pickerDelegate.onImagePick(imagePicker,source: source,result: result)
        self.navigationController?.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func onCancel(_ sender: AnyObject) {
        self.navigationController?.dismiss(animated: true, completion: nil)
        
        
    }
    func refreshPhotoCellItemSize() -> CGSize {
        let width = floor((contentCollectionView.bounds.width - 20.0 ) / 3.0)
        return CGSize(width: width, height: width)
    }
  
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showPreview" {
            let viewController = segue.destination as! IPaImagePickerPreviewViewController
            viewController.delegate = self
            viewController.currentIndex = sender as! Int
            
            
        }
    }

    func onTapImage(at indexPath:IndexPath) {
        if let index = self.indexForSelectedImage(at: indexPath.item) {
            
            selectedIndexPaths.remove(at: index)
            contentCollectionView.reloadItems(at: selectedIndexPaths + [indexPath])
        }
        else {
            selectedIndexPaths.append(indexPath)
            contentCollectionView.reloadItems(at: [indexPath])
        }
        
        confirmBarButtonItem.isEnabled = selectedIndexPaths.count > 0
        self.navigationItem.rightBarButtonItem = self.confirmBarButtonItem
    }
    func numberOfItems() -> Int
    {
        return 0
    }
    func updateCell(_ cell:IPaImagePickerCollectionViewCell,indexPath:IndexPath) {
        
    }
    //MARK:UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return numberOfItems()
    }
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! IPaImagePickerCollectionViewCell
        
        self.updateCell(cell,indexPath:indexPath)
        cell.delegate = self
        if let index = indexForSelectedImage(at: indexPath.item) {
            cell.markerNumber = (index.advanced(by: 0) + 1)
        }
        else {
            cell.markerNumber = 0
        }

        return cell
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return photoCellItemSize
    }
    //MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    
        self.performSegue(withIdentifier: "showPreview", sender: indexPath.item)
    }

//need to be override ,can not implement in extension
//}
//extension IPaImagePickerContentViewController:
//{
    //MARK:IPaImagePickerPreviewViewControllerDelegate
    func onTapSelectImage(_ index: Int) {
        self.onTapImage(at: IndexPath(item:index,section:0))
    }
    
    func numberOfImages() -> Int {
        return collectionView(contentCollectionView, numberOfItemsInSection: 0)
    }
    func numberOfSelected() -> Int {
        return selectedIndexPaths.count
    }
    func requestImage(at index: Int, complete: @escaping (UIImage?) -> ()) {
        let imagePicker = self.navigationController as! IPaImagePickerController
        let identifier = self.imageIdentifier(for: index)
        if let image = imagePicker.pickerDelegate.onWillLoadImage?(imagePicker, source: source, identifier: identifier, loadImageHandler: {
            imageLoadComplete in
            self.loadImage(at: index, complete: imageLoadComplete)
            
            }) {
            complete(image)
        }
        else {
            self.loadImage(at: index, complete: {
                image in
                complete(image)
            })
        }
        
    }
    func imageIdentifier(for index:Int) -> String {
        return "\(index)"
    }
    func loadImage(at index: Int, complete: @escaping (UIImage?) -> ()) {
    }
    func indexForSelectedImage(at index: Int) -> Int? {
        return selectedIndexPaths.firstIndex(of: IndexPath(item:index,section:0))
    }
    func onConfirmPick() {
        self.onConfirm(self)
    }
    
    func removeEditedImage(at index: Int) {
        
    }
}
extension IPaImagePickerContentViewController:IPaImagePickerCollectionViewCellDelegate
{
    func onTapMarkerButton(_ cell: IPaImagePickerCollectionViewCell) {
        guard let indexPath = contentCollectionView.indexPath(for: cell) else {
            return
        }
        self.onTapImage(at: indexPath)
    }
}

