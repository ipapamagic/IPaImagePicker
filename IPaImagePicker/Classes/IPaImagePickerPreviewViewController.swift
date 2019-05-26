//
//  IPaImagePickerPreviewViewController.swift
//
//  Created by IPa Chen on 2017/8/18.
//
//

import UIKit
import IPaImagePreviewer
import IPaIndicator
protocol IPaImagePickerPreviewViewControllerDelegate
{
    func numberOfImages() -> Int
    func numberOfSelected() -> Int
    func requestImage(at index:Int, complete:@escaping (UIImage?) -> ())
    func removeEditedImage(at index:Int)
    func indexForSelectedImage(at index:Int) -> Int?
    func onTapSelectImage(_ index:Int)
    func onConfirmPick()
}
class IPaImagePickerPreviewViewController: UIViewController {
    
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var contentPreviewView: IPaGalleryPreviewView!
    var delegate:IPaImagePickerPreviewViewControllerDelegate!
    var currentIndex:Int = 0
    

    @IBOutlet weak var doneBarButtonItem: UIBarButtonItem!

    @IBOutlet weak var indexButton: IPaIndexButton!
    lazy var tapGestureRecognizer:UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(IPaImagePickerPreviewViewController.onTap(_:)))
        
        return gestureRecognizer
    }()

    @IBOutlet weak var selectImageButton: IPaIndexButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentPreviewView.addGestureRecognizer(self.tapGestureRecognizer)
        tapGestureRecognizer.require(toFail: self.contentPreviewView.doubleTapRecognizer)
        // Do any additional setup after loading the view.
        contentPreviewView.delegate = self
        contentPreviewView.addObserver(self, forKeyPath: "currentIndex", options: .new, context: nil)
        
//        doneBarButtonItem.isEnabled = self.delegate.numberOfSelected() > 0
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentPreviewView.currentIndex = self.currentIndex
        contentPreviewView.reloadData()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentIndex" {
            self.currentIndex = contentPreviewView.currentIndex
            
            refreshIndexButton()
        }
    }
    @objc func onTap(_ sender:Any) {
        UIView.animate(withDuration: 0.3, animations: {
            let hide = !(self.navigationController?.isNavigationBarHidden ?? false)
            self.navigationController?.setNavigationBarHidden(hide, animated: true)
            
            
            self.bottomToolBar.transform = (hide) ? CGAffineTransform(translationX: 0, y: self.bottomToolBar.bounds.height) : CGAffineTransform.identity
        })
        
        
    }
    func refreshIndexButton() {
        if let selectedIndex = self.delegate.indexForSelectedImage(at: self.currentIndex) {
            indexButton.indexNumber = selectedIndex + 1
        }
        else {
            indexButton.indexNumber = 0
        }

    }
    @IBAction func onConfirm(_ sender: Any) {
        
        if self.delegate.numberOfSelected() == 0 {
            self.delegate.onTapSelectImage(self.currentIndex)
        }
        self.delegate.onConfirmPick()
    }
    
    @IBAction func onTapSelectImage(_ sender: IPaIndexButton) {

        self.delegate.onTapSelectImage(self.currentIndex)
        refreshIndexButton()
//        doneBarButtonItem.isEnabled = self.delegate.numberOfSelected() > 0
//        guard let userInfo = sender.userInfo,let pageIndex = userInfo["PageIndex"] as? Int else {
//            return
//        }
//        self.delegate.onTapSelectImage(pageIndex)
//        if let index = self.delegate.indexForSelectedImage(at: pageIndex) {
//            sender.indexNumber = index + 1
//        }
//        else {
//            sender.indexNumber = 0
//        }
//        

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension IPaImagePickerPreviewViewController:IPaGalleryPreviewViewDelegate {
    func numberOfImages(_ galleryView:IPaGalleryPreviewView) -> Int
    {
        return self.delegate.numberOfImages()
    }
    func loadImage(_ galleryView: IPaGalleryPreviewView, index: Int, complete: @escaping (UIImage?) -> ()) {
        let totalCount = self.delegate.numberOfImages()
        if index >= totalCount || index < 0 {
            return
        }
        self.delegate.requestImage(at: index,complete:{
            image in
            complete(image)
        })
        
    }
    func customView(_ galleryView:IPaGalleryPreviewView,index:Int,reuseCustomView:UIView?) ->  UIView?
    {
        return nil
    }
}
