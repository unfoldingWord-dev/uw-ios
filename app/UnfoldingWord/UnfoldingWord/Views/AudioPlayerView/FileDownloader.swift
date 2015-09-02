//
//  FileDownloader.swift
//  UnfoldingWord
//
//  Created by David Solberg on 9/1/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation
import UIKit

class FileDownloader : NSObject, NSURLSessionDelegate {
    
    let url : NSURL
    let completion : AudioDownloadCompletionBlock
    let progress : AudioDownloadProgressBlock?
    
    var task : NSURLSessionTask?
    var downloadedData : NSData?
    
    var bytesWrittenSoFar : Int64 = 0
    var bytesExpected : Int64 = 0
    
    
    var percentDone : Float {
        get {
            if bytesExpected <= 0 {
                return 0
            }
            else {
                return Float(bytesWrittenSoFar) / Float(bytesExpected)
            }
        }
    }
    
    lazy var session : NSURLSession = {
        let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        return session
    }()
    
    init (url: NSURL, progress : AudioDownloadProgressBlock?,  completion : AudioDownloadCompletionBlock) {
        self.url = url
        self.progress = progress
        self.completion = completion
        super.init()
    }
    
        deinit {
        if let currentTask = self.task where currentTask.state != NSURLSessionTaskState.Canceling {
            currentTask.cancel()
        }
    }
    
    func download() {
        
        if self.downloadedData != nil { // No need to download again
            return
        }
        
        if self.task == nil {
            let request = NSMutableURLRequest(URL:self.url)
            self.task = self.session.downloadTaskWithRequest(request)
        }
        self.task?.resume()
    }
    
    // NSURLSessionDownloadDelegate Methods
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten written: Int64, totalBytesExpectedToWrite expected: Int64) {
        self.bytesWrittenSoFar = written
        self.bytesExpected = expected
        if let progress = self.progress {
            progress(percentDone: percentDone)
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {}
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let error = error {
            completion(success: false, data: nil)
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        self.downloadedData = NSData(contentsOfURL: location)
        completion(success: true, data: self.downloadedData)
    }
    
}
