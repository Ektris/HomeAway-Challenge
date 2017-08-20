//
//  UISearchBar+Color.swift
//  HomeAway Challenge
//
//  Created by Robert Carrier on 8/20/17.
//  Copyright © 2017 rwc. All rights reserved.
//

import UIKit

extension UISearchBar
{
    func placeholderColor(color: UIColor)
    {
        if let textField = self.value(forKey: "searchField") as? UITextField {
            if let placeholderLabel = textField.value(forKey: "placeholderLabel") as? UILabel {
                placeholderLabel.textColor = color
            }
        }
    }
}
