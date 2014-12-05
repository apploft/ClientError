//
//  ClientError.swift
//  WMD
//
//  Created by Michael Kamphausen on 07.11.14.
//  Copyright (c) 2014 apploft GmbH. All rights reserved.
//

import Foundation

class ClientError : PFObject, PFSubclassing {
    @NSManaged var domain: String?
    @NSManaged var code: Int
    @NSManaged var userInfo: [NSObject: AnyObject]?
    @NSManaged var installation: Installation?
    
    override class func load() {
        self.registerSubclass()
    }
    
    convenience init(error: NSError) {
        self.init()
        domain = error.domain
        code = error.code
        userInfo = error.userInfo
        installation = Installation.currentInstallation()
    }
    
    convenience init(domain: String?, code: Int?, userInfo: [NSObject: AnyObject]?) {
        self.init()
        self.domain = domain
        self.code = code != nil ? code! : 0
        self.userInfo = userInfo
        installation = Installation.currentInstallation()
    }
    
    class func parseClassName() -> String! {
        return "ClientError"
    }
    
    class func reportError(error: NSError) {
        ClientError(error: error).saveEventually()
    }
    
    class func reportError(domain: String?, code: Int?, userInfo: [NSObject: AnyObject]?) {
        ClientError(domain: domain, code: code, userInfo: userInfo).saveEventually()
    }
}
