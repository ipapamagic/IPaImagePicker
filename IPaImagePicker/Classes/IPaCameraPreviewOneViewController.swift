//
//  IPaCameraPreviewOneViewController.swift
//  Pods
//
//  Created by IPa Chen on 2017/8/18.
//
//

import UIKit
protocol IPaCameraPreviewOneViewControllerDelegate
{
    func onReTakePhoto()
}
class IPaCameraPreviewOneViewController: UIViewController {
    @IBOutlet weak var contentImageView: UIImageView!
    var delegate:IPaCameraPreviewOneViewControllerDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let imagePicker = navigationController as! IPaImagePickerController
         let imagePath = (imagePicker.tempPhotoPath as NSString).appendingPathComponent("0")
        contentImageView.image = UIImage(contentsOfFile: imagePath)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onReTake(_ sender: Any) {
        self.delegate.onReTakePhoto()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onUsePhoto(_ sender: Any) {
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
