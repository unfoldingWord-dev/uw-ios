//
//  UrlContent.swift
//  UnfoldingWord
//
//  Created by David Solberg on 6/16/15.
//

import Foundation

enum UrlContentType {
    case USFM(String)
    case OpenBibleStories(String)
    case Signature(String)
    case None(String)
}

/// This is really just a container to allow checking of the type of content in a url scheme. Technically, this is unnecessary when the content is always correct.
struct UrlSourceItem {
    
    let url : String
    let content : String
    
    init(url: String, content: String) {
        self.url = url
        self.content = content
    }
    
    var type : UrlContentType {
        get {
            if url.localizedCaseInsensitiveContains("usfm") {
                return UrlContentType.USFM(content)
            }
            else if
                let data = content.data(using: String.Encoding.utf8),
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            {
                // If the top level is a dictionary with an object for the open bible stories, assign that open bible type
                if let dictionary = json as? NSDictionary,
                   let _ = dictionary[Constants.URLSource.open_chapter] as? NSArray
                {
                    return UrlContentType.OpenBibleStories(content)
                }
                else if let array = json as? NSArray {
                    if array.count > 0 {
                        // if top level is an array with a dictionary with an object for signature, assign signature type
                        if let dictionary = array.firstObject as? NSDictionary,
                           let _ = dictionary[Constants.URLSource.signature] as? NSString
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
