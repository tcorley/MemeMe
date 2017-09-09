//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Corley, Tyler on 8/17/17.
//  Copyright © 2017 Corley, Tyler. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: - UI Elements
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    // MARK: - Instance Objects
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
        self.setNeedsStatusBarAppearanceUpdate()
        UIApplication.shared.statusBarStyle = .lightContent
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = false
        clearButton.isEnabled = false
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField(textField: self.bottomTextField, withAlignment: .center, andDefaultAttributes: impactTextAttributes)
        configureTextField(textField: self.topTextField, withAlignment: .center, andDefaultAttributes: impactTextAttributes)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    // MARK: - Actions
    @IBAction func shareMeme(_ sender: Any) {
        let completeMeme = generateMemedImage()
        let shareSheet = UIActivityViewController(activityItems: [completeMeme], applicationActivities: nil)
        shareSheet.completionWithItemsHandler = {
            (_,successful,_,_) in
            self.saveMeme(meme: completeMeme)
        }
        present(shareSheet, animated: true, completion: nil)
    }
    
    @IBAction func cancelMeme(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clearMeme(_ sender: Any) {
        (self.meme.topText, self.meme.bottomText, self.meme.image, self.meme.meme) = (nil, nil, nil, nil)
        (self.topTextField.text, self.bottomTextField.text, self.memeImageView.image) = (nil, nil, nil)
        self.shareButton.isEnabled = false
        self.clearButton.isEnabled = false
    }
    
    @IBAction func shareFromCamera(_ sender: Any) {
        presentImagePickerWith(sourceType: .camera)
    }
    
    @IBAction func shareFromAlbum(_ sender: Any) {
        presentImagePickerWith(sourceType: .photoLibrary)
    }
    
    // MARK: - ImagePicker Delegate Functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.memeImageView.image = image
            checkReadyToShare()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TextField Delegate Functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkReadyToShare()
    }
    
    // MARK: - Keyboard Show/Hide
    // FIXME: bottom content will move up, but the top tool bar, top text, and image will float back into position??
    func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 && bottomTextField.isFirstResponder {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 && bottomTextField.isFirstResponder {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    // MARK: - Kitchen Sink
    func checkReadyToShare() {
        // have to check for "" strings not nil
        if let top: String = topTextField.text, let bottom: String = bottomTextField.text, let _: UIImage = memeImageView.image {
            if top != "" && bottom != "" {
                self.shareButton.isEnabled = true
            } else { self.shareButton.isEnabled = false }
        } else { self.shareButton.isEnabled = false }
        if topTextField.hasText || bottomTextField.hasText || memeImageView.image != nil {
            self.clearButton.isEnabled = true
        }
    }
    
    func generateMemedImage() -> UIImage {
        // Render view to an image
        configureToolbars(hidden: true)
        UIGraphicsBeginImageContext(self.view.bounds.size)
        view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        configureToolbars(hidden: false)
        
        return memedImage
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func configureTextField(textField: UITextField, withAlignment alignment: NSTextAlignment, andDefaultAttributes defaultAttributes: [String: Any]) {
        textField.defaultTextAttributes = defaultAttributes
        textField.textAlignment = alignment
        textField.delegate = self
    }
    
    func saveMeme(meme: UIImage) {
        self.meme = Meme(image: memeImageView.image, meme: meme, topText: topTextField.text, bottomText: bottomTextField.text)
        
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(self.meme)
        
        dismiss(animated: true, completion: nil)
    }
    
    func presentImagePickerWith(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.modalPresentationStyle = .overCurrentContext
        present(imagePicker, animated: true, completion: nil)
    }
    
    func configureToolbars(hidden: Bool) {
        self.topToolbar.isHidden = hidden
        self.bottomToolbar.isHidden = hidden
    }
    
}

