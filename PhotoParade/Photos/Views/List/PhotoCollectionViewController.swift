//
//  PhotoCollectionViewController.swift
//  HEBBuddy
//
//  Created by Cervenka, Michelle on 12/8/17.
//  Copyright © 2017 Michelle Cervenka. All rights reserved.
//

import UIKit

private enum State {
    case none
    case initial
    case searching
    case searched
}

class PhotoCollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityView: PhotoSearchTableStateView!
    
    let photoService = PhotoService(photoProvider: Flickr())
    
    private var photosViewModel = PhotosViewModel(
        searchTerm: nil,
        totalMatches: .noTotal,
        photos: [Int: PhotoViewModel]()) {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var currentState = State.none {
        didSet {
            switch currentState {
            case .initial:
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                activityView.showInitial()
            case .searching:
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                activityView.showSearching()
            case .searched:
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                activityView.showSearched(count: photosViewModel.photos.count)
            case .none:
                activityView.showNothing()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let columnLayout = ColumnFlowLayout(
            lines: 2,
            minimumInteritemSpacing: 5,
            minimumLineSpacing: 5,
            sectionInset: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        )
        
        collectionView.collectionViewLayout = columnLayout
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.prefetchDataSource = self
        
        currentState = .initial
        
        //Seed the search
        search(PhotoRequest(searchTerm: "Fruit faces", page: 1))
    }
}

// MARK: - UICollectionViewDataSource
extension PhotoCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosViewModel.totalMatches.totalIfAny ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as? PhotoCollectionViewCell {
            
            if let photoViewModel = photosViewModel.photos[indexPath.item] {
                cell.photo = photoViewModel.photoIfAny
            }
                        
            return cell
        }
        
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegate
extension PhotoCollectionViewController: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDelegate
extension PhotoCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        loadMore(indexPaths)
    }
}

// MARK: - Search
extension PhotoCollectionViewController: UISearchBarDelegate {
    
    @objc private func initialSearch() {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            // There is no search text so we will not search
            return
        }
        
        search(PhotoRequest(searchTerm: searchText, page: 1))
    }
    
    private func search(_ request: PhotoRequest) {
        currentState = .searching
        searchBar.text = request.searchTerm
        
        //Cancel previous searches
        photoService.cancel()
        
        //Perform new search
        photoService.search(request, completion: { [weak self] result in
            
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let resultMetaData):
                
                var photos = resultMetaData.results.convertToViewModel(startIndex: ((request.page - 1) * PhotoRequest.itemsPerPage))
                
                // Successful Search - update the UI
                photos = self.photosViewModel.photos.merging(photos) { (_, new) in new }
                
                self.photosViewModel = PhotosViewModel(searchTerm: request.searchTerm, totalMatches: resultMetaData.totalMatches, photos: photos)

                self.currentState = .searched
                
            case .failure(let error):
                
                guard (error as NSError).code != NSURLErrorCancelled else {
                    //We expect a cancelled request since we are the ones cancelling it

                    self.currentState = .searched
                    return
                }
                
                // Failed Search - show the error
                self.showError(error)
            }
        })
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // to limit network activity, reload a second after last key press.
        cancelSearch()
        
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            currentState = .initial
            photosViewModel = PhotosViewModel(searchTerm: nil, totalMatches: .noTotal, photos: [Int: PhotoViewModel]())
            return
        }
        
        delaySearch()
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        cancelSearch()
        initialSearch()
    }
    
    private func delaySearch() {
        // Delaying the search by 1 second so we don't overload the backend
        perform(#selector(self.initialSearch), with: nil, afterDelay: 1.0)
    }
    
    private func cancelSearch() {
        // Cancel any previous delayed requests to search because it is obsolete.
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.initialSearch), object: nil)
    }
    
    private func loadMore(_ indexPaths: [IndexPath]) {
        guard let index = indexPaths.first?.row,
            photosViewModel.loadMore(start: index, count: PhotoRequest.itemsPerPage) else { return }
        
        
        let page = Int(ceil(Double(index + 1) / Double(PhotoRequest.itemsPerPage)))
        print("loading \(index) for page \(page)")
        search(PhotoRequest(
            searchTerm: photosViewModel.searchTerm,
            page: page))
    }
}

// MARK: - Rotation Detection
extension PhotoCollectionViewController {
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }
}

// MARK: - Error Handling
extension PhotoCollectionViewController {
    
    private func showError(_ error: Error?) {
        guard let error = error else {
            return
        }
        
        let alertController = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
