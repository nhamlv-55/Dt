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

    var cachedImage: UIImage!

    var photoPicked: Bool!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoPicked = false
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    

    @IBAction func PhotoLibAction(sender: UIButton) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        
        picker.sourceType = .PhotoLibrary
        
        presentViewController(picker, animated: true, completion: nil)
        
    }
    
    
    @IBAction func CameraAction(sender: UIButton) {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        picker.allowsEditing = false

        picker.delegate = self
        let overlayFrame = UIImageView(frame: CGRectMake(0, 0, view.frame.size.width, view.frame.size.height))
        //crop to square
        let overlayImage1 = UIImageView(frame: CGRectMake(view.frame.size.height, 0, view.frame.size.width-view.frame.size.height, view.frame.size.height))
        overlayImage1.image = UIImage(named: "black")
        //crop to half
        let overlayImage2 = UIImageView(frame: CGRectMake(0, 0,view.frame.size.height/2, view.frame.size.height))
        overlayImage2.image = UIImage(named: "black")

        overlayFrame.addSubview(overlayImage1)
        overlayFrame.addSubview(overlayImage2)
        overlayFrame.alpha = 0.5

//        overlayView.addSubview(overlayImage)

        picker.cameraOverlayView = overlayFrame
        presentViewController(picker, animated: true, completion: nil)
        
    }

    
//TODO:    after picking the image, can call the camera here?
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print(picker.sourceType)
        if(picker.sourceType == UIImagePickerControllerSourceType.Camera){
            print("use the camera")
            let imageToSave = info[UIImagePickerControllerOriginalImage] as! UIImage
            UIImageWriteToSavedPhotosAlbum(self.cropToSquare(imageToSave, photoPicked: photoPicked), nil, nil, nil)
            photoPicked=false
            self.dismissViewControllerAnimated(true, completion: nil)

        }else{//Open an image
            ImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            cachedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            photoPicked = true
            let camera = UIImagePickerController()
            print("get camera")
            camera.sourceType = UIImagePickerControllerSourceType.Camera
            camera.allowsEditing = false
            camera.delegate = self

            let overlayFrame = UIImageView(frame: CGRectMake(0, 0, view.frame.size.width, view.frame.size.height))
            //crop to square
            let overlayImage1 = UIImageView(frame: CGRectMake(view.frame.size.height, 0, view.frame.size.width-view.frame.size.height, view.frame.size.height))
            overlayImage1.image = UIImage(named: "black")
            //crop to half
            let overlayImage2 = UIImageView(frame: CGRectMake(view.frame.size.height/2, 0, view.frame.size.height/2, view.frame.size.height))
            overlayImage2.image = info[UIImagePickerControllerOriginalImage] as! UIImage

            overlayFrame.addSubview(overlayImage1)
            overlayFrame.addSubview(overlayImage2)
            overlayFrame.alpha = 0.5

            camera.cameraOverlayView = overlayFrame
            if let topController = UIApplication.topViewController() {
                topController.presentViewController(camera, animated: true, completion: nil)
            }
        }
    }

//    func savedImageAlert(){
//        let alert:UIAlertView = UIAlertView()
//        alert.title = "Saved!"
//        alert.message = "Your picture was saved to Camera Roll"
//        alert.delegate = self
//        alert.addButtonWithTitle("Ok")
//        alert.show()
//    }


//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        print("Got an image")
//    }
//
//    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
//        print("User canceled image")
//        dismissViewControllerAnimated(true, completion: {
//            // Anything you want to happen when the user selects cancel
//        })
//    }

    func cropToSquare(image: UIImage, photoPicked: Bool) -> UIImage {
        print("call crop")
        print(photoPicked)
        let contextImage: UIImage = UIImage(CGImage: image.CGImage!)

        let contextSize: CGSize = contextImage.size

        var resultImage: UIImage!
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = 0.0
        var cgheight: CGFloat = 0.0

        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
//            posX = ((contextSize.width - contextSize.height) / 2)
//            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
//            posX = 0
//            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }

        print("done calculating frame")
        if(photoPicked==false){
            let rect: CGRect = CGRectMake(cgwidth/2, posY, cgwidth/2, cgheight)

            // Create bitmap image from context using the rect
            let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!

            // Create a new image based on the imageRef and rotate back to the original orientation
            resultImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

        }
        if(photoPicked==true){
            resultImage = UIImage(CGImage: cachedImage.CGImage!)
            /*  combining the overlay and the user-photo  */
            UIGraphicsBeginImageContext( CGSizeMake(cgwidth,cgwidth) );

            /*  for some reason I have to push the user-photo
             down 60 pixels for it to show correctly as it
             was edited.
             */
            contextImage.drawAtPoint(CGPoint(x: 0, y: 0))
            cachedImage.drawAtPoint(CGPoint(x: cgwidth/2, y: 0))

            resultImage = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
        }
        return resultImage

    }

    
}

