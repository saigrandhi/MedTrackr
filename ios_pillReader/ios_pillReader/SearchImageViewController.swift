//
//  SearchImageViewController.swift
//  ios_pillReader
//
//  Created by Sai Grandhi on 11/13/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import UIKit
import FontAwesome_swift
import Fusuma
import Alamofire
import SwiftyJSON

class SearchImageViewController: UIViewController, FusumaDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resetUIButton: UIBarButtonItem!
    let base_url = "http://02c9958e.ngrok.io/"
    var img_url: String = ""
    var isImgFound: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.image = UIImage.fontAwesomeIcon(code: "fa-plus-square", textColor: UIColor.red, size: CGSize(width: 4000, height: 4000))
        //self.overTable.isHidden = true
        resetUIButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resetUI(_ sender: Any) {
        cleanUpUI(false)
    }

    @IBAction func openFusuma(_ sender: UIButton) {
        let fusuma = FusumaViewController()
        
        fusuma.delegate = self
        self.present(fusuma, animated: true, completion: nil)
    }
    
    // MARK: FusumaDelegate Protocol
    func fusumaImageSelected(_ image: UIImage) {
        
        print("Image selected")
        imageView.image = image
    }
    
    
    func fusumaDismissedWithImage(_ image: UIImage) {
        imageView.image = image
        let imageData = UIImagePNGRepresentation(image)
        let image_name = "file.jpg"
        let url2 = "http://localhost:5000/api/pushImage/"
        let result = Alamofire.upload(multipartFormData: {
            multiPartFormData in
            multiPartFormData.append(imageData!, withName: "file", fileName: "image.jpg", mimeType: "image/jpeg")
        }, to: url2, encodingCompletion: {
            encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                //let resultJson = JSON(upload)
                //self.img_url = resultJson["url"].stringValue
                upload.responseJSON {
                    response in
                    //debugPrint(response)
                    if let jason = response.result.value {
                        print("result: \(jason)")
                    }
                    performUIUpdatesOnMain {
                        self.addImageButton.setTitle("Analyze Image", for: UIControlState.normal)
                        self.isImgFound = true
                    }
                    //img_url = response("url")
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
        cleanUpUI(true)
        print("Called just after dismissed FusumaViewController")
    }
    
    /// Re-arrange UI
    func cleanUpUI(_ isPickerOn: Bool) {
        if isPickerOn {
            print("calling true cleanUPUi")
            //overTable.isHidden = false
            resetUIButton.isEnabled = true
            //picAdded = true
            addImageButton.isEnabled = false
            addImageButton.isHidden = false
        } else {
            print("calling false cleanUPUi")
            imageView.image = UIImage.fontAwesomeIcon(code: "fa-plus-square", textColor: UIColor.red, size: CGSize(width: 4000, height: 4000))
            //overTable.isHidden = true
            addImageButton.isEnabled = true
            addImageButton.isHidden = false
            resetUIButton.isEnabled = false

//            isWordSelected = false

        }
    }
    
    
    
    func fusumaClosed() {
        
        print("Called when the close button is pressed")
    }

    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
        
        let alert = UIAlertController(title: "Access Requested", message: "Saving image needs to access your photo album", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
            
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        print("video completed and output to file: \(fileURL)")
        //self.fileUrlLabel.text = "file output to: \(fileURL.absoluteString)"
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
//    // given raw JSON, return a usable Foundation object
//    fileprivate func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
//        
//        var parsedResult: AnyObject!
//        do {
//            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! JSONStandard
//        } catch {
//            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
//            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
//        }
//        
//        completionHandlerForConvertData(parsedResult, nil)
//    }
    

}

extension SearchImageViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        return cell!
    }
}
