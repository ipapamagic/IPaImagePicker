//
//  IPaImagePickerCollectionViewCell.swift
//  IPaImagePickerContentViewController
//
//  Created by IPa Chen on 2016/1/11.
//  Copyright © 2016年 A Magic Studio. All rights reserved.
//

import UIKit
protocol IPaImagePickerCollectionViewCellDelegate
{
    func onTapMarkerButton(_ cell:IPaImagePickerCollectionViewCell)
}
class IPaImagePickerCollectionViewCell: UICollectionViewCell {
    var delegate:IPaImagePickerCollectionViewCellDelegate!
    @IBOutlet weak var markerButton: IPaIndexButton!
    @IBOutlet weak var photoImageView: UIImageView!
    var identifier:Any?
    var markerNumber:Int {
        get {
            return markerButton.indexNumber
        }
        set {
            markerButton.indexNumber = newValue
            
        }
    }
    
    @IBAction func onTapMarkerButton(_ sender: Any) {
        self.delegate.onTapMarkerButton(self)
    }
}
