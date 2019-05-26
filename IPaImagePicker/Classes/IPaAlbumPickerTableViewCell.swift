//
//  IPaAlbumPickerTableViewCell.swift
//  IPaImagePickerViewController
//
//  Created by IPa Chen on 2017/5/24.
//  Copyright © 2017年 A Magic Studio. All rights reserved.
//

import UIKit

class IPaAlbumPickerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var albumImageView: UIImageView!
    var requestIntifier:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
