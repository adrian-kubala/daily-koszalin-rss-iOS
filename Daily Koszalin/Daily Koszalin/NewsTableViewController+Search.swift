//
//  NewsTableViewController+Search.swift
//  Daily Koszalin
//
//  Created by Adrian on 12.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

extension NewsTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        guard let searchText = searchBar.text, let scopeTitles = searchBar.scopeButtonTitles else {
            return
        }
        
        let scope = scopeTitles[searchBar.selectedScopeButtonIndex]
        
        filterContentForSearchText(searchText, scope: scope)
    }
}

extension NewsTableViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let searchText = searchBar.text, let scopeTitles = searchBar.scopeButtonTitles else {
            return
        }
        
        filterContentForSearchText(searchText, scope: scopeTitles[selectedScope])
    }
}
