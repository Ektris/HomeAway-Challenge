//
//  MasterViewController.swift
//  HomeAway Challenge
//
//  Created by Robert Carrier on 8/18/17.
//  Copyright © 2017 rwc. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    let searchController = UISearchController(searchResultsController: nil)
    var detailViewController: DetailViewController? = nil
    var events = [Dictionary<String, Any?>]()
    let connector = SeatGeekConnector.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the search bar
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()// TODO: Fix Search Bar placement
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(searchController.searchBar)

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
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
        // Only want to query if text actually entered, otherwise you get everything when search bar given focus
        if let text = searchController.searchBar.text, text.characters.count > 0 {
            connector.query(query: searchController.searchBar.text!) { results in
                self.events = results
                self.tableView.reloadData()
            }
        } else {
            // Clear results if search bar empty
            events.removeAll()
        }
        
        self.tableView.reloadData()
    }

    // MARK: - Table View

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EventTableViewCell
        
        let event = events[indexPath.row]
        
        cell.titleLabel.text = event["title"] as? String
        cell.locationLabel.text = (event["venue"] as! Dictionary<String, Any>)["display_location"] as? String
        cell.timeLabel.text = event["datetime_local"] as? String // TODO: Convert to Date to be more readable
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Get more results if available
        //    If the current number of results is divisible by the page size, then it last pulled down a full page,
        //    which means another page may be available
        if (indexPath.row + 1) == events.count, (events.count % SeatGeekConnector.pageSize) == 0 {
            connector.queryPage(query: searchController.searchBar.text!,
                                page: ((events.count / SeatGeekConnector.pageSize) + 1)) { results in
                self.events = self.events + results
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let event = events[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.eventDict = event
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}
