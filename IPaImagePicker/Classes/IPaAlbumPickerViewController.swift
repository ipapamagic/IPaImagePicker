//
//  IPaAlbumPickerViewController.swift
//  IPaImagePickerViewController
//
//  Created by IPa Chen on 2017/5/24.
//  Copyright © 2017年 A Magic Studio. All rights reserved.
//

import UIKit
import Photos
@objc protocol IPaAlbumPickerViewControllerDelegate
{
    func onSelectAlbum(_ albumCollection:PHAssetCollection?)
    
}
@objc class IPaAlbumPickerViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    // MARK: Types for managing sections, cell and segue identifiers
    var delegate:IPaAlbumPickerViewControllerDelegate!
    var selectedAlbum:PHCollection?
    
    enum Section: Int {
        case allPhotos = 0
        case favoriteAlbum
        case userCollections
        
        static let count = 3
    }
    var assetCache = [String:PHAsset]()
    let cacheSize = CGSize(width: 120, height: 120)
    var previousPreheatRect = CGRect.zero
    lazy var imageManager = PHCachingImageManager()
    lazy var allPhotos: PHFetchResult<PHAsset> = {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = IPaImageAssetPickerViewController.photoSortDescriptors
        return PHAsset.fetchAssets(with: allPhotosOptions)
    }()
    lazy var favoriteAlbum: PHFetchResult<PHAssetCollection> = {
        
        return PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: nil)
    }()
    lazy var userCollections: PHFetchResult<PHCollection> = {
        return PHCollectionList.fetchTopLevelUserCollections(with: nil)
    }()
    
    @IBOutlet weak var contentTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a PHFetchResult object for each section in the table view.
        
        PHPhotoLibrary.shared().register(self)
        // Do any additional setup after loading the view.
    }
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {

        return Section.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .allPhotos: return 1
        case .favoriteAlbum: return favoriteAlbum.count
        case .userCollections: return userCollections.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as! IPaAlbumPickerTableViewCell
        
        var photoAsset:PHAsset?
        switch Section(rawValue: indexPath.section)! {
        case .allPhotos:
            cell.albumNameLabel.text = "所有照片"
            
            if let asset = allPhotos.firstObject {
                photoAsset = asset
                
            }
            if selectedAlbum == nil {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
            
        case .favoriteAlbum:
            let collection = favoriteAlbum.object(at: indexPath.row)
            photoAsset = self.assetsAtIndexPaths([indexPath]).first
            cell.albumNameLabel.text = collection.localizedTitle
            if let selectedAlbum = selectedAlbum ,selectedAlbum.localIdentifier == collection.localIdentifier {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
        case .userCollections:
            let collection = userCollections.object(at: indexPath.row)
            photoAsset = self.assetsAtIndexPaths([indexPath]).first            
            cell.albumNameLabel.text = collection.localizedTitle
            if let selectedAlbum = selectedAlbum ,selectedAlbum.localIdentifier == collection.localIdentifier {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
        }
        cell.albumImageView.image = nil
        if let wPhotoAsset = photoAsset {
            cell.requestIntifier = wPhotoAsset.localIdentifier
            imageManager.requestImage(for: wPhotoAsset, targetSize: cacheSize, contentMode: .aspectFill, options: nil, resultHandler:  {
                resultImage,info in
                if cell.requestIntifier == wPhotoAsset.localIdentifier {
                    DispatchQueue.main.async {
                        cell.albumImageView.image = resultImage
                    }
                    
                }
            })
        }
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section)! {
        case .allPhotos:
            delegate.onSelectAlbum(nil)
            dismiss(animated: true, completion: nil)
        case .favoriteAlbum:
            let collection = favoriteAlbum.object(at: indexPath.row)
            delegate.onSelectAlbum( collection)
            dismiss(animated: true, completion: nil)
        case .userCollections:
            let collection = userCollections.object(at: indexPath.row)
            if let assetCollection = collection as? PHAssetCollection {
                delegate.onSelectAlbum( assetCollection)
                dismiss(animated: true, completion: nil)
            }
            else if let collectionList = collection as? PHCollectionList {
                self.performSegue(withIdentifier: "showSubAlbum", sender: collectionList)
                
                
            }
        }
    }
    //MARK: Asset Caching
    func getIndexPaths(_ inRect:CGRect) -> [IndexPath] {
        
        let minRow:Int = Int(inRect.minY / contentTableView.rowHeight)
        let maxRow:Int = Int(inRect.maxY / contentTableView.rowHeight)
        var indexPaths = [IndexPath]()
        if minRow == 0 {
            indexPaths.append(IndexPath(row: 0, section: 0))
        }
        
        if maxRow >= 1 {
            //favoriteAlbum
            let smartMaxRow = min(favoriteAlbum.count ,maxRow - 1)
            for row in 0 ..< smartMaxRow {
                indexPaths.append(IndexPath(row: row, section: 1))
            }
            
            if maxRow >= 1 + favoriteAlbum.count {
                //userCollection
                let userMaxRow = min(userCollections.count ,maxRow - 1 - favoriteAlbum.count)
                for row in 0 ..< userMaxRow {
                    indexPaths.append(IndexPath(row: row, section: 2))
                }
            }
            
            
        }
        return indexPaths
    }
    func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = CGRect.zero
        assetCache.removeAll()
    }
    func updateCachedAssets() {
        guard let _ = view.window , isViewLoaded else {
            return
        }
        
        // The preheat window is twice the height of the visible rect.
        var preheatRect = contentTableView.bounds
        preheatRect = preheatRect.insetBy(dx: 0.0, dy:  -3.0 * preheatRect.height)
        
        /*
         Check if the collection view is showing an area that is significantly
         different to the last preheated area.
         */
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        if delta > contentTableView.bounds.height / 3.0 {
            
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
            
            imageManager.startCachingImages(for: assetsToStartCaching, targetSize: cacheSize, contentMode: .aspectFill, options: nil)
            imageManager.stopCachingImages(for: assetsToStopCaching, targetSize: cacheSize, contentMode: .aspectFill, options: nil)
            
            
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
        
        return indexPaths.compactMap({
            indexPath in
            if indexPath.section == 0 {
                return allPhotos.firstObject!
            }
            else if indexPath.section == 1 {
                let assetCollection = favoriteAlbum.object(at: indexPath.row)
                if let asset = assetCache[assetCollection.localIdentifier] {
                    return asset
                }
                
                let fetchOptions = PHFetchOptions()
                fetchOptions.fetchLimit = 1
                fetchOptions.sortDescriptors = IPaImageAssetPickerViewController.photoSortDescriptors
                
                if let fetchResult = PHAsset.fetchKeyAssets(in: assetCollection, options: fetchOptions),fetchResult.count > 0 {
                    let asset = fetchResult.object(at:0)
                    assetCache[assetCollection.localIdentifier] = asset
                    return asset
                }
            }
            else {
                let collection = userCollections.object(at: indexPath.row)
                if let asset = assetCache[collection.localIdentifier] {
                    return asset
                }
                else {
                    if let assetCollection = collection as? PHAssetCollection {
                        let collectionFetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
                        if collectionFetchResult.count > 0 {
                            let asset = collectionFetchResult.object(at: 0)
                           
                            assetCache[collection.localIdentifier] = asset
                            return asset
                        }
                    }
                    else if let collectionList = collection as? PHCollectionList {
                        let options = PHFetchOptions()
                        options.sortDescriptors = IPaImageAssetPickerViewController.photoSortDescriptors
                        
                        let collectionFetchResult = PHCollectionList.fetchCollections(in: collectionList, options: nil)
                        for index in 0 ..< collectionFetchResult.count {
                            if let assetCollection = collectionFetchResult.object(at: index) as? PHAssetCollection {
                                let collectionFetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
                                if collectionFetchResult.count > 0 {
                                    let asset = collectionFetchResult.object(at: 0)
                                    
                                    assetCache[collection.localIdentifier] = asset
                                    return asset
                                }
                            }
                        }
                    }
                }
            }
            return nil
        })
    }
    //MARK: UIStoryboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSubAlbum" {
            let viewController = segue.destination as! IPaSubAlbumPickerViewController
            viewController.collectionList = (sender as! PHCollectionList)
            viewController.delegate = self.delegate
            viewController.selectedAlbum = self.selectedAlbum
        }
    }
}
// MARK: PHPhotoLibraryChangeObserver
extension IPaAlbumPickerViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Check each of the three top-level fetches for changes.
            
            if let changeDetails = changeInstance.changeDetails(for: allPhotos) {
                // Update the cached fetch result.
                allPhotos = changeDetails.fetchResultAfterChanges
                // (The table row for this one doesn't need updating, it always says "All Photos".)
            }
            
            // Update the cached fetch results, and reload the table sections to match.
            
            if let changeDetails = changeInstance.changeDetails(for: userCollections) {
                userCollections = changeDetails.fetchResultAfterChanges
                contentTableView.reloadSections(IndexSet(integer: Section.userCollections.rawValue), with: .automatic)
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
