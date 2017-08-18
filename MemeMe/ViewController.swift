//
//  ViewController.swift
//  MemeMe
//
//  Created by Corley, Tyler on 8/17/17.
//  Copyright © 2017 Corley, Tyler. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: - UI Elements
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    // MARK: - Instance Objects
    struct Meme {
        var image, meme: UIImage?
        var topText, bottomText: String?
    }
    
    let impactTextAttributes: [String: Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40) as Any,
        NSStrokeWidthAttributeName: -3.0
    ]
    
    var meme: Meme = Meme(image: nil, meme: nil, topText: nil, bottomText: nil)
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        UIApplication.shared.statusBarStyle = .lightContent
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do I need the self before?
        self.bottomTextField.defaultTextAttributes = impactTextAttributes
        self.topTextField.defaultTextAttributes = impactTextAttributes
        
        self.bottomTextField.textAlignment = .center
        self.topTextField.textAlignment = .center
        
        self.bottomTextField.delegate = self
        self.topTextField.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        
    }
    
    // MARK: - Actions
    @IBAction func shareMeme(_ sender: Any) {
        checkReadyToShare()
        let shareSheet = UIActivityViewController(activityItems: [self.meme.meme!], applicationActivities: nil)
        present(shareSheet, animated: true, completion: nil)
    }
    
    @IBAction func cancelMeme(_ sender: Any) {
        (self.meme.topText, self.meme.bottomText, self.meme.image, self.meme.meme) = (nil, nil, nil, nil)
        (self.topTextField.text, self.bottomTextField.text, self.memeImageView.image) = (nil, nil, nil)
        self.shareButton.isEnabled = false
    }
    
    @IBAction func shareFromCamera(_ sender: Any) {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        present(cameraPicker, animated: true, completion: nil)
    }
    
    @IBAction func shareFromAlbum(_ sender: Any) {
        let albumPicker = UIImagePickerController()
        albumPicker.delegate = self
        albumPicker.sourceType = .photoLibrary
        albumPicker.modalPresentationStyle = .overCurrentContext
        present(albumPicker, animated: true, completion: nil)
    }
    
    // MARK: - ImagePicker Delegate Functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.memeImageView.image = image
            self.meme.image = image
            checkReadyToShare()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    }
    
    // MARK: - TextField Delegate Functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Need to find out what text field just finished and assing the value to the struct, or just set the values of both
        if let string: String = topTextField.text {
            self.meme.topText = string
        }
        if let string: String = bottomTextField.text {
            self.meme.bottomText = string
        }
        checkReadyToShare()
    }
    
    // MARK: - Keyboard Show/Hide
    // FIXME: bottom content will move up, but the top tool bar, top text, and image will float back into position??
    func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 && bottomTextField.isEditing {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    // MARK: - Kitchen Sink
    func checkReadyToShare() {
        // have to check for "" strings not nil
        if let top: String = self.meme.topText, let bottom: String = self.meme.bottomText, let _: UIImage = self.meme.image {
            if top != "" && bottom != "" {
                self.meme.meme = generateMemedImage()
                self.shareButton.isEnabled = true
            } else { self.shareButton.isEnabled = false }
        } else { self.shareButton.isEnabled = false }
    }
    
    func generateMemedImage() -> UIImage {
        
        // Render view to an image
        self.topToolbar.isHidden = true
        self.bottomToolbar.isHidden = true
        UIGraphicsBeginImageContext(self.view.bounds.size)
        view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.topToolbar.isHidden = false
        self.bottomToolbar.isHidden = false
        
        return memedImage
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    //TODO: Create a function that moves the texts within the bounds of the imaged
    
}

