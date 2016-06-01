//
//  ViewController.swift
//  Dt
//
//  Created by Nham Le on 5/23/16.
//  Copyright © 2016 Nham Le. All rights reserved.
//

import UIKit

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var PhotoLib: UIButton!
    
    
    
    
    @IBOutlet weak var Camera: UIButton!
    
    
    
    @IBOutlet weak var ImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func PhotoLibAction(sender: UIButton) {
        print("Dsadsadasdsa")
        let picker = UIImagePickerController()
        
        picker.delegate = self
        
        picker.sourceType = .PhotoLibrary
        
        presentViewController(picker, animated: true, completion: nil)
        
        
        
        
        
    }
    
    
    @IBAction func CameraAction(sender: UIButton) {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        picker.allowsEditing = false
//        picker.showsCameraControls = false
        picker.delegate = self
        
        let overlayRect = CGRectMake(0, 0, picker.view.frame.size.width, picker.view.frame.size.height)
        
        let overlayView = UIView(frame: overlayRect)
//        overlayView.contentMode = UIViewContentMode.ScaleAspectFill
        
        let overlayImage = UIImageView(image: UIImage(named: "theking"))
    
        overlayImage.sizeToFit()
        overlayImage.contentMode = UIViewContentMode.ScaleAspectFit
        overlayImage.center = overlayView.center
        overlayImage.alpha = 0.5
        
        overlayView.addSubview(overlayImage)
        
        picker.cameraOverlayView = overlayView
        presentViewController(picker, animated: true, completion: nil)
        
    }

    
//TODO:    after picking the image, can call the camera here?
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        Camera.sendActionsForControlEvents(.TouchUpInside)
        let camera = UIImagePickerController()
        print("get camera")
        camera.sourceType = UIImagePickerControllerSourceType.Camera
//        camera.allowsEditing = false
        //        picker.showsCameraControls = false
        camera.delegate = self
//
        let overlayRect = CGRectMake(0, 0, picker.view.frame.size.width, picker.view.frame.size.height)
//
        let overlayView = UIView(frame: overlayRect)
        overlayView.contentMode = UIViewContentMode.ScaleAspectFill
//
        let overlayImage = UIImageView(image: info[UIImagePickerControllerOriginalImage] as? UIImage)
//
        overlayImage.sizeToFit()
        overlayImage.contentMode = UIViewContentMode.ScaleAspectFit
        overlayImage.center = overlayView.center
        overlayImage.alpha = 0.5
//
        overlayView.addSubview(overlayImage)
//
        camera.cameraOverlayView = overlayView
//        showViewController(camera, sender: AnyObject?)
        if let topController = UIApplication.topViewController() {
                topController.presentViewController(camera, animated: true, completion: nil)
        }
        
//
        
        
//        ImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
//        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

