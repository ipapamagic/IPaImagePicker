//
//  IPaSubAlbumPickerViewController.swift
//
//  Created by IPa Chen on 2017/5/25.
//  Copyright © 2017年 AMagicStudio. All rights reserved.
//

import UIKit
import Photos
class IPaSubAlbumPickerViewController: UIViewController {
    var assetCache = [String:PHAsset]()
    let cacheSize = CGSize(width: 120, height: 120)
    var previousPreheatRect = CGRect.zero
    lazy var imageManager = PHCachingImageManager()
    var delegate:IPaAlbumPickerViewControllerDelegate!
    var selectedAlbum:PHCollection?
    @IBOutlet weak var contentTableView: UITableView!
    
    var collectionList:PHCollectionList!
    {
        didSet {
            fetchResult = PHCollection.fetchCollections(in: collectionList, options: nil)
        }
    }
    var fetchResult:PHFetchResult<PHCollection>!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    //MARK: Asset Caching
    func getIndexPaths(_ inRect:CGRect) -> [IndexPath] {
        
        let minRow:Int = max(0,Int(inRect.minY / contentTableView.rowHeight))
        let maxRow:Int = Int(inRect.maxY / contentTableView.rowHeight)
        var indexPaths = [IndexPath]()
        if maxRow >= 0 {
            let albumMaxRow = min(fetchResult.count-1 ,maxRow)
            for row in minRow ..< albumMaxRow {
                indexPaths.append(IndexPath(row: row, section: 0))
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
            if let assetCollection = fetchResult.object(at:indexPath.row) as? PHAssetCollection {
                
                if let asset = assetCache[assetCollection.localIdentifier] {
                    return asset
                }
                
                let fetchOptions = PHFetchOptions()
                fetchOptions.fetchLimit = 1
                fetchOptions.sortDescriptors = IPaImageAssetPickerViewController.photoSortDescriptors
                let collectionFetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
                if collectionFetchResult.count > 0 {
                    let asset = collectionFetchResult.object(at:0)
                    assetCache[assetCollection.localIdentifier] = asset
                    return asset
                }
            }
            return nil
        })
    }
}
extension IPaSubAlbumPickerViewController:UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return fetchResult.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let collection = fetchResult.object(at: indexPath.row)
        if let assetCollection = collection as? PHAssetCollection {
            delegate.onSelectAlbum( assetCollection)
            dismiss(animated: true, completion: nil)
        }
        
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView .dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as! IPaAlbumPickerTableViewCell
        let collection = fetchResult.object(at: indexPath.row)
        let photoAsset = self.assetsAtIndexPaths([indexPath]).first
        cell.albumNameLabel.text = collection.localizedTitle
        if let selectedAlbum = selectedAlbum ,selectedAlbum.localIdentifier == collection.localIdentifier {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
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
}

// MARK: PHPhotoLibraryChangeObserver
extension IPaSubAlbumPickerViewController {
    //MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Update cached assets for the new visible area.
        updateCachedAssets()
    }
}
