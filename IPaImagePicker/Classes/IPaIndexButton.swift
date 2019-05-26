
//
//  IPaIndexButton.swift
//  Pods
//
//  Created by IPa Chen on 2017/8/18.
//
//

import UIKit
import IPaDesignableUI
class IPaIndexButton: IPaDesignableButton {
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var userInfo:[String:Any]?
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetting()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetting()
    }
    
    var selectedBackgroundColor = UIColor(red: 0, green: 122.0/255.0, blue: 1, alpha: 1)
    override var bounds: CGRect {
        didSet {
            // Do stuff here
            self.layer.cornerRadius = bounds.size.width / 2
        }
    }
    var indexNumber:Int = 0 {
        didSet {
            self.backgroundColor = (indexNumber > 0) ? selectedBackgroundColor : UIColor.clear
            let text = (indexNumber > 0) ? "\(indexNumber)" : ""
            self.setTitle(text, for: .normal)
        }
    }
    func initialSetting() {
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.cornerRadius = bounds.size.height / 2
    }
}
