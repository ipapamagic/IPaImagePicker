//
//  IPaFocusView.swift
//  IPaCaculatorPro
//
//  Created by IPa Chen on 2016/5/21.
//  Copyright © 2016年 AMagicStudio. All rights reserved.
//

import UIKit

class IPaFocusView: UIImageView {

    let FADE_TIME:TimeInterval = 2.0
    let FADE_ALPHA:CGFloat = 0.3
    let FADE_OUT_TIME:TimeInterval = 0.3
    var fadeTimer:Timer?
    override func awakeFromNib() {
        super.awakeFromNib()
        alpha = FADE_ALPHA
        self.image = IPaImagePickerDrawKit.imageOfFocusImage()
        
    }
    
    func reset()
    {
        alpha = 1
        if let fadeTimer = fadeTimer {
            fadeTimer.invalidate()
            self.fadeTimer = nil;
        }
        fadeTimer = Timer.scheduledTimer(timeInterval: FADE_TIME, target: self, selector: #selector(IPaFocusView.onFadeOut(_:)), userInfo: nil, repeats: false)
    }
    @objc func onFadeOut(_ sender:Timer)
    {
        UIView.animate(withDuration: FADE_OUT_TIME, animations: {
            self.alpha = self.FADE_ALPHA
        })
        fadeTimer?.invalidate()
        fadeTimer = nil;
    }
    func flashView() {
        alpha = 0
        isHidden = false
        UIView.animate(withDuration: FADE_OUT_TIME, animations: {
            self.alpha = 1
            }, completion: {
                finished in
                UIView.animate(withDuration: self.FADE_OUT_TIME, animations: {
                    self.alpha = 0
                    },completion: {
                        finished in
                        self.isHidden = true
                })
        })
    }

}
