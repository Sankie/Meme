//
//  EditViewController.swift
//  Meme Testing
//
//  Created by Sanky Chan on 2/7/15.
//  Copyright (c) 2015 SankieInc. All rights reserved.
//

import UIKit
import Foundation

class EditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var pickBarButton: UIBarButtonItem!
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    //Create an array to store number of saving times
    var saveSeq = [Int]()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        shareButton.enabled = false
        self.topTextField.delegate = self
        self.topTextField.text = "TOP"
        self.bottomTextField.delegate = self
        self.bottomTextField.text = "BOTTOM"
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
        self.subscribeToHideKeyboardNotifications()
        
        cameraBarButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
        self.unsubscribeFromHideKeyboardNotification()
    }
    
    @IBAction func pickImage(sender: AnyObject) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(pickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func pickImageCamera(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(pickerController, animated: true, completion: nil)
        
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.contentMode = .ScaleAspectFit
            imagePickerView.image = pickedImage
            if pickedImage.images == nil {shareButton.enabled = true}
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -3.0
    ]
    
    @IBAction func moveViewUpward(sender: UITextField) {
        NSNotificationCenter.defaultCenter().postNotificationName("tapBottomLabel", object: self)
    }
    
    @IBAction func moveViewDownward(sender: UITextField) {
        NSNotificationCenter.defaultCenter().postNotificationName("finishedEditBottomLabel", object: self)
    }
    
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowForBottomLabel:", name: "tapBottomLabel", object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            "tapBottomLabel", object: nil)
    }
    
    func subscribeToHideKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHideForBottomLabel:", name: "finishedEditBottomLabel", object: nil)
    }
    
    func unsubscribeFromHideKeyboardNotification(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            "finishedEditBottomLabel", object: nil)
    }
    
    func keyboardWillShowForBottomLabel(notification: NSNotification) {
        self.view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        
        var keyboardSize = 180
        return CGFloat(keyboardSize)
    }
    
    func keyboardWillHideForBottomLabel(notification: NSNotification){
        self.view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    //dismiss keyboard by typing return key
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.topTextField.resignFirstResponder()
        self.bottomTextField.resignFirstResponder()
        return true;
    }
    
    //dismiss keyboard by typing other areas
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    
    func save() -> [Int] {
        //Create the meme with Index number by memeIndex var
        
        var meme = Meme( topText: topTextField.text!, bottomText: bottomTextField.text!, originalImg: imagePickerView.image, memedImg: generateMemedImage(), memeIndex: saveSeq.count)
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        //Add an object into saveSeq array
        self.saveTimesIncreasement()
        return self.saveSeq
        
    }
    
    //Func for adding an object into saveSeq array
    func saveTimesIncreasement() -> [Int]{
       saveSeq.append(1)
       return self.saveSeq
        
    }
    
    func generateMemedImage() -> UIImage
    {
        self.topToolBar.hidden = true
        self.bottomToolBar.hidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.topToolBar.hidden = false
        self.bottomToolBar.hidden = false
        
        return memedImage
    }
    
    @IBAction func shareAction(sender: AnyObject) {
        let memedImage = generateMemedImage()
        let ActivityVC = UIActivityViewController(activityItems:[memedImage],applicationActivities: nil)
        
        self.presentViewController(ActivityVC, animated: true, completion: nil)
        
        ActivityVC.completionWithItemsHandler = {(activity, success, items, error) in println("Activity: \(activity) Success: \(success) Items: \(items) Error: \(error)")
            
            if success == true {
            self.save()
            self.performSegueWithIdentifier("TableAndCollection", sender: sender)
            }
            
        }
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)        
    }
}

