//
//  IPaCameraViewController.swift
//
//  Created by IPa Chen on 2016/5/21.
//  Copyright © 2016年 AMagicStudio. All rights reserved.
//

import UIKit
import AVFoundation
import IPaAVCamera
class IPaCameraViewController: UIViewController,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    let avCamera:IPaAVCamera = {
        var camera = IPaAVCamera()
        
        camera.setupCaptureStillImage(.back, error: nil)
        
        return camera
    }()
    var maxPhotoCount:Int {
        get {
            let imagePicker = navigationController as! IPaImagePickerController
            return imagePicker.maxPhotoCount ?? 0
        }
    }
    var photoCount = 0
    @IBOutlet var focusCenterYConstraint: NSLayoutConstraint!
    @IBOutlet var focusCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewView: UIView!
    
    @IBOutlet var flashButton: UIButton!
    @IBOutlet var focusView: IPaFocusView!
    @IBOutlet weak var flashView:UIView!
    open var flashMode:AVCaptureDevice.FlashMode {
        get {
            return AVCaptureDevice.FlashMode(rawValue: UserDefaults.standard.integer(forKey: "FlashMode"))!
        }
        set {
            let userDefault = UserDefaults.standard
            userDefault.set(newValue.rawValue, forKey: "FlashMode")
            userDefault.synchronize()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let scale = UIScreen.main.scale
        let attributes:[NSAttributedString.Key : Any] = [NSAttributedString.Key.strokeColor:UIColor.black,NSAttributedString.Key.strokeWidth:scale * -1,NSAttributedString.Key.font:UIFont .boldSystemFont(ofSize:17),NSAttributedString.Key.foregroundColor:UIColor.white]
        
        let doneString = NSAttributedString(string: "Done", attributes: attributes)
        doneButton.setAttributedTitle(doneString, for: .normal)
        
        
        let cancelString = NSAttributedString(string: "Cancel", attributes: attributes)
        cancelButton.setAttributedTitle(cancelString, for: .normal)
        
        flashView.isHidden = true
        
        cameraButton.setImage(IPaImagePickerDrawKit.imageOfPhotoButton, for: .normal)
        // Do any additional setup after loading the view.
        self.clearPhotos()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        refreshDoneButton()
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        avCamera.setPreviewView(previewView,videoGravity: AVLayerVideoGravity.resizeAspectFill)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func refreshDoneButton() {
        doneButton.isHidden = (maxPhotoCount == 1) || photoCount == 0
    }
    func clearPhotos()
    {
        let fileManager = FileManager.default
        let imagePicker = navigationController as! IPaImagePickerController
        do {
            let tempPhotoPath = imagePicker.tempPhotoPath
            if fileManager.fileExists(atPath: tempPhotoPath) {
                try fileManager.removeItem(atPath: tempPhotoPath)
            }
            try fileManager.createDirectory(atPath: tempPhotoPath, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            
        }
        self.photoCount = 0
    }
    @IBAction func onCancel(_ sender: AnyObject) {
        self.navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func onDone(_ sender: AnyObject) {
    }

    func refreshFlashSwitch()
    {
        let mode = avCamera.getCameraFlashMode(.back)
        switch (mode) {
        case .auto:
            
            
            flashButton.setImage(UIImage(named: "flash_auto", in: IPaImagePickerController.bundle, compatibleWith: nil), for:.normal)
        case .on:
            flashButton.setImage(UIImage(named: "flash_on", in: IPaImagePickerController.bundle, compatibleWith: nil), for:.normal)
        case .off:
            flashButton.setImage(UIImage(named: "flash_off", in: IPaImagePickerController.bundle, compatibleWith: nil), for:.normal)
        @unknown default:
            break
        }
        
        
    }
    @IBAction func onSwitchFlash(_ sender:AnyObject) {
        
        var mode = avCamera.getCameraFlashMode(.back)
        if mode == .off {
            mode = .on
        }
        else if mode == .on {
            mode = .auto
        }
        else
        {
            mode = .off;
        }
        avCamera.setCamera(.back, flashMode: mode)
        refreshFlashSwitch()
        self.flashMode = mode
        
    }
    @IBAction func onCapture(_ sender:AnyObject) {
        if let previewLayer = avCamera.previewLayer {
            if let connection = previewLayer.connection {
                connection.isEnabled = false
            }
        }
        flashView.isHidden = false
        focusView.isHidden = true
        UIView.animate(withDuration: 0.2, animations: {
            
            self.flashView.alpha = 0
            }, completion: {
                finished in
                self.flashView.isHidden = true
                self.flashView.alpha = 1
                self.focusView.isHidden = false
        })
        if !avCamera.canWorking {
            

            return
        }
        avCamera.captureStillImageData({
            imageData in
            let imagePicker = self.navigationController as! IPaImagePickerController
            let filePath = (imagePicker.tempPhotoPath as NSString).appendingPathComponent("\(self.photoCount)")
            do {
                let url = URL(fileURLWithPath: filePath)
                try imageData.write(to: url)
            }
            catch {
                
            }
         
            self.photoCount += 1
            self.refreshDoneButton()
            if let previewLayer = self.avCamera.previewLayer {
                if let connection = previewLayer.connection {
                    connection.isEnabled = true
                }
            }
            
            if self.maxPhotoCount == 1 {
                self.performSegue(withIdentifier: "showSinglePreview", sender: nil)
            }
        })
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showPreview" {
            let viewController = segue.destination as! IPaImagePhotoPickerViewController
            viewController.photoCount = self.photoCount
        }
        else if segue.identifier == "showSinglePreview" {
            let viewController = segue.destination as! IPaCameraPreviewOneViewController
            viewController.delegate = self
        }
    }
 
    @IBAction func onTapGesture(_ sender:UITapGestureRecognizer) {
        
        let tapPos = sender.location(in: view)
        
        //focus camera
        var focusPos = sender.location(in: previewView)
        focusPos = CGPoint(x: focusPos.x / previewView.bounds.width, y: focusPos.y / previewView.bounds.height)
        
        avCamera.setCameraFocusAt(focusPos, focusMode: .continuousAutoFocus)
        let center = previewView.center
        
        focusCenterXConstraint.constant = tapPos.x - center.x
        focusCenterYConstraint.constant = tapPos.y - center.y
        
        view.bringSubviewToFront(focusView)
        view.setNeedsUpdateConstraints()
        let anim = CABasicAnimation(keyPath: "transform")
        
        let fromTransform = CATransform3DMakeScale(1.3, 1.3, 1)
        
        anim.duration = 0.3;
        anim.fromValue = NSValue(caTransform3D:fromTransform)
        anim.toValue = NSValue(caTransform3D:CATransform3DIdentity)
        focusView.layer.add(anim, forKey: nil)
        focusView.reset()
    }
    @IBAction func onPinchGesture(_ sender:AnyObject) {
        
    }
    //MARK:UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
extension IPaCameraViewController: IPaCameraPreviewOneViewControllerDelegate
{
    func onReTakePhoto() {
        self.clearPhotos()
    }
}
