//
//  Cache.swift
//  Pixabay
//

import Foundation
import UIKit

class Cache {
    static let sharedInstance = Cache()
    let contant = Constants()
    var connection: URLCacheConnection?
    var response: APIResponse?
    var searchDataPath: String!
    var imageDataPath: String!
    var imageDirPath: String!
    var searchFilePath: String?
    var searchFileDate: Date?
    var imageFilePath: String?
    var imageFileDate: Date?
    var err: Error?
    var errorMessage: String?
    var vc: UIViewController? = nil
    var isImageFound = false
    
    // cache update interval in seconds
    private let URLCacheInterval = 86400.0
    
    func initSearchCache() {
        // create path to cache directory inside the application's Documents directory
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        self.searchDataPath = (paths[0] as NSString).appendingPathComponent("SearchCache")
        // check for existence of cache directory
        if FileManager.default.fileExists(atPath: searchDataPath) {
            return
        }
        //create a new cache directory
        do {
            try FileManager.default.createDirectory(atPath: searchDataPath,
                withIntermediateDirectories: false,
                attributes: nil)
            return
        } catch let error {
            vc!.presentAlert(error: error)
            err = error
            return
        }
    }
    
    func cacheSearchResponse(searchString: String, urlString: URL, delegate: URLCacheConnectionDelegate) -> APIResponse? {
        response = nil
        
        // get the path to the cached search reponse
        let fileName = "\(searchString).json"
        searchFilePath = (searchDataPath as NSString).appendingPathComponent(fileName)
        
        let dirContents = try? FileManager.default.contentsOfDirectory(atPath: searchDataPath)
        let count = dirContents?.count
    
        //check the last modified date
        self.getFileModificationDateOfSearch()
        // get the elapsed time since last file update
        let time = abs(searchFileDate!.timeIntervalSinceNow)
        if time > URLCacheInterval {
            
            if count! >= 10 {
                removesOlderFiles(dirContents: dirContents!, path: searchDataPath!)
            }
            
            // file doesn't exist or hasn't been updated for at least one day
            do {
                self.connection = try URLCacheConnection(url: urlString, delegate: delegate)
            } catch URLCacheConnectionError.failed(let message) {
                vc!.presentAlert(message: message)
                errorMessage = message
            } catch {}
        } else {
            response = self.fetchCachedSearchResponse()
        }
        return response ?? nil
    }
    
    func removesOlderFiles(dirContents: [String], path: String) {
        var oldestDate = Date()
        var oldestFile = ""
        for file in dirContents {
            if file.contains(".json"){
                let filPath = (path as NSString).appendingPathComponent(file)
                let attributes = try! FileManager.default.attributesOfItem(atPath: filPath)
                let creationDate = attributes[.creationDate] as! Date
                if creationDate < oldestDate {
                    oldestDate = creationDate
                    oldestFile = file
                }
            }
        }
//        let oldestFilPath = (path as NSString).appendingPathComponent(oldestFile)
        //try! FileManager.default.removeItem(atPath: oldestFilPath)
        clearSpecificCache(fileName: oldestFile)
    }
    
    // display existing cached image
    func fetchCachedSearchResponse() -> APIResponse? {
       // retrieve file attributes
       self.getFileModificationDateOfSearch()

       // format the file modification date for display in Updated field
       let dateFormatter = DateFormatter()
       dateFormatter.timeStyle = .short
       dateFormatter.dateStyle = .medium
       
       // display the file as a json response
        let url = URL(fileURLWithPath: searchFilePath!)
        do {
            let data = try Data(contentsOf: url)
            response = try JSONDecoder().decode(APIResponse.self, from: data)
        }
        catch {
            print("Decoding error")
        }
        return response ?? nil
    }
    
