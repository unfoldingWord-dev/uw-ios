//
//  UINib-Extensions.swift
//  My2020
//
//  Created by David Solberg on 10/26/15.
//  Copyright © 2015 David Solberg. All rights reserved.
//

import Foundation
import UIKit

extension UINib {

    static func viewForName(name : String) -> UIView {
        let views = NSBundle.mainBundle().loadNibNamed(name, owner: nil, options: nil)
        let view = views.first
        return view! as! UIView
    }
}
