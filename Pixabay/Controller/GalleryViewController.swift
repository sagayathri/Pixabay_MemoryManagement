//
//  GalleryViewController.swift
//  Pixabay
//

import UIKit

class GalleryViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let application = UIApplication.shared
    let cache = Cache.sharedInstance
    var response: APIResponse?
    var hits: [Hit]? = []
    let contant = Constants()
    var filePath: String?
    var fileDate: Date?
    var searchString: String?
    let queue = OperationQueue()
    let group = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        startAnimation()
        initAndLoadCache()
    }
    
    //Initiates cache and saves image
    func initAndLoadCache() {
        cache.vc = self
        
        //Initiates cache directory
        cache.initImageCache()
        cache.createImageDirectory(searchString: searchString!)
        
        if response == nil {
            response = cache.fetchCachedSearchResponse()
            hits = response?.hits
        }
        
        group.enter()
        queue.maxConcurrentOperationCount = 1
        if hits != nil && !hits!.isEmpty {
            for item in hits! {
                queue.addOperation {
                    let url = URL(string: item.previewURL!)
                    //Checks if already downloaded
                    let isfound = self.cache.cacheImageResponse(urlString: url!, delegate: self)
                    if !isfound {
                        //Suspend all other queued operations untill the cureent operation completes
                        self.queue.isSuspended = true
                    }
                    if self.queue.operationCount <= 1 || self.queue.operationCount <= 0 {
                        self.group.leave()
                    }
                }
            }
        }
        else {
            self.group.leave()
        }
        //Notifies the main thread
        group.notify(queue: .main, execute: loadImage)
    }
    
    func loadImage() {
        if hits!.isEmpty {
            stopAnimation()
            let message = NSLocalizedString("Please try some other text", comment: "Use precise test to search")
            self.presentAlert(title: "Nothing to show", message: message,delegate: self)
        }
        else {
            collectionView.reloadData()
        }
    }
    
    //Show the user that loading activity has started
    private func startAnimation() {
        self.activityIndicator.startAnimating()
    }
    
    //Show the user that loading activity has stopped
    private func stopAnimation() {
        self.activityIndicator.stopAnimating()
    }
}

extension GalleryViewController: URLCacheConnectionDelegate {
    func connectionDidFail(_ theConnection: URLCacheConnection, error: Error) {
        self.presentAlert(error: error)
    }
       
    func connectionDidFinish(_ theConnection: URLCacheConnection) {
        if queue.isSuspended {
            queue.isSuspended = false
        }
        filePath = cache.imageFilePath
        if !FileManager.default.fileExists(atPath: filePath!) {
            // file doesn't exist, so create it
            FileManager.default.createFile(atPath: filePath!,
                                           contents: theConnection.receivedData,
                                           attributes: nil)
        }
       // reset the file's modification date to indicate that the URL has been checked
       let dict: [FileAttributeKey: Any] = [FileAttributeKey.modificationDate: Date()]
       do {
            try FileManager.default.setAttributes(dict, ofItemAtPath: filePath!)
        } catch let error {
           self.presentAlert(error: error)
        }
    }
    
    //Fetches the images from cache location
    func fromImagePath(string: String) -> UIImage? {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let imageDataPath = (paths[0] as NSString).appendingPathComponent("ImageCache")
        let imageDirPath = (imageDataPath as NSString).appendingPathComponent(searchString!)
        let urlString = URL(string: string)
        let fileName = urlString!.lastPathComponent
        let imageFilePath = (imageDirPath as NSString).appendingPathComponent(fileName)
        // display the file as an image
        if FileManager.default.fileExists(atPath: imageFilePath) {
            if let theImage = UIImage(contentsOfFile: imageFilePath) {
                return theImage
            }
        }
        return nil
    }
}

extension GalleryViewController: UIAlertControllerDelegate {
    func alertController(_ alertController: UIAlertController, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            return
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hits!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GalleryCollectionViewCell
        if fromImagePath(string: hits![indexPath.row].previewURL!) != nil {
            if activityIndicator.isAnimating {
                stopAnimation()
                collectionView.isHidden = false
            }
            cell.item = hits![indexPath.row]
            cell.pictureImageView.image = fromImagePath(string: hits![indexPath.row].previewURL!)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = (self.storyboard?.instantiateViewController(identifier: "ImageViewController"))! as DetailsViewController
        print(hits![indexPath.row].previewURL!)
        vc.pageURL = hits![indexPath.row].pageURL!
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
