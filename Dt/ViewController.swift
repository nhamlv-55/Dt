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

    @IBOutlet weak var Share: UIButton!
    var cachedImage: UIImage!

    var photoPicked: Bool!

    let backgroundPic = UIImage(named: "background")
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoPicked = false
        let ratioConstraint = NSLayoutConstraint(item:self.ImageView,
                                                attribute:NSLayoutAttribute.Height,
                                                relatedBy:NSLayoutRelation.Equal,
                                                toItem:self.ImageView,
                                                attribute:NSLayoutAttribute.Width,
                                                multiplier:1.0,
                                                constant:0);
        ImageView.addConstraint(ratioConstraint)
//        ImageView.layer.borderWidth = 2
//        ImageView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5).CGColor
        ImageView.image=backgroundPic
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
        cachedImage = nil
        photoPicked = false
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

        picker.cameraOverlayView = overlayFrame
        presentViewController(picker, animated: true, completion: nil)
        
    }


    @IBAction func ShareAction(sender: UIButton) {
        print("call share")
            let objectsToShare = [self.cachedImage]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

            activityVC.popoverPresentationController?.sourceView = sender
            self.presentViewController(activityVC, animated: true, completion: nil)
    }

//TODO:    after picking the image, can call the camera here?
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if(picker.sourceType == UIImagePickerControllerSourceType.Camera){
            print("use the camera")
            let rawImage = info[UIImagePickerControllerOriginalImage] as! UIImage



            let imageToSave = cropToSquare(rawImage, photoPicked: photoPicked)
            UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
            photoPicked=false
            self.dismissViewControllerAnimated(true, completion: nil)

        }else{//Open an image
            cachedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            if(cachedImage.size.height != cachedImage.size.width){
                var resultImage = UIImage(CGImage: cachedImage.CGImage!)
                let size = max(cachedImage.size.height, cachedImage.size.width)
                UIGraphicsBeginImageContext( CGSizeMake(size, size) );

                backgroundPic!.drawInRect(CGRect(x: 0, y: 0, width: size, height: size))
                cachedImage.drawAtPoint(CGPoint(x: size/2, y: 0))

                resultImage = UIGraphicsGetImageFromCurrentImageContext();
                
                UIGraphicsEndImageContext();
                ImageView.image = resultImage
            }else{
                ImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage

            }

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
            overlayFrame.alpha = 0.8

            camera.cameraOverlayView = overlayFrame
            if let topController = UIApplication.topViewController() {
                topController.presentViewController(camera, animated: true, completion: nil)
            }
        }
    }

    func cropToSquare(image: UIImage, photoPicked: Bool) -> UIImage {
        print("call crop")
        print(photoPicked)
        let contextImage: UIImage = UIImage(CGImage: image.CGImage!)

        let contextSize: CGSize = contextImage.size

        var resultImage: UIImage!
        var cgwidth: CGFloat = 0.0
        var cgheight: CGFloat = 0.0

        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }

        print("done calculating frame")
        if(photoPicked==false){
            let rect: CGRect = CGRectMake(cgwidth/2, 0, cgwidth/2, cgheight)

            // Create bitmap image from context using the rect
            let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!

            // Create a new image based on the imageRef and rotate back to the original orientation
            resultImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
            var tempImage: UIImage

            UIGraphicsBeginImageContext( CGSizeMake(cgwidth,cgwidth) );

            backgroundPic!.drawInRect(CGRect(x: 0, y: 0, width: cgwidth, height: cgwidth))
            resultImage.drawAtPoint(CGPoint(x: cgwidth/2, y: 0))

            tempImage = UIGraphicsGetImageFromCurrentImageContext();

            UIGraphicsEndImageContext();

            self.ImageView.image = tempImage

        }
        if(photoPicked==true){
            resultImage = UIImage(CGImage: cachedImage.CGImage!)

            UIGraphicsBeginImageContext( CGSizeMake(cgwidth,cgwidth) );

            contextImage.drawAtPoint(CGPoint(x: 0, y: 0))
            cachedImage.drawAtPoint(CGPoint(x: cgwidth/2, y: 0))

            resultImage = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            self.ImageView.image = resultImage
        }

        self.cachedImage = resultImage
        return resultImage

    }

    
}

