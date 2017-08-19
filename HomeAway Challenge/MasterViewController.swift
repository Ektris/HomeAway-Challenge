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
        searchController.searchBar.sizeToFit()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let title = events[indexPath.row]["id"] as! Int
        cell.textLabel!.text = String(title)
        return cell
    }

    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
//                let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
//                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}
