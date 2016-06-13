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

    let camera = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoPicked = false
        ImageView.image=backgroundPic
        ImageView.layer.borderWidth = 0
        // Do any additional setup after loading the view, typically from a nib.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

    override func prefersStatusBarHidden() -> Bool {
        return true;
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
        camera.sourceType = UIImagePickerControllerSourceType.Camera
        camera.allowsEditing = false
        camera.showsCameraControls = false
        camera.delegate = self

        let longerSide = max(view.frame.size.height, view.frame.size.width);
        let shorterSide = min(view.frame.size.height, view.frame.size.width);

        let overlayFrame = UIImageView(frame: CGRectMake(0, 0, longerSide, longerSide))
        overlayFrame.userInteractionEnabled = true

        //crop to square
        let overlayImage1 = UIImageView(frame: CGRectMake(shorterSide, 0, longerSide-shorterSide, shorterSide))
        overlayImage1.backgroundColor = UIColor.whiteColor()
        overlayImage1.userInteractionEnabled = false
        overlayImage1.exclusiveTouch = false

        let button = UIButton(frame: CGRect(x: shorterSide + (longerSide-shorterSide)/2-50, y: shorterSide/2-50, width: 100, height: 100))
        button.layer.cornerRadius = 50
        button.backgroundColor = UIColor.greenColor()
        button.addTarget(self, action: Selector("takePhoto"), forControlEvents: UIControlEvents.TouchUpInside)


        let overlayImage3 = UIImageView(frame: CGRectMake(0, shorterSide, shorterSide, longerSide-shorterSide))
        overlayImage3.backgroundColor = UIColor.whiteColor()

        let button2 = UIButton(frame: CGRect(x: shorterSide/2-35, y: shorterSide + 35, width: 70, height: 70))
        button2.layer.cornerRadius = 35
        button2.backgroundColor = UIColor.greenColor()
        button2.addTarget(self, action: Selector("takePhoto"), forControlEvents: UIControlEvents.TouchUpInside)

        let quitCameraButton = UIButton(frame: CGRect(x: shorterSide/2-15, y: longerSide-45, width: 30, height: 30))
        quitCameraButton.layer.cornerRadius = 15
        quitCameraButton.backgroundColor = UIColor.redColor()
        quitCameraButton.addTarget(self, action: Selector("quitCamera"), forControlEvents: UIControlEvents.TouchUpInside)
        //crop to half
        let overlayImage2 = UIImageView(frame: CGRectMake(0, 0, shorterSide/2, longerSide))
        overlayImage2.backgroundColor = UIColor.blackColor()
        overlayImage2.alpha = 0.7

        overlayFrame.addSubview(overlayImage1)
        overlayFrame.addSubview(overlayImage2)
        overlayFrame.addSubview(overlayImage3)
        overlayFrame.addSubview(button)
        overlayFrame.addSubview(button2)
        overlayFrame.addSubview(quitCameraButton)

        camera.cameraOverlayView = overlayFrame
        presentViewController(camera, animated: true, completion: nil)

    }

    func takePhoto(){
        camera.takePicture()
    }

    func quitCamera(){
        camera.dismissViewControllerAnimated(true, completion: nil)
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
            camera.sourceType = UIImagePickerControllerSourceType.Camera
            camera.allowsEditing = false
            camera.delegate = self
            camera.showsCameraControls = false

            let longerSide = max(view.frame.size.height, view.frame.size.width);
            let shorterSide = min(view.frame.size.height, view.frame.size.width);

            let overlayFrame = UIImageView(frame: CGRectMake(0, 0, longerSide, longerSide))
            overlayFrame.userInteractionEnabled = true

            //crop to square
            let overlayImage1 = UIImageView(frame: CGRectMake(shorterSide, 0, longerSide-shorterSide, shorterSide))
            overlayImage1.backgroundColor = UIColor.whiteColor()
            overlayImage1.userInteractionEnabled = false
            overlayImage1.exclusiveTouch = false

            let button = UIButton(frame: CGRect(x: shorterSide + (longerSide-shorterSide)/2-50, y: shorterSide/2-50, width: 100, height: 100))
            button.layer.cornerRadius = 50
            button.backgroundColor = UIColor.greenColor()
            button.addTarget(self, action: Selector("takePhoto"), forControlEvents: UIControlEvents.TouchUpInside)


            let overlayImage3 = UIImageView(frame: CGRectMake(0, shorterSide, shorterSide, longerSide-shorterSide))
            overlayImage3.backgroundColor = UIColor.whiteColor()

            let button2 = UIButton(frame: CGRect(x: shorterSide/2-35, y: shorterSide + 35, width: 70, height: 70))
            button2.layer.cornerRadius = 35
            button2.backgroundColor = UIColor.greenColor()
            button2.addTarget(self, action: Selector("takePhoto"), forControlEvents: UIControlEvents.TouchUpInside)

            let quitCameraButton = UIButton(frame: CGRect(x: shorterSide/2-15, y: longerSide-45, width: 30, height: 30))
            quitCameraButton.layer.cornerRadius = 15
            quitCameraButton.backgroundColor = UIColor.redColor()
            quitCameraButton.addTarget(self, action: Selector("quitCamera"), forControlEvents: UIControlEvents.TouchUpInside)
            //crop to half
            let overlayImage2 = UIImageView(frame: CGRectMake(shorterSide/2, 0, shorterSide/2, shorterSide))
            overlayImage2.image = info[UIImagePickerControllerOriginalImage] as! UIImage
            overlayImage2.alpha = 0.7
            //            ----------------------------------

            overlayFrame.addSubview(overlayImage1)
            overlayFrame.addSubview(overlayImage2)
            overlayFrame.addSubview(overlayImage3)
            overlayFrame.addSubview(button)
            overlayFrame.addSubview(button2)
            overlayFrame.addSubview(quitCameraButton)

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

        let shorterSide = min(contextSize.height, contextSize.width)
        let longerSide = max(contextSize.height, contextSize.width)

        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }

        if(photoPicked==false){
            print(image.imageOrientation.rawValue)
            var rect: CGRect!
            switch image.imageOrientation.rawValue {
            case 0:
                rect = CGRectMake(shorterSide/2, 0, shorterSide/2, shorterSide)
                break
            case 1:
                rect = CGRectMake(shorterSide/2, 0, shorterSide/2, shorterSide)
                break
            case 2:
                rect = CGRectMake(0, shorterSide/2, shorterSide, shorterSide/2)
                break
            case 3:
                rect = CGRectMake(0, 0, shorterSide, shorterSide/2)
                break
            default:
                rect = CGRectMake(shorterSide/2, 0, shorterSide/2, shorterSide)

            }

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
            print(image.imageOrientation.rawValue)
            var rect: CGRect!
            switch image.imageOrientation.rawValue {
            case 0:
                rect = CGRectMake(shorterSide/2, 0, shorterSide/2, shorterSide)
                break
            case 1:
                rect = CGRectMake(shorterSide/2, 0, shorterSide/2, shorterSide)
                break
            case 2:
                rect = CGRectMake(0, shorterSide/2, shorterSide, shorterSide/2)
                break
            case 3:
                rect = CGRectMake(0, 0, shorterSide, shorterSide/2)
                break
            default:
                rect = CGRectMake(shorterSide/2, 0, shorterSide/2, shorterSide)

            }
            // Create bitmap image from context using the rect
            let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!

            // Create a new image based on the imageRef and rotate back to the original orientation
            resultImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

            UIGraphicsBeginImageContext( CGSizeMake(cgwidth,cgwidth) );
            
            resultImage.drawAtPoint(CGPoint(x: 0, y: 0))
            cachedImage.drawAtPoint(CGPoint(x: cgwidth/2, y: 0))
            
            resultImage = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            self.ImageView.image = resultImage
        }
        
        self.cachedImage = resultImage
        return resultImage
        
    }
    
    
}

