//
//  URLCacheConnection.swift
//  Pixabay
//

import Foundation
import UIKit

let NSURLResponseUnknownLength = Int64(-1)

@objc(URLCacheConnectionDelegate)
protocol URLCacheConnectionDelegate: NSObjectProtocol {
    func connectionDidFail(_ theConnection: URLCacheConnection, error: Error)
    func connectionDidFinish(_ theConnection: URLCacheConnection)
}

enum URLCacheConnectionError: Error {
    case failed(String)
}

@objc(URLCacheConnection)
class URLCacheConnection: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    weak var delegate: URLCacheConnectionDelegate!
    var receivedData: Data?
    var lastModified: Date?
    var dataTask: URLSessionDataTask!
    
    // This method initiates the load request
    init(url theURL: URL, delegate theDelegate: URLCacheConnectionDelegate) throws {
        self.delegate = theDelegate
        super.init()
        
        // Create the request
        let theRequest = URLRequest(url: theURL,
                                    cachePolicy: .reloadIgnoringLocalCacheData,
                                    timeoutInterval: 60)
        
        // Create the connection with the request and start loading the data
        self.dataTask = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main).dataTask(with: theRequest)
        self.dataTask.resume()
    }
    
    //MARK: NSURLConnection delegate methods
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        // create the NSMutableData instance that will hold the received data
        var contentLength = response.expectedContentLength
        if contentLength == NSURLResponseUnknownLength {
            contentLength = 500000
        }
        self.receivedData = Data(capacity: Int(contentLength))
        
        //Retrieves last modified date from HTTP header
        if let response = response as? HTTPURLResponse {
            let headers = response.allHeaderFields
            if let modified = headers["Last-Modified"] as! String? {
                let dateFormatter = DateFormatter()
                
                /* avoid problem if the user's locale is incompatible with HTTP-style dates */
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                
                dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
                self.lastModified = dateFormatter.date(from: modified)
            } else {
                /* default if last modified date doesn't exist (not an error) */
                self.lastModified = Date(timeIntervalSinceReferenceDate: 0)
            }
            completionHandler(.allow)
        } else {
            completionHandler(.cancel)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        // Append the new data to the received data.
        self.receivedData?.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        session.invalidateAndCancel()
        self.dataTask = nil
        if let error = error {
            self.delegate.connectionDidFail(self, error: error)
        } else {
            self.delegate.connectionDidFinish(self)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        // this application does not use a NSURLCache disk or memory cache
        completionHandler(nil)
    }
}

