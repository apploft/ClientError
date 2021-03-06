//
//  ClientError.swift
//
//  Created by Michael Kamphausen on 07.11.14.
//  Copyright (c) 2014 apploft GmbH. All rights reserved.
//

import Foundation

class ClientError : PFObject, PFSubclassing {
    @NSManaged var domain: String?
    @NSManaged var code: Int
    @NSManaged var userInfo: [NSObject: AnyObject]?
    @NSManaged var installation: PFInstallation?
    
    override class func load() {
        self.registerSubclass()
    }
    
    convenience init(error: NSError) {
        self.init()
        domain = error.domain
        code = error.code
        userInfo = error.userInfo
        installation = PFInstallation.currentInstallation()
    }
    
    convenience init(domain: String?, code: Int?, userInfo: [NSObject: AnyObject]?) {
        self.init()
        self.domain = domain
        self.code = code != nil ? code! : 0
        self.userInfo = userInfo
        installation = PFInstallation.currentInstallation()
    }
    
    class func parseClassName() -> String! {
        return "ClientError"
    }
    
    class func reportError(error: NSError) {
        ClientError(error: error).saveEventually(nil)
    }
    
    class func reportError(domain: String?, code: Int?, userInfo: [NSObject: AnyObject]?) {
        ClientError(domain: domain, code: code, userInfo: userInfo).saveEventually(nil)
    }
}
