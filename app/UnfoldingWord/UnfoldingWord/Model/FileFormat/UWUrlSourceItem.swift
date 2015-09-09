//
//  UrlContent.swift
//  UnfoldingWord
//
//  Created by David Solberg on 6/16/15.
//

import Foundation

enum UrlContentType {
    case USFM(NSString)
    case OpenBibleStories(NSString)
    case Signature(NSString)
    case None(NSString)
}

/// This is really just a container to allow checking of the type of content in a url scheme. Technically, this is unnecessary when the content is always correct.
struct UrlSourceItem {
    
    let url : NSString
    let content : NSString
    
    init(url: NSString, content: NSString) {
        self.url = url
        self.content = content
    }
    
    var type : UrlContentType {
        get {
            if url.containsString("usfm") {
                return UrlContentType.USFM(content)
            }
            else if let
                data = content.dataUsingEncoding(NSUTF8StringEncoding),
                json: AnyObject = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
            {
                if let // If the top level is a dictionary with an object for the open bible stories, assign that open bible type
                    dictionary = json as? NSDictionary,
                    book = dictionary[Constants.URLSource.open_chapter] as? NSArray
                {
                    return UrlContentType.OpenBibleStories(content)
                }
                else if let array = json as? NSArray {
                    if array.count > 0 {
                        if let // if top level is an array with a dictionary with an object for signature, assign signature type
                            dictionary = array.firstObject as? NSDictionary,
                            signature = dictionary[Constants.URLSource.signature] as? NSString
                        {
                            return UrlContentType.Signature(content)
                        }
                    }
                }
            }
            return UrlContentType.None("Error for url \(url)")
        }
    }
}