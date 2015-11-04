//
//  SignatureHandler.swift
//  UnfoldingWord
//
//  Created by David Solberg on 11/4/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import Foundation

@objc class SignatureHandler : NSObject {
    static func bareSignatureStringFromString(sig : String) -> String
    {
        // See if the signature is inside a json string; else return the raw string
        if let
            sigData = sig.dataUsingEncoding(NSUTF8StringEncoding),
            json = try? NSJSONSerialization.JSONObjectWithData(sigData, options: NSJSONReadingOptions.AllowFragments),
            array = json as? Array<AnyObject>,
            dictionary = array.first as? Dictionary<String,String>,
            signature = dictionary["sig"] {
                return signature
        }
        else {
            return sig
        }
    }
}
