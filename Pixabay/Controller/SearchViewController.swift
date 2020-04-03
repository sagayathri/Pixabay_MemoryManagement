//
//  ViewController.swift
//  Pixabay
//

import UIKit

class SearchViewController: UIViewController, URLCacheConnectionDelegate {
    
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet var clearCacheButton: UIView!
    
    let cache = Cache.sharedInstance
    let contant = Constants()
    var response: APIResponse? = nil
    var filePath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCache()
    }
    
    private func initCache() {
        searchTF.text = ""
        cache.vc = self
        cache.initSearchCache()
    }
    
    @IBAction func btnSearchTapped(_ sender: UIButton) {
        response = nil
        let searchString = searchTF.text
        if searchString != nil && searchString != "" {
            let encodedSearchString = searchString!.replacingOccurrences(of: " ", with: "+")
            let urlString = contant.baseURLString+"&q=\(encodedSearchString)"
            
            //MARK:- Create the url with NSURL
            let url = URL(string: urlString)
            response = self.cache.cacheSearchResponse(searchString:searchString!, urlString: url!, delegate: self)
            if response == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2)  {
                    self.moveToGallery(reponse: nil)
                }
            }
            else {
                self.moveToGallery(reponse: self.response!)
            }
        }
    }
    
    @IBAction func btnClearCacheTapped(_ sender: UIButton) {
        let message = NSLocalizedString("Do you really want to clear the cache?",
                   comment: "Clear Cache alert message")
        self.presentAlert(title: "Clear Cache", message: message, delegate: self)
    }
    
    func connectionDidFail(_ theConnection: URLCacheConnection, error: Error) {
        self.presentAlert(error: error)
    }
       
    func connectionDidFinish(_ theConnection: URLCacheConnection) {
        filePath = cache.searchFilePath
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
    
    func moveToGallery(reponse: APIResponse?) {
        let vc = (self.storyboard?.instantiateViewController(identifier: "GalleryViewController"))! as GalleryViewController
        vc.searchString = searchTF.text
        if response != nil {
            vc.response = response
            vc.hits = response?.hits
        }
        self.navigationController?.pushViewController(vc, animated: true)
        searchTF.text = ""
    }
}
extension SearchViewController: UIAlertControllerDelegate {
    func alertController(_ alertController: UIAlertController, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            return
        }
        self.cache.clearCache()
    }
}

