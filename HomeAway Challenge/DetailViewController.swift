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
    @IBOutlet weak var imageView: UIImageView!
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
    let connector = SeatGeekConnector.shared

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
            hideDetails(false)
            
            self.title = event["title"] as? String
            
            if let imgView = self.imageView {
                let performers = event["performers"] as! [Dictionary<String, Any>]
                if let imageUrl = performers[0]["image"] as? String {
                    self.connector.loadImage(url: imageUrl) { image in
                        imgView.image = image
                    }
                } else {
                    imgView.removeFromSuperview()
                }
            }
            
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
                } else {
                    button.image = UIImage(named: "Star")
                }
            }
        } else {
            hideDetails(true)
        }
    }
    
    func hideDetails(_ hide: Bool) {
        if self.detailDescriptionLabel != nil {
            self.detailDescriptionLabel.isHidden = !hide
        }
        
        if self.imageView != nil {
            self.imageView.isHidden = hide
        }
        
        if self.dateLabel != nil {
            self.dateLabel.isHidden = hide
        }
        
        if self.locationLabel != nil {
            self.locationLabel.isHidden = hide
        }
        
        if self.favoriteButton != nil {
            self.favoriteButton.isEnabled = !hide
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
                Favorites.save(id: id)
            }
            reloadMaster!()
        }
    }
}
