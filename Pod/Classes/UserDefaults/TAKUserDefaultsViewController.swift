//
//  TAKUserDefaultsViewController.swift
//  TAKKitSwift
//
//  Created by Takahiro Ooishi
//  Copyright (c) 2015 Takahiro Ooishi. All rights reserved.
//  Released under the MIT license.
//

import Foundation
import UIKit

public class TAKUserDefaultsViewController: UIViewController {
  @IBOutlet private weak var tableView: UITableView!
  
  private let userDefaults = UserDefaults()
  private var keys: [String] {
    return userDefaults.allKeys
  }

  private var searchController: UISearchController
  private var resultsController: TAKUserDefaultsSearchResultController
  
  public class func instantiate() -> TAKUserDefaultsViewController? {
    let storyboard = TAKUserDefaultsBundleHelper.storyboard()
    return storyboard.tak_instantiateViewController(TAKUserDefaultsViewController.self)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    resultsController = TAKUserDefaultsSearchResultController(userDefaults: userDefaults)
    searchController = UISearchController(searchResultsController: resultsController)
    
    super.init(coder: aDecoder)
  }
  
  public override func viewDidLoad() {
    setupTableView()
    setupResultsController()
    setupSearchController()
    
    tableView.tableHeaderView = searchController.searchBar
    
    definesPresentationContext = true
  }
}

// MARK: - Private Methods

extension TAKUserDefaultsViewController {
  private func setupResultsController() {
    resultsController.tableView.delegate = self
  }
  
  private func setupSearchController() {
    searchController.searchResultsUpdater = self
    searchController.searchBar.sizeToFit()
    searchController.delegate = self
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
    
    if #available(iOS 9.0, *) {
      searchController.loadViewIfNeeded()
    }
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.estimatedRowHeight = 108.0
    tableView.rowHeight = UITableViewAutomaticDimension
    
    if let bundle = TAKUserDefaultsBundleHelper.bundle() {
      tableView.tak_registerClassAndNibForCell(TAKUserDefaultsViewCell.self, bundle: bundle)
    }
  }
}

extension TAKUserDefaultsViewController: UITableViewDataSource {
  public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return keys.count
  }
  
  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.tak_forceDequeueReusableCell(TAKUserDefaultsViewCell.self, indexPath: indexPath)
    cell.backgroundColor = tableView.backgroundColor
    
    let key = keys[indexPath.row]
    cell.bind(key, value: userDefaults[key])
    
    return cell
  }
}

// MARK: - UITableViewDelegate

extension TAKUserDefaultsViewController: UITableViewDelegate {
  public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}

// MARK: - UISearchBarDelegate

extension TAKUserDefaultsViewController: UISearchBarDelegate {
  public func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
}

// MARK: - UISearchControllerDelegate

extension TAKUserDefaultsViewController: UISearchControllerDelegate {
}

// MARK: - UISearchResultsUpdating

extension TAKUserDefaultsViewController: UISearchResultsUpdating {
  public func updateSearchResultsForSearchController(searchController: UISearchController) {
    guard let searchText = searchController.searchBar.text else { return }
    
    if let c = self.searchController.searchResultsController as? TAKUserDefaultsSearchResultController {
      c.updateKeys(userDefaults.filteredKeys(searchText))
    }
  }
}
