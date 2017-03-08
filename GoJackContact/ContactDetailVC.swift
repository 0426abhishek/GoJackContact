//
//  ContactDetailVC.swift
//  GoJackContact
//
//  Created by APPLE on 3/7/17.
//  Copyright © 2017 APPLE. All rights reserved.
//
import UIKit
import AFNetworking
import MessageUI
class ContactDetailVC: UIViewController,MFMailComposeViewControllerDelegate {

@IBOutlet var ContactEmailId: UILabel!
@IBOutlet var ContactNumber: UILabel!
@IBOutlet var ContactName: UILabel!
@IBOutlet var ContactImage: UIImageView!
@IBOutlet var LetterLabel: UILabel!
@IBOutlet var FavoriteContact:UIButton!
@IBOutlet var CallButton :UIButton!
@IBOutlet var EmailButton :UIButton!
var url:String!
let commonUtil = CommonFile()
override func viewDidLoad() {
super.viewDidLoad()
ContactImage.layer.cornerRadius = ContactImage.frame.height/2
ContactImage.clipsToBounds = true
LetterLabel.layer.cornerRadius = LetterLabel.frame.height/2
LetterLabel.clipsToBounds = true
FavoriteContact.addTarget(self, action:#selector(favoriteButton(sender:)), for: .touchUpInside)
EmailButton.addTarget(self, action:#selector(emailClick), for:.touchUpInside)
CallButton.addTarget(self, action:#selector(callClick), for: .touchUpInside)

DispatchQueue.global(qos: .background).async {
var dictionay : NSDictionary!
dictionay = self.commonUtil.serviceMethod(self.url!)
DispatchQueue.main.async {
    self.ContactName.text = String.init(format: "%@ %@", dictionay.object(forKey: "first_name")! as! CVarArg,dictionay.object(forKey: "last_name")! as! CVarArg)
   if(dictionay.object(forKey: "phone_number") != nil)
   {
    self.ContactNumber.text = dictionay.object(forKey: "phone_number") as? String
    
   }
    if(dictionay.object(forKey: "email") != nil)
    {
    self.ContactEmailId.text =  dictionay.object(forKey: "email") as? String
    }
    if  dictionay.object(forKey: "profile_pic") as! String? == nil || dictionay.object(forKey: "profile_pic") as! String? == "/images/missing.png"{
        self.LetterLabel.isHidden=false
        self.ContactImage.isHidden = true
        let nameString = String(describing: dictionay.object(forKey: "first_name")!)
     self.LetterLabel.text = String(nameString[nameString.startIndex])
    }else{
        URLSession.shared.dataTask(with: NSURL(string: dictionay.object(forKey: "profile_pic") as! String)! as URL, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.ContactImage.image = image
            })
        }).resume()
        self.LetterLabel.isHidden=true
        self.ContactImage.isHidden = false
    }
    if(dictionay.object(forKey: "favorite") as! Bool)
    {
        self.FavoriteContact.setImage(UIImage(named: "Hearts.png"), for: UIControlState.normal)
    }
    
}
}

}
func callClick()
{
if ContactNumber.text != nil
{
UIApplication.shared.openURL(NSURL(string:String.init(format: "telprompt:%@", ContactNumber.text!))! as URL)
}
}

func emailClick()
{
if ContactEmailId.text != nil
{
if MFMailComposeViewController.canSendMail() {
let mail = MFMailComposeViewController()
mail.mailComposeDelegate = self
mail.setToRecipients([ContactEmailId.text!])
mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
present(mail, animated: true)
} else {
let sendMailErrorAlert = UIAlertView(title: "Unable to Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
sendMailErrorAlert.show()

}
}
}
func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
controller.dismiss(animated: true)
}
func favoriteButton(sender: UIButton){
if(self.FavoriteContact.currentImage == UIImage(named: "LikeFilled.png"))
{
self.FavoriteContact.setImage(UIImage(named: "Hearts.png"), for: UIControlState.normal)
}
else{
self.FavoriteContact.setImage(UIImage(named: "LikeFilled.png"), for: UIControlState.normal)
}
}
override func didReceiveMemoryWarning() {
super.didReceiveMemoryWarning()
// Dispose of any resources that can be recreated.
}

}

