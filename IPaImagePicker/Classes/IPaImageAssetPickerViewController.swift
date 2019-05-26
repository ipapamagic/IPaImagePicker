//
//  IPaImageAssetPickerViewController.swift
//  Pods
//
//  Created by IPa Chen on 2017/8/18.
//
//

import UIKit
import Photos
import IPaImageTool
import IPaDesignableUI
class IPaImageAssetPickerViewController: IPaImagePickerContentViewController {
    static var photoSortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false),NSSortDescriptor(key: "modificationDate", ascending: false)]
    lazy var allPhotos:PHFetchResult<PHAsset> = {
        let allPhotosOptions = PHFetchOptions()
//        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false),NSSortDescriptor(key: "creationDate", ascending: false)]
        allPhotosOptions.sortDescriptors = IPaImageAssetPickerViewController.photoSortDescriptors
//        allPhotosOptions.includeAllBurstAssets = true
        
        return PHAsset.fetchAssets(with: .image, options: allPhotosOptions)
        
    }()
    var previousPreheatRect = CGRect.zero
    lazy var fetchResult:PHFetchResult<PHAsset> = self.allPhotos
    var selectedAlbum:PHCollection?
    lazy var photoLibrary = PHPhotoLibrary.shared()
    lazy var imageManager = PHCachingImageManager()
    lazy var previewImageManager = PHImageManager()
    
    lazy var titleButton:IPaImageRightStyleButton = {
        
        var titleTextColor:UIColor = .black
        if let titleTextAttributes = self.navigationController!.navigationBar.titleTextAttributes,let attributesTitleColor = titleTextAttributes[NSAttributedString.Key.foregroundColor] as? UIColor {
            titleTextColor = attributesTitleColor
        }
        else if let titleTextAttributes = UINavigationBar.appearance().titleTextAttributes,let attributesTitleColor = titleTextAttributes[NSAttributedString.Key.foregroundColor] as? UIColor {
            titleTextColor = attributesTitleColor
        }
        
        let button = IPaImageRightStyleButton(type: .custom)
        button.centerSpace = 4
        let image = IPaImagePickerDrawKit.imageOfDownArrow(arrowColor: titleTextColor)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(IPaImageAssetPickerViewController.onPickAlbum(_:)), for: .touchUpInside)
        button.bounds = CGRect(x: 0, y: 0, width: 320, height: 44)
        button.setTitle("所有照片", for: .normal)
        
        button.setTitleColor(titleTextColor , for: .normal)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = titleButton
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(IPaImagePickerContentViewController.onCancel(_:)))
        
        // Store the PHFetchResult objects and localized titles for each section.
        
       
        photoLibrary.register(self)
        // Do any additional setup after loading the view.
    }
    deinit{
        photoLibrary.unregisterChangeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func onPickAlbum(_ sender:Any) {
        self.performSegue(withIdentifier: "pickAlbum", sender: nil)
    }
    override func resultPhoto(at indexPath:IndexPath) -> IPaImagePickerResultPhoto {
        
        return IPaImagePickerAssetResultPhoto(fetchResult[indexPath.item])
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "pickAlbum" {
            let navigationController = segue.destination as! UINavigationController
            let viewController = navigationController.viewControllers.first as! IPaAlbumPickerViewController
            viewController.delegate = self
            viewController.selectedAlbum = selectedAlbum
        }
    }
    override func imageIdentifier(for index:Int) -> String {
        let asset = fetchResult[index]
        return asset.localIdentifier
    }
    override func loadImage(at index: Int, complete: @escaping (UIImage?) -> ()) {
        let asset = fetchResult[index]
        
        let options = PHImageRequestOptions()
        
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .opportunistic
        
        previewImageManager.requestImageData(for: asset, options: options, resultHandler: {
            imageData,dataUTI,orientation,info in
            if let imageData = imageData,let image = UIImage(data: imageData) {
                complete(image)
            }
            else {
                complete(nil)
            }
            
        })
    }
    

    //MARK: IPaImagePickerContent override
    override func numberOfItems() -> Int {
        return fetchResult.count
    }
    override func updateCell(_ cell:IPaImagePickerCollectionViewCell,indexPath:IndexPath) {
        let asset = fetchResult[indexPath.item]
        cell.identifier = asset
    
        weak var weakCell = cell
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .opportunistic

        imageManager.requestImage(for: asset, targetSize: photoCellItemSize, contentMode: .aspectFill, options: options, resultHandler: {
            resultImage,info in
            
            guard let targetCell = (self.contentCollectionView.cellForItem(at: indexPath) as? IPaImagePickerCollectionViewCell) ?? weakCell else {
                return
            }
            
            if let cellAsset = targetCell.identifier as? PHAsset, asset == cellAsset {
                targetCell.photoImageView.image = resultImage
            }
        })
    
    }
}
//MARK: Asset Caching
extension IPaImageAssetPickerViewController:PHPhotoLibraryChangeObserver
{
    
