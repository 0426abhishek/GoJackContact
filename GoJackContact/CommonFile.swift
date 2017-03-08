//
//  CommonFile.swift
//  GoJackContact
//
//  Created by APPLE on 3/6/17.
//  Copyright © 2017 APPLE. All rights reserved.
//

import UIKit
import SystemConfiguration

class CommonFile: NSObject {

func networkStatus() -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    
    var flags = SCNetworkReachabilityFlags()
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
        return false
    }
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    return (isReachable && !needsConnection)
        
    }


func serviceMethod(_ urlserviceparameter:String) -> NSDictionary {
    let url = URL(string: urlserviceparameter)
    let contentData = try? Data(contentsOf: url!)
    let contentRes = NSString(data: contentData!,encoding: String.Encoding.ascii.rawValue)
    var  JSONDictionary = NSDictionary()
    do{
        JSONDictionary = try JSONSerialization.jsonObject(with: contentRes!.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: true)!, options:.allowFragments) as! NSDictionary
    }
    catch let error{
        print("\(error)")
    }
    
    return JSONDictionary
}

func convertToDictionary(text: String) -> Any? {
    
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? Any
        } catch {
            print(error.localizedDescription)
        }
    }
    
    return nil
    
}


class func isValidEmail(testStr:String) -> Bool {
    print("validate calendar: \(testStr)")
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailTest:NSPredicate? = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    if emailTest != nil {
        return emailTest!.evaluate(with: testStr)
        
    }
    return false
}

    
    

}
