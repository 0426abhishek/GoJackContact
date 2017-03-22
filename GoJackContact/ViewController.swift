//
//  ViewController.swift
//  GoJackContact
//
//  Created by APPLE on 3/2/17.
//  Copyright © 2017 APPLE. All rights reserved.
//

import UIKit
import AFNetworking

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

@IBOutlet var ErrorviewHt: NSLayoutConstraint!
@IBOutlet var ErrorView: UIView!
@IBOutlet var ContactTableView: UITableView!
@IBOutlet var PlusButton: UIButton!
let commonUtil = CommonFile()
var arrayOfContacts = [ContactMain]()
let reloadContact = Notification.Name(rawValue:"reloadContact")
internal let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
override func viewDidLoad() {
super.viewDidLoad()
    
//    let alertController = UIAlertController(title:"To get access of key", message: "Please Enter Your Apple Id", preferredStyle: .alert)
//    
//    let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
//        if let field = alertController.textFields?[0] {
//            // store your data
//              print(field.text ?? 0)
//               print(alertController.textFields?[1].text ?? 0)
//            UserDefaults.standard.set(field.text, forKey: "userEmail")
//            UserDefaults.standard.synchronize()
//        } else {
//            // user did not fill field
//        }
//    }
//    
//    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
//    
//    alertController.addTextField { (textField) in
//        textField.placeholder = "Email"
//    }
//    alertController.addTextField { (textField) in
//        textField.placeholder = "Password"
//    }
//    
//    alertController.addAction(confirmAction)
//    alertController.addAction(cancelAction)
//    self.present(alertController, animated: true, completion: nil)
    
let nc = NotificationCenter.default
nc.addObserver(forName:reloadContact, object:nil, queue:nil, using:catchNotification)

    ContactTableView.register(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "ContactCell")
ContactTableView.tableFooterView = UIView(frame: .zero)
self.navigationItem.title = "Contacts"
let addimage = UIImage(named: "Addd.png")
self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: addimage, style: UIBarButtonItemStyle.plain, target: self, action: #selector
    (addContact))