    // get modification date of the current cached image
    func getFileModificationDateOfSearch() {
        err = nil
        // default date if file doesn't exist (not an error)
        guard let filePath = self.searchFilePath else {return}
        self.searchFileDate = Date(timeIntervalSinceReferenceDate: 0)
        if FileManager.default.fileExists(atPath: filePath) {
            //retrieve file attributes
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: filePath)
                self.searchFileDate = (attributes as NSDictionary).fileModificationDate()
            } catch let error {
                vc!.presentAlert(error: error)
                err = error
            }
        }
    }
    
    func initImageCache() {
        // create path to cache directory inside the application's Documents directory
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        self.imageDataPath = (paths[0] as NSString).appendingPathComponent("ImageCache")
        // check for existence of cache directory
        if FileManager.default.fileExists(atPath: imageDataPath) {
            return
        }
        //create a new cache directory
        do {
            try FileManager.default.createDirectory(atPath: imageDataPath,
                withIntermediateDirectories: false,
                attributes: nil)
            return
        } catch let error {
            vc!.presentAlert(error: error)
            err = error
            return
        }
    }
        
    func createImageDirectory(searchString: String) {
        // create path to cache directory inside ImageCache directory
        self.imageDirPath = (self.imageDataPath as NSString).appendingPathComponent(searchString)
        
        // check for existence of cache directory
        if FileManager.default.fileExists(atPath: self.imageDirPath) {
            return
        }
        //create a new cache directory
        do {
            try FileManager.default.createDirectory(atPath: self.imageDirPath,
                withIntermediateDirectories: false,
                attributes: nil)
            return
        } catch let error {
            vc!.presentAlert(error: error)
            err = error
            return
        }
    }
    
    // get modification date of the current cached image
    func getFileModificationDateOfImage() {
        err = nil
        // default date if file doesn't exist (not an error)
        guard let filePath = self.imageFilePath else {return}
        self.imageFileDate = Date(timeIntervalSinceReferenceDate: 0)
        if FileManager.default.fileExists(atPath: filePath) {
            //retrieve file attributes
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: filePath)
                self.imageFileDate = (attributes as NSDictionary).fileModificationDate()
            } catch let error {
                vc!.presentAlert(error: error)
                err = error
            }
        }
    }
    
    func cacheImageResponse(urlString: URL, delegate: URLCacheConnectionDelegate) -> Bool {
        // get the path to the cached search reponse
        let fileName = urlString.lastPathComponent
        imageFilePath = (imageDirPath as NSString).appendingPathComponent(fileName)
    
        //check the last modified date
        self.getFileModificationDateOfImage()
        //get the elapsed time since last file update
        let time = abs(imageFileDate!.timeIntervalSinceNow)
        if time > URLCacheInterval {
            isImageFound = false
            // file doesn't exist or hasn't been updated for at least one day
            do {
                self.connection = try URLCacheConnection(url: urlString, delegate: delegate)
            } catch URLCacheConnectionError.failed(let message) {
                vc!.presentAlert(message: message)
                errorMessage = message
            } catch {}
        } else {
            isImageFound = true
        }
        return isImageFound
    }
    
    // removes every file in the cache directory
    func clearCache() {
        // remove the cache directory and its contents
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        self.searchDataPath = (paths[0] as NSString).appendingPathComponent("SearchCache")
        self.imageDataPath = (paths[0] as NSString).appendingPathComponent("ImageCache")
        do {
            try FileManager.default.removeItem(atPath: imageDataPath)
            try FileManager.default.removeItem(atPath: searchDataPath)
        } catch let error {
            vc!.presentAlert(error: error)
            return
        }
    }
    
    func clearSpecificCache(fileName: String) {
        // remove the cache directory and its contents
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        self.searchDataPath = (paths[0] as NSString).appendingPathComponent("SearchCache")
        self.imageDataPath = (paths[0] as NSString).appendingPathComponent("ImageCache")
        let searchFilePathToRemove = (searchDataPath as NSString).appendingPathComponent(fileName)
        let stringToReplace = ".json"
        let outputStr = fileName.replacingOccurrences(of: stringToReplace, with: "")
        let imageFileDirName = outputStr.trimmingCharacters(in: NSCharacterSet.whitespaces)
        let imageDirPathToRemove = (self.imageDataPath as NSString).appendingPathComponent(imageFileDirName)
        do {
            try FileManager.default.removeItem(atPath: searchFilePathToRemove)
            try FileManager.default.removeItem(atPath: imageDirPathToRemove)
        } catch let error {
            vc!.presentAlert(error: error)
            return
        }
    }
}
