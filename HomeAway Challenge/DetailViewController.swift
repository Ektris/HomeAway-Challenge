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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var performersLabel: UILabel!
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
            
            let frame = CGRect(x: 0, y: 0, width: (self.navigationController?.navigationBar.frame.width)!,
                               height: (self.navigationController?.navigationBar.frame.height)!)
            let titleLabel = UILabel(frame: frame)
            titleLabel.text = event["title"] as? String
            titleLabel.textColor = .white
            titleLabel.backgroundColor = .clear
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
            titleLabel.textAlignment = .center
            self.navigationItem.titleView = titleLabel
            
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
                dateFormatter.dateFormat = "E, d MMM yyyy hh:mm a"
                label.appendAttributedText(text: dateFormatter.string(from:date!), attributes: [NSForegroundColorAttributeName:UIColor.black])
            }
            
            if let label = self.locationLabel {
                label.appendAttributedText(text: ((event["venue"] as! Dictionary<String, Any>)["display_location"] as? String)!,
                                           attributes: [NSForegroundColorAttributeName:UIColor.black])
            }
            
            if let label = self.venueLabel {
                label.appendAttributedText(text: ((event["venue"] as! Dictionary<String, Any>)["name"] as? String)!,
                                           attributes: [NSForegroundColorAttributeName:UIColor.black])
            }
            
            if let label = self.performersLabel {
                let performers = event["performers"] as! [Dictionary<String, Any>]
                var performerNames = [String]()
                for i in 0..<performers.count {
                    performerNames.append(performers[i]["name"] as! String)
                }
                label.appendAttributedText(text: performerNames.joined(separator: ", "), attributes: [NSForegroundColorAttributeName:UIColor.black])
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
        
        if self.favoriteButton != nil {
            self.favoriteButton.isEnabled = !hide
        }
        
        if self.scrollView != nil {
            self.scrollView.isHidden = hide
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
