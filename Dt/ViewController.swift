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

    var flipped = false
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
        camera.cameraDevice = .Rear
        flipped = false
        let longerSide = max(view.frame.size.height, view.frame.size.width);
        let shorterSide = min(view.frame.size.height, view.frame.size.width);

        let blackOverlay = UIImageView(frame: CGRectMake(0, 0, shorterSide/2, longerSide))
        blackOverlay.backgroundColor = UIColor.blackColor()
        blackOverlay.alpha = 0.7

        camera.cameraOverlayView = setupOverlayFrame(longerSide, shorterSide: shorterSide, overlayPic: blackOverlay)
        presentViewController(camera, animated: true, completion: nil)

    }

    func takePhoto(){
        camera.takePicture()
    }

    func quitCamera(){
        camera.dismissViewControllerAnimated(true, completion: nil)
    }

    func frontCamera(){
        if(camera.cameraDevice == .Front){
            camera.cameraDevice = .Rear
            flipped = false
        }else{
            camera.cameraDevice = .Front
            flipped = true
        }
    }

    func setupOverlayFrame(longerSide: CGFloat, shorterSide: CGFloat, overlayPic: UIImageView)->UIImageView{
        let overlayFrame = UIImageView(frame: CGRectMake(0, 0, longerSide, longerSide))
        overlayFrame.userInteractionEnabled = true

        //crop to square
        let overlayImage1 = UIImageView(frame: CGRectMake(shorterSide, 0, longerSide-shorterSide, shorterSide))
        overlayImage1.backgroundColor = UIColor.whiteColor()
        overlayImage1.userInteractionEnabled = false
        overlayImage1.exclusiveTouch = false

        let cameraIcon = UIImage(named: "cameraIcon")!


        let overlayImage3 = UIImageView(frame: CGRectMake(0, shorterSide, shorterSide, longerSide-shorterSide))
        overlayImage3.backgroundColor = UIColor.whiteColor()

        let shutterButton = UIButton(frame: CGRect(x: shorterSide/2-40, y: shorterSide + (longerSide-shorterSide)/2-40, width: 80, height: 80))
        shutterButton.layer.cornerRadius = 40
        shutterButton.setBackgroundImage(cameraIcon, forState: .Normal)
        shutterButton.addTarget(self, action: #selector(ViewController.takePhoto), forControlEvents: UIControlEvents.TouchUpInside)

        let frontCameraButton = UIButton(frame: CGRect(x: shorterSide-70, y: shorterSide + (longerSide-shorterSide)/2-20, width: 40, height: 40))
        frontCameraButton.layer.cornerRadius = 20
        frontCameraButton.setBackgroundImage(UIImage(named: "frontCameraIcon"), forState: .Normal)
        frontCameraButton.addTarget(self, action: #selector(ViewController.frontCamera), forControlEvents: UIControlEvents.TouchUpInside)

        let quitCameraButton = UIButton(frame: CGRect(x: 30, y: shorterSide + (longerSide-shorterSide)/2-20, width: 40, height: 40))
        quitCameraButton.layer.cornerRadius = 20
        quitCameraButton.setBackgroundImage(UIImage(named: "cancelIcon"), forState: .Normal)
        quitCameraButton.addTarget(self, action: #selector(ViewController.quitCamera), forControlEvents: UIControlEvents.TouchUpInside)
        //crop to half


        overlayFrame.addSubview(overlayImage1)
        overlayFrame.addSubview(overlayPic)
        overlayFrame.addSubview(overlayImage3)
        overlayFrame.addSubview(shutterButton)
        overlayFrame.addSubview(quitCameraButton)
        overlayFrame.addSubview(frontCameraButton)

        return overlayFrame
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
            print("flipped:")
            print(flipped)
            var imageToSave:UIImage
            let rawImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            if(flipped==true){
                flipped = false
                let shorterSide = min(rawImage.size.height, rawImage.size.width)

                let flippedImage = UIImage(CGImage: rawImage.CGImage!, scale: rawImage.scale, orientation:.LeftMirrored)

                UIGraphicsBeginImageContext( CGSizeMake(shorterSide,shorterSide) );
                flippedImage.drawAtPoint(CGPoint(x: 0, y: 0))
                let tempImage = UIGraphicsGetImageFromCurrentImageContext();
                
                imageToSave = cropToSquare(tempImage, photoPicked: photoPicked)

            }else{
                imageToSave = cropToSquare(rawImage, photoPicked: photoPicked)
            }
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

            let overlayImage = UIImageView(frame: CGRectMake(shorterSide/2, 0, shorterSide/2, shorterSide))
            overlayImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            overlayImage.alpha = 0.7

            camera.cameraOverlayView = setupOverlayFrame(longerSide, shorterSide: shorterSide, overlayPic: overlayImage)
            if let topController = UIApplication.topViewController() {
                topController.presentViewController(camera, animated: true, completion: nil)
            }
        }
    }

    func cropToSquare(image: UIImage, photoPicked: Bool) -> UIImage {
        let contextImage: UIImage = UIImage(CGImage: image.CGImage!)

        let contextSize: CGSize = contextImage.size

        var resultImage: UIImage!
        let shorterSide = min(contextSize.height, contextSize.width)
        let longerSide = max(contextSize.height, contextSize.width)

        if(photoPicked==false){
            print(image.imageOrientation.rawValue)
            var rect: CGRect!
            switch image.imageOrientation.rawValue {
            case 0:
                rect = CGRectMake(shorterSide/2, 0, shorterSide/2, shorterSide)
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

            UIGraphicsBeginImageContext( CGSizeMake(shorterSide,shorterSide) );

            backgroundPic!.drawInRect(CGRect(x: 0, y: 0, width: shorterSide, height: shorterSide))
            resultImage.drawAtPoint(CGPoint(x: shorterSide/2, y: 0))

            tempImage = UIGraphicsGetImageFromCurrentImageContext();

            UIGraphicsEndImageContext();

            self.ImageView.image = tempImage

        }
        if(photoPicked==true){
            print(image.imageOrientation.rawValue)
            var rect: CGRect!
            switch image.imageOrientation.rawValue {
            case 0:
                rect = CGRectMake(0, 0, shorterSide/2, shorterSide)
                break
            case 3:
                rect = CGRectMake(0, shorterSide/2, shorterSide, shorterSide/2)
                break
            default:
                rect = CGRectMake(shorterSide/2, 0, shorterSide/2, shorterSide)

            }
            // Create bitmap image from context using the rect
            let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!

            // Create a new image based on the imageRef and rotate back to the original orientation
            resultImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

            UIGraphicsBeginImageContext( CGSizeMake(shorterSide,shorterSide) );
            
            resultImage.drawAtPoint(CGPoint(x: 0, y: 0))
            cachedImage.drawInRect(CGRect(x: shorterSide/2, y: 0, width: shorterSide/2, height: shorterSide))
            
            resultImage = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            self.ImageView.image = resultImage
        }
        
        self.cachedImage = resultImage
        return resultImage
        
    }
    
    
}

