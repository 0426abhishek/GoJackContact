//
//  ContactEntity.swift
//  GoJackContact
//
//  Created by APPLE on 3/6/17.
//  Copyright © 2017 APPLE. All rights reserved.
//

import Foundation
struct Contact{
var id:String?
var Firstname:String?
var lastname:String?
var profilepic:String?
var url:String?
var favorite:String?

}
struct ContactMain {
var key:String?
var Data = [Contact]()
}
