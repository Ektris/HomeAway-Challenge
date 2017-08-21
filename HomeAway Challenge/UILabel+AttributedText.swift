//
//  UILabel+AttributedText.swift
//  HomeAway Challenge
//
//  Created by Robert Carrier on 8/20/17.
//  Copyright © 2017 rwc. All rights reserved.
//

import UIKit

extension UILabel
{
    func appendAttributedText(text: String, attributes: [String:Any])
    {
        let title = self.attributedText as! NSMutableAttributedString
        let value = NSMutableAttributedString(string: " \(text)", attributes: attributes)
        title.append(value)
        self.attributedText = title
    }
}