    func getIndexPaths(_ inRect:CGRect) -> [IndexPath] {
        guard let attributes = contentCollectionView.collectionViewLayout.layoutAttributesForElements(in: inRect) , attributes.count > 0 else {
            return []
        }
        var indexPaths = [IndexPath]()
        for layoutAttribute in attributes {
            indexPaths.append(layoutAttribute.indexPath)
        }
        return indexPaths
    }
    func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = CGRect.zero
    }
    func updateCachedAssets() {
        guard let _ = view.window , isViewLoaded else {
            return
        }
        
        // The preheat window is twice the height of the visible rect.
        var preheatRect = contentCollectionView.bounds
        preheatRect = preheatRect.insetBy(dx: 0.0, dy: -0.5 * preheatRect.height)
        
        /*
         Check if the collection view is showing an area that is significantly
         different to the last preheated area.
         */
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        if delta > contentCollectionView.bounds.height / 3.0 {
            
            // Compute the assets to start caching and to stop caching.
            var addedIndexPaths = [IndexPath]()
            var removedIndexPaths = [IndexPath]()
            computeDifference(previousPreheatRect, newRect: preheatRect, removedHandler: {
                removedRect in
                let indexPaths = self.getIndexPaths(removedRect)
                removedIndexPaths.append(contentsOf: indexPaths)
                
            }, addedHandler: {
                addedRect in
                let indexPaths = self.getIndexPaths(addedRect)
                addedIndexPaths.append(contentsOf: indexPaths)
            })
            let assetsToStartCaching = assetsAtIndexPaths(addedIndexPaths)
            
            let assetsToStopCaching = assetsAtIndexPaths(removedIndexPaths)
            
            // Update the assets the PHCachingImageManager is caching.
            imageManager.startCachingImages(for: assetsToStartCaching, targetSize: photoCellItemSize, contentMode: .aspectFill, options: nil)
            imageManager.stopCachingImages(for: assetsToStopCaching, targetSize: photoCellItemSize, contentMode: .aspectFill, options: nil)
            
            
            // Store the preheat rect to compare against in the future.
            previousPreheatRect = preheatRect
        }
    }
    func computeDifference(_ oldRect:CGRect,newRect:CGRect,removedHandler:((CGRect) -> Void),addedHandler:((CGRect) -> Void)) {
        
        if newRect.intersects(oldRect) {
            let oldMaxY = oldRect.maxY
            let oldMinY = oldRect.minY
            let newMaxY = newRect.maxY
            let newMinY = newRect.minY
            if newMaxY > oldMaxY {
                let rectToAdd = CGRect(x: newRect.origin.x, y: oldMaxY, width: newRect.width, height: newMaxY - oldMaxY)
                addedHandler(rectToAdd)
            }
            
            if oldMinY > newMinY {
                let rectToAdd = CGRect(x: newRect.origin.x, y:newMinY, width:newRect.width, height:oldMinY - newMinY)
                addedHandler(rectToAdd)
            }
            
            if newMaxY < oldMaxY {
                let rectToRemove = CGRect(x:newRect.origin.x, y:newMaxY, width:newRect.width, height:(oldMaxY - newMaxY))
                removedHandler(rectToRemove)
            }
            
            if oldMinY < newMinY {
                let rectToRemove = CGRect(x:newRect.origin.x, y:oldMinY, width:newRect.width, height:(newMinY - oldMinY))
                removedHandler(rectToRemove)
            }
        }
        else {
            addedHandler(newRect);
            removedHandler(oldRect);
        }
    }
    
    func assetsAtIndexPaths(_ indexPaths:[IndexPath]) -> [PHAsset] {
        if indexPaths.count == 0 {
            return []
        }
        var assets = [PHAsset]()
        for indexPath in indexPaths {
            assets.append(fetchResult[indexPath.item] )
        }
        
        return assets;
    }
    //MARK:PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Change notifications may be made on a background queue.
        // Re-dispatch to the main queue to update the UI.
        DispatchQueue.main.async {
            // Check for changes to the displayed album itself
            // (its existence and metadata, not its member assets).
            //            if let albumChanges = changeInstance.changeDetails(for: assetCollection) {
            //                // Fetch the new album and update the UI accordingly.
            //                assetCollection = albumChanges.objectAfterChanges! as! PHAssetCollection
            //                navigationController?.navigationItem.title = assetCollection.localizedTitle
            //            }
            
            // Check if there are changes to the assets we are showing.
            //================================================
            //need to do these two command in the same thread or there will be conditional racing
            guard let collectionChanges = changeInstance.changeDetails(for: self.fetchResult) else {
                return
            }
            self.fetchResult = collectionChanges.fetchResultAfterChanges
            
            // Check for changes to the list of assets (insertions, deletions, moves, or updates).
            
            
            if collectionChanges.hasIncrementalChanges {
                // If there are incremental diffs, animate them in the collection view.
                self.contentCollectionView.performBatchUpdates({
                    // For indexes to make sense, updates must be in this order:
                    // delete, insert, reload, move
                    if let removed = collectionChanges.removedIndexes , removed.count > 0 {
                        self.contentCollectionView.deleteItems(at: removed.map { IndexPath(item: $0, section:0) })
                    }
                    if let inserted = collectionChanges.insertedIndexes , inserted.count > 0 {
                        self.contentCollectionView.insertItems(at: inserted.map { IndexPath(item: $0, section:0) })
                    }
                    if let changed = collectionChanges.changedIndexes , changed.count > 0 {
                        self.contentCollectionView.reloadItems(at: changed.map { IndexPath(item: $0, section:0) })
                    }
                    collectionChanges.enumerateMoves { fromIndex, toIndex in
                        self.contentCollectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                            to: IndexPath(item: toIndex, section: 0))
                    }
                })
            } else {
                // Reload the collection view if incremental diffs are not available.
                self.contentCollectionView.reloadData()
            }
            self.resetCachedAssets()
        }
    }
    
    //MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Update cached assets for the new visible area.
        updateCachedAssets()
    }
}
extension IPaImageAssetPickerViewController:IPaAlbumPickerViewControllerDelegate
{
    func onSelectAlbum(_ albumCollection:PHAssetCollection?) {
        selectedAlbum = albumCollection
        if let collection = albumCollection {
            self.fetchResult = PHAsset.fetchAssets(in: collection, options: nil)
            titleButton.setTitle(collection.localizedTitle ?? "", for: .normal)
            
        }
        else {
            self.fetchResult = allPhotos
            titleButton.setTitle("所有照片", for: .normal)
        }
        self.resetCachedAssets()
        self.contentCollectionView.reloadData()
    }
}
extension IPaImageAssetPickerViewController:UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath])
    {
        
    }
    
    // indexPaths that previously were considered as candidates for pre-fetching, but were not actually used; may be a subset of the previous call to -collectionView:prefetchItemsAtIndexPaths:
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        
        
    }
}
