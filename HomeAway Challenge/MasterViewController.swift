//
//  MasterViewController.swift
//  HomeAway Challenge
//
//  Created by Robert Carrier on 8/18/17.
//  Copyright © 2017 rwc. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, UISearchResultsUpdating {    
    // MARK: - Properties
    let searchController = UISearchController(searchResultsController: nil)
    var detailViewController: DetailViewController? = nil
    var events = [Dictionary<String, Any?>]()
    let connector = SeatGeekConnector.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the search bar
        self.searchController.searchResultsUpdater = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.searchBarStyle = .minimal
        self.navigationItem.titleView = searchController.searchBar
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.placeholderColor(color: .white)
        self.definesPresentationContext = true

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        // Deselect row when returning from details and not in a split view
        if let path = self.tableView.indexPathForSelectedRow, self.splitViewController!.isCollapsed {
            self.tableView.deselectRow(at: path, animated: animated)
        }

        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        // Only want to query if text is actually entered, otherwise you get everything when the search bar is given focus.
        if let text = searchController.searchBar.text, text.characters.count > 0 {
            self.connector.query(query: searchController.searchBar.text!) { results in
                self.events = results
                self.tableView.reloadData()
            }
        } else {
            // Clear results if search bar empty
            self.events.removeAll()
            self.tableView.reloadData()
        }
    }

    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventTableViewCell
        
        let event = self.events[indexPath.row]
        
        cell.titleLabel.text = event["title"] as? String
        
        cell.locationLabel.text = (event["venue"] as! Dictionary<String, Any>)["display_location"] as? String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH.mm.ss"
        let date = dateFormatter.date(from: event["datetime_local"] as! String)
        dateFormatter.dateFormat = "E, d MMM yyyy hh:mm a"
        cell.timeLabel.text = dateFormatter.string(from: date!)
        
        cell.favoriteImageView.isHidden = !Favorites.check(id: event["id"] as! Int)
        
        // Check for an image of the first given performer to present as a preview
        cell.tag = indexPath.row
        let performers = event["performers"] as! [Dictionary<String, Any>]
        if let imageUrl = performers[0]["image"] as? String {
            self.connector.loadImage(url: imageUrl) { image in
                DispatchQueue.main.async {
                    // Ensure image is assigned to correct cell, as could have scrolled before data was retrieved,
                    //     so check tag to see if still the right one visible at given path
                    if let cellToUpdate = tableView.cellForRow(at: indexPath) as? EventTableViewCell, cellToUpdate.tag == indexPath.row {
                        cellToUpdate.thumbnail.image = image
                    }
                }
            }
        } else {
            cell.thumbnail.image = UIImage(named: "Question_Mark")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Get more results if available
        //    If the current number of results is divisible by the page size, then it last pulled down a full page,
        //    which means another page may be available
        if (indexPath.row + 1) == events.count, (events.count % QueryConstants.pageSize) == 0 {
            self.connector.queryPage(query: searchController.searchBar.text!,
                                     page: ((events.count / QueryConstants.pageSize) + 1)) { results in
                self.events = self.events + results
                let indexPath = self.tableView.indexPathForSelectedRow
                self.tableView.reloadData()
                self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func refreshPulled(_ sender: UIRefreshControl) {
        updateSearchResults(for: self.searchController)
        sender.endRefreshing()
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let event = self.events[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.eventDict = event
                // If using split view, want to refresh the table if a favorite is toggled
                controller.reloadMaster = {
                    self.tableView.reloadData()
                    self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
                
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}
