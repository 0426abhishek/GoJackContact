//
//  AddContactVC.swift
//  GoJackContact
//
//  Created by APPLE on 3/7/17.
//  Copyright © 2017 APPLE. All rights reserved.
//

import UIKit
import AFNetworking

class AddContactVC: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate {
@IBOutlet var PhoneNumberError: UILabel!
@IBOutlet var EmailError: UILabel!
@IBOutlet var FirstNameError: UILabel!
@IBOutlet var FavouriteCheckButton: UIButton!
@IBOutlet var EmailTextField: UITextField!
@IBOutlet var MobileNumberTextField: UITextField!
@IBOutlet var LastNameTextField: UITextField!
@IBOutlet var FirstNameTextField: UITextField!
@IBOutlet var SaveButton: UIButton!
@IBOutlet var ContactImage: UIImageView!
@IBOutlet var imageUpload:UIButton!
var ContactObj = Contact.init()
let commonUtil = CommonFile()
override func viewDidLoad() {
super.viewDidLoad()
ContactImage.layer.cornerRadius = ContactImage.frame.height/2
ContactImage.clipsToBounds = true
FirstNameError.isHidden=true
PhoneNumberError.isHidden=true
EmailError.isHidden=true
SaveButton.addTarget(self, action: #selector(saveButton), for: .touchUpInside)
FavouriteCheckButton.addTarget(self, action: #selector(checkButton), for: .touchUpInside)
imageUpload.addTarget(self, action: #selector(imageButton), for: .touchUpInside)
ContactObj.favorite = "0"
}

func textFieldDidBeginEditing(_ textField: UITextField) {
if(textField == LastNameTextField)
{
animateViewMoving(up:true, moveValue: 100)
}
else if(textField == MobileNumberTextField)
{
animateViewMoving(up: true, moveValue: 100)
}
else if(textField == EmailTextField)
{
animateViewMoving(up: true, moveValue: 150)
}

}

func textFieldDidEndEditing(_ textField: UITextField) {
if textField == FirstNameTextField {
if (FirstNameTextField.text?.characters.count)!<3 {

FirstNameError.isHidden=false
FirstNameError.text = "Length Should be >= to 3"

}else{

FirstNameError.isHidden=true

}
}



else if(textField == LastNameTextField)
{
animateViewMoving(up: false, moveValue: 100)
}
else if(textField == MobileNumberTextField)
{
animateViewMoving(up: false, moveValue: 100)
if self.MobileNumberTextField.text!.contains("+")
{
if self.MobileNumberTextField.text!.contains("+91") && self.MobileNumberTextField.text!.characters.count > 7
{
    PhoneNumberError.isHidden=true
    
}
else{
   PhoneNumberError.text = "Mobile Number Invalid"
    PhoneNumberError.isHidden=false
}
}
else{
if self.MobileNumberTextField.text!.characters.count > 5
{
     PhoneNumberError.isHidden=true
}
else{
    PhoneNumberError.text = "Mobile Number Invalid"
    PhoneNumberError.isHidden=false
}
}


}

else if(textField == EmailTextField)
{
animateViewMoving(up: false, moveValue: 150)
if  CommonFile.isValidEmail(testStr: EmailTextField.text!)
{
EmailError.isHidden=true
}else{
EmailError.isHidden=false
}
}
}
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
textField.resignFirstResponder()
return true
}

override func didReceiveMemoryWarning() {
super.didReceiveMemoryWarning()
// Dispose of any resources that can be recreated.
}

func saveButton()
{
if commonUtil.networkStatus() == false
{
let alert = UIAlertController(title:nil, message: "Network Error", preferredStyle: UIAlertControllerStyle.alert)
alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (action: UIAlertAction!) in
    self.saveButton()
}))

alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
    
}))
present(alert, animated: true, completion: nil)

}
else{
if FirstNameError.isHidden == false || PhoneNumberError.isHidden == false
{
let alert = UIAlertController(title: nil, message: "Please Enter FirstName and Mobile No", preferredStyle: UIAlertControllerStyle.alert)
alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
self.present(alert, animated: true, completion: nil)
}
else{
let alertController = UIAlertController(title: nil, message: "Please wait\n\n", preferredStyle: .alert)
let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
spinnerIndicator.color = UIColor.black
spinnerIndicator.startAnimating()
alertController.view.addSubview(spinnerIndicator)
self.present(alertController, animated: false, completion: nil)
let urlString = "http://gojek-contacts-app.herokuapp.com/contacts"
let parameters = ["first_name": (FirstNameTextField.text?.addingPercentEscapes(using: String.Encoding.utf8))!, "last_name":(LastNameTextField.text?.addingPercentEscapes(using: String.Encoding.utf8))!,"email":(EmailTextField.text?.addingPercentEscapes(using: String.Encoding.utf8))!,"phone_number":(MobileNumberTextField.text?.addingPercentEscapes(using: String.Encoding.utf8))!,"profile_pic":"abcd.jpg","favorite":ContactObj.favorite!] as Dictionary<String, String>
    print(parameters)

let manager = AFHTTPSessionManager()
manager.requestSerializer = AFJSONRequestSerializer()
manager.responseSerializer = AFHTTPResponseSerializer()
manager.post(urlString, parameters: parameters, success:
{
    requestOperation, response in
let result = NSString(data: (response as! NSData) as Data, encoding: String.Encoding.utf8.rawValue)!
let nc = NotificationCenter.default
nc.post(name:Notification.Name(rawValue:"reloadContact"),
            object: nil,
            userInfo: nil)
alertController.dismiss(animated: true, completion: nil)
self.navigationController?.popViewController(animated: true)

},failure:
{
    requestOperation, error in
    print(error)
    alertController.dismiss(animated: true, completion: nil)
    
})

}
}
}
func checkButton()
{
if self.FavouriteCheckButton.currentImage == UIImage(named: "UncheckedCircle.png")
{
self.FavouriteCheckButton.setImage(UIImage(named: "okchecked.png"), for: UIControlState.normal)
ContactObj.favorite = "1"
}
else{
self.FavouriteCheckButton.setImage(UIImage(named: "UncheckedCircle.png"), for: UIControlState.normal)
ContactObj.favorite = "0"
}
}

func animateViewMoving (up:Bool, moveValue :CGFloat){
let movementDuration:TimeInterval = 0.3
let movement:CGFloat = ( up ? -moveValue : moveValue)
UIView.beginAnimations( "animateView", context: nil)
UIView.setAnimationBeginsFromCurrentState(true)
UIView.setAnimationDuration(movementDuration )
self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
UIView.commitAnimations()
}


func imageButton()
{
let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Gallery", "Camera")
actionSheet.show(in: self.view)

}
func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
{
switch (buttonIndex){
case 0:
print("Cancel")
case 1:
if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
    imagePicker.allowsEditing = true
    self.present(imagePicker, animated: true, completion: nil)
}

case 2:
if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
    imagePicker.allowsEditing = false
    self.present(imagePicker, animated: true, completion: nil)
}
default:
print("Default")

}
}

func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
ContactImage.image = image
self.dismiss(animated: true, completion: nil);
}
    
func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }

}
