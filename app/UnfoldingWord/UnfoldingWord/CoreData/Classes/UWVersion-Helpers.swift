//
//  UWVersion-Helpers.swift
//  UnfoldingWord
//
//  Created by David Solberg on 12/11/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import Foundation

extension UWVersion {
    
    func downloadedMediaTypes() -> [MediaType]?
    {
        guard self.statusText().contains(.All) else {
            return nil
        }
        
        let hasAudio = self.statusAudio().contains(.All)
        let hasVideo = self.statusVideo().contains(.All)
        
        switch (hasAudio, hasVideo) {
        case (true, true):
            return [.Text, .Audio, .Video]
        case (true, false):
            return [.Text, .Audio]
        case (false, true):
            return [.Text, .Video]
        case (false, false):
            return [.Text]
        }
    }
}