PlusButton.addTarget(self,action:#selector(addContact), for:.touchUpInside)
ErrorviewHt.constant=0
ErrorView.isHidden=true
self.loadContact()
}
func loadContact() {

if commonUtil.networkStatus() == false
{
    ErrorviewHt.constant=44;
    ErrorView.isHidden=false;
}
else{
    ErrorviewHt.constant=0;
    ErrorView.isHidden=true;
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("gojack.sqlite")
    // open database
    var db: OpaquePointer? = nil
    if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
        print("error opening database")
    }
    else{
        print("open")
    }
    //create Table logic
    let createSQL = "create table if not exists contact (id unique, firstname text, lastname text,profilepic text , url text)"
    if sqlite3_exec(db,createSQL, nil, nil, nil) != SQLITE_OK {
        let errmsg = String(cString: sqlite3_errmsg(db))
        print("error creating table: \(errmsg)")
    }
    var statement: OpaquePointer? = nil
    var contactArrayList = [Contact]()
    let url = "http://gojek-contacts-app.herokuapp.com/contacts.json"
    let manager = AFHTTPSessionManager()
    manager.get(url, parameters: nil, progress: nil, success: {(Operation,responseObject) in
        let jsonData = try! JSONSerialization.data(withJSONObject: responseObject!, options: JSONSerialization.WritingOptions.prettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        if let list = self.commonUtil.convertToDictionary(text: jsonString) as? [AnyObject] {
        for j in 0  ..< list.count
        {
            var ContactObj = Contact.init()
            ContactObj.id = String(describing: list[j].object(forKey: "id")!)
            ContactObj.Firstname = String(describing:list[j].object(forKey: "first_name")!)
            ContactObj.lastname = String(describing:list[j].object(forKey: "last_name")!)
            ContactObj.profilepic = String(describing:list[j].object(forKey: "profile_pic")!)
            ContactObj.url = String(describing:list[j].object(forKey: "url")!)
            contactArrayList.append(ContactObj)
            var statement: OpaquePointer? = nil
            //inserting data loigc in db
            let update = "INSERT INTO contact (id, firstname, lastname, profilepic, url) VALUES (?, ?, ?, ?, ?)"
            if sqlite3_prepare_v2(db, update, -1, &statement, nil) == SQLITE_OK {
                    sqlite3_bind_text(statement, 1,ContactObj.id, -1, nil);
                    sqlite3_bind_text(statement, 2,ContactObj.Firstname , -1, nil);
                    sqlite3_bind_text(statement, 3, ContactObj.lastname, -1, nil);
                    sqlite3_bind_text(statement, 4,ContactObj.profilepic, -1, nil);
                    sqlite3_bind_text(statement, 5,ContactObj.url, -1, nil);
                if sqlite3_step(statement) != SQLITE_DONE {
                    let errmsg = String(cString: sqlite3_errmsg(db))
                   // print("failure inserting data: \(errmsg)")
                }
                else{
                   // print("inserting data")
                }
                
            }
        }
            
//getting data Query Logic from Database

//      if sqlite3_prepare_v2(db, "select id, firstname from contact", -1, &statement, nil) != SQLITE_OK {
//                    let errmsg = String(cString: sqlite3_errmsg(db))
//                    print("error preparing select: \(errmsg)")
//                }
//                while sqlite3_step(statement) == SQLITE_ROW {
//                    let id = sqlite3_column_int64(statement, 0)
//                    print("id = \(id); ", terminator: "")
//                    
//                    let name = sqlite3_column_text(statement, 1)
//                    let nameString = String(cString: name!)
//                    print("name = \(nameString)")
//                }
          
            
            var nameDictionary: Dictionary<String, [Contact]> = [:]
            for name in contactArrayList {
                let index = name.Firstname!.index(name.Firstname!.startIndex, offsetBy: 1)
                let key = (name.Firstname!.substring(to: index) as String).capitalized
                if var arrayForLetter = nameDictionary[key] {
                    arrayForLetter.append(name)
                    nameDictionary.updateValue(arrayForLetter, forKey: key) // and we pass it to the dictionary
                } else { // if the key doesn't already exists in our dictionary
                    nameDictionary.updateValue([name], forKey: key) // we create an array with the name and add it to the dictionary
                }
            }
            var SubarrayOfContacts = [ContactMain]()
            
            for data in nameDictionary {
                var con = ContactMain.init()
                con.key = data.0
                con.Data = data.1
                SubarrayOfContacts.append(con)
            }
            
            self.arrayOfContacts = SubarrayOfContacts.sorted { $0.key?.localizedCaseInsensitiveCompare($1.key!) == ComparisonResult.orderedAscending }
            
           // print(self.arrayOfContacts);
            // DispatchQueue.main.async(execute: {
            self.ContactTableView.delegate = self
            self.ContactTableView.dataSource = self
            self.ContactTableView.reloadData()
            // });
            
        }
    }, failure: {(operation, error) in
        print("Error: " + error.localizedDescription)
    })
}
}

func numberOfSections(in tableView: UITableView) -> Int {
return arrayOfContacts.count
}

func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
let ArrMain = arrayOfContacts[section]

return ArrMain.key;
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
let array = arrayOfContacts[section]
return array.Data.count
}
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath as IndexPath) as! ContactCell
let ArrMain = arrayOfContacts[indexPath.section]
let ContactObj:Contact = ArrMain.Data[indexPath.row]
cell.StartLetterLabel.text=ArrMain.key
cell.ContactName.text = String.init(format: "%@ %@", ContactObj.Firstname!,ContactObj.lastname!)
cell.ContactName.font = cell.ContactName.font.withSize(14)
cell.StartLetterLabel.isHidden=false
if  ContactObj.profilepic == nil || ContactObj.profilepic == "/images/missing.png"{
cell.StartLetterLabel.isHidden=false

}else{
URLSession.shared.dataTask(with: NSURL(string: ContactObj.profilepic!)! as URL, completionHandler: { (data, response, error) -> Void in
    if error != nil {
       
        return
    }
    DispatchQueue.main.async(execute: { () -> Void in
        let image = UIImage(data: data!)
        cell.ContactImage.image = image
    })
}).resume()
cell.StartLetterLabel.isHidden=true
}
return cell
}

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

let view: ContactDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "ContactDetailVC") as! ContactDetailVC
let ArrMain = arrayOfContacts[indexPath.section]
let ContactObj:Contact = ArrMain.Data[indexPath.row]
view.url = ContactObj.url! as String
self.navigationController?.pushViewController(view, animated: true)
}
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
return 60
}

func addContact()
{
let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "AddContactVC") as! AddContactVC
self.navigationController!.pushViewController(secondViewController, animated: true)

}
override func didReceiveMemoryWarning() {
super.didReceiveMemoryWarning()
// Dispose of any resources that can be recreated.
}

func catchNotification(notification:Notification) -> Void {
        loadContact()
}
}

