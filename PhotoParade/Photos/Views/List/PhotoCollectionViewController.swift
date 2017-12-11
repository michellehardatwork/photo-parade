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

struct PhotoDataSource {
    let request: PhotoRequest
    let totalMatches: Total
    let photos: [Photo]
}

extension PhotoDataSource {
    func hasMore() -> Bool {
        switch totalMatches {
        case .total(let value):
            return value > ((request.page - 1) * request.itemsPerPage)
        default:
            return false
        }
    }
}

class PhotoCollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityView: PhotoSearchTableStateView!
    
    let photoService = PhotoService(photoProvider: Flickr())
    
    fileprivate var photoDataSource = PhotoDataSource(
        request: PhotoRequest(searchTerm: "Fruit faces", page: 1),
        totalMatches: .noTotal,
        photos: [Photo]()) {
        didSet {
            collectionView.reloadData()
        }
    }
    
    fileprivate var currentState = State.none {
        didSet {
            switch currentState {
            case .initial:
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                activityView.showInitial()
                break
            case .searching:
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                activityView.showSearching()
                break
            case .searched:
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                activityView.showSearched(count: photoDataSource.photos.count)
                break
            case .none:
                activityView.showNothing()
                break
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
        
        currentState = .initial
        
        //Seed the search
        search(photoDataSource.request)
    }
}

// MARK: - UICollectionViewDataSource
extension PhotoCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoDataSource.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as? PhotoCollectionViewCell {
            cell.photo = photoDataSource.photos[indexPath.item]
            return cell
        }
        
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegate
extension PhotoCollectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout,
            layout.scrollDirection == .horizontal {
            let offsetX = collectionView.contentOffset.x
            let contentWidth = collectionView.contentSize.width
            if offsetX > contentWidth - collectionView.frame.size.width {
                loadMore()
            }
        } else {
            let offsetY = collectionView.contentOffset.y
            let contentHeight = collectionView.contentSize.height
            if offsetY > contentHeight - collectionView.frame.size.height {
                loadMore()
            }
        }
    }
}

// MARK: - Search
extension PhotoCollectionViewController: UISearchBarDelegate {
    
    @objc fileprivate func initialSearch() {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            // There is no search text so we will not search
            return
        }
        
        search(PhotoRequest(searchTerm: searchText, page: 1))
    }
    
    fileprivate func search(_ request: PhotoRequest) {
        currentState = .searching
        searchBar.text = request.searchTerm
        
        //Cancel previous searches
        photoService.cancel()
        
        //Perform new search
        photoService.search(request, completion: { [weak self] result in
            
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let resultMetaData):
                
                var photos = resultMetaData.results
                
                // Successful Search - update the UI
                if request.page > 1 {
                    photos = strongSelf.photoDataSource.photos + photos
                }
                
                strongSelf.photoDataSource = PhotoDataSource(request: request, totalMatches: resultMetaData.totalMatches, photos: photos)
                
                break
                
            case .failure(let error):
                
                guard (error as NSError).code != NSURLErrorCancelled else {
                    //We expect a cancelled request since we are the ones cancelling it
                    break
                }
                
                // Failed Search - show the error
                strongSelf.showError(error)
                break
            }
            
            strongSelf.currentState = .searched
        })
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // to limit network activity, reload a second after last key press.
        cancelSearch()
        
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            currentState = .initial
            photoDataSource = PhotoDataSource(request: PhotoRequest(searchTerm: "", page: 1), totalMatches: .noTotal, photos: [])
            return
        }
        
        delaySearch()
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        cancelSearch()
        initialSearch()
    }
    
    fileprivate func delaySearch() {
        // Delaying the search by 1 second so we don't overload the backend
        perform(#selector(self.initialSearch), with: nil, afterDelay: 1.0)
    }
    
    fileprivate func cancelSearch() {
        // Cancel any previous delayed requests to search because it is obsolete.
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.initialSearch), object: nil)
    }
    
    fileprivate func loadMore() {
        if  currentState == .searching || !photoDataSource.hasMore() {
            return
        }
        
        search(PhotoRequest(
            searchTerm: photoDataSource.request.searchTerm,
            page: photoDataSource.request.page + 1))
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
    
    fileprivate func showError(_ error: Error?) {
        guard let error = error else {
            return
        }
        
        let alertController = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
