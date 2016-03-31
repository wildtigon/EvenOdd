//
//  SearchWikiViewController.swift
//  EvenOdd
//
//  Created by Nguyễn Tiến Đạt on 3/29/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension SearchWikiViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

class SearchWikiViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //Variables
    let searchController = UISearchController(searchResultsController: nil)
    //IBOutlets
    @IBOutlet weak var ibTableView: UITableView!
    
    
    override func viewDidLoad() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        ibTableView.tableHeaderView = searchController.searchBar
        
        configureTableDataSource()
        configureKeyboardDismissesOnScroll()
        configureNavigateOnRowClick()
        configureActivityIndicatorsShow()
    }
    
    //Functions
    
    private func configureActivityIndicatorsShow(){
        Driver.combineLatest(
            DefaultWikipediaAPI.sharedAPI.loadingWikipediaData, // $0
            DefaultImageService.sharedImageService.loadingImage // $1
        ) { $0 || $1 }
            .distinctUntilChanged()
            .drive(UIApplication.sharedApplication().rx_networkActivityIndicatorVisible)
            .addDisposableTo(disposeBag)
    }
    
    private func configureNavigateOnRowClick(){
        let wireframe = DefaultWireframe.sharedInstance
        
        ibTableView.rx_modelSelected(SearchResultViewModel.self)
            .asDriver()
            .driveNext{searchResult in
                wireframe.openURL(searchResult.searchResult.URL)
            }
            .addDisposableTo(disposeBag)
    }
    
    private func configureKeyboardDismissesOnScroll(){
        let searchBar = searchController.searchBar
        ibTableView.rx_contentOffset
            .asDriver()
            .driveNext { _ in
                if searchBar.isFirstResponder(){
                    _ = searchBar.resignFirstResponder()
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    private func configureTableDataSource(){
        ibTableView.registerNib(UINib(nibName: "WikipediaSearchCell", bundle: nil), forCellReuseIdentifier: "WikipediaSearchCell")
        ibTableView.rowHeight = 194
        
        let API = DefaultWikipediaAPI.sharedAPI
        
        searchController.searchBar.rx_text
            .asDriver()
            .throttle(0.3)
            .distinctUntilChanged()
            .flatMapLatest{query in
                API.getSearchResults(query)
                    .retry(3)
                    .retryOnBecomesReachable([], reachabilityService: ReachabilityService.sharedReachabilityService)
                    .startWith([])
                    .asDriver(onErrorJustReturn: [])
            }
            .map{results in
                results.map(SearchResultViewModel.init)}
            .drive(ibTableView.rx_itemsWithCellIdentifier("WikipediaSearchCell", cellType: WikipediaSearchCell.self)) { (_, viewModel, cell) in
                cell.viewModel = viewModel
            }
            .addDisposableTo(disposeBag)
    }
    
    //
    //Search
    //
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        ibTableView.reloadData()
    }
    
    //
    //Table
    //
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellWiki", forIndexPath: indexPath)
        
        return cell
    }
    
    
    
}
