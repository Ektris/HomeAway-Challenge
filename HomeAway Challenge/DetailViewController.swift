//
//  DetailViewController.swift
//  HomeAway Challenge
//
//  Created by Robert Carrier on 8/18/17.
//  Copyright © 2017 rwc. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!

    // MARK: - Properties
    var eventDict: Dictionary<String, Any?>? {
        didSet {
            self.configureView()
        }
    }
    var reloadMaster:(() -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let event = self.eventDict {
            hideDetails(show: false)
            
            self.title = event["title"] as? String
            
            if let label = self.dateLabel {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH.mm.ss"
                let date = dateFormatter.date(from: event["datetime_local"] as! String)
                dateFormatter.dateFormat = "E, d MMM yyyy HH:mm a"
                label.text = dateFormatter.string(from: date!)
            }
            
            if let label = self.locationLabel {
                label.text = (event["venue"] as! Dictionary<String, Any>)["display_location"] as? String
            }
            
            if let button = self.favoriteButton {
                if Favorites.check(id: event["id"] as! Int) {
                    button.image = UIImage(named: "Star_Filled")
//                    button.tintColor = .yellow
                } else {
                    button.image = UIImage(named: "Star")
                }
            }
        } else {
            hideDetails(show: true)
        }
    }
    
    func hideDetails(show: Bool) {
        if self.detailDescriptionLabel != nil {
            self.detailDescriptionLabel.isHidden = !show
        }
        
        if self.dateLabel != nil {
            self.dateLabel.isHidden = show
        }
        
        if self.locationLabel != nil {
            self.locationLabel.isHidden = show
        }
        
        if self.favoriteButton != nil {
            self.favoriteButton.isEnabled = !show
        }
    }
    
    // MARK: - Actions
    
    @IBAction func toggleFavorite() {
        if let event = self.eventDict, let id = event["id"] as? Int {
            if Favorites.check(id: id) {
                self.favoriteButton.image = UIImage(named: "Star")
                self.favoriteButton.tintColor = .white
                Favorites.remove(id: id)
            } else {
                self.favoriteButton.image = UIImage(named: "Star_Filled")
//                self.favoriteButton.tintColor = .yellow
                Favorites.save(id: id)
            }
            reloadMaster!()
        }
    }
}
