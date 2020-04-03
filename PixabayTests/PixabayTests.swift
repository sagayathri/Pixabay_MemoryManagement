//
//  PixabayTests.swift
//  PixabayTests
//

import XCTest
@testable import Pixabay

class PixabayTests: XCTestCase {

    var searchDataPath: String?
    var imageDataPath: String?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        searchDataPath = (paths[0] as NSString).appendingPathComponent("SearchCache")
        imageDataPath = (paths[0] as NSString).appendingPathComponent("ImageCache")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testChecksSearchDir() {
        if FileManager.default.fileExists(atPath: searchDataPath!) {
            XCTAssert(FileManager.default.fileExists(atPath: searchDataPath!))
        }
    }
    
    func testChecksImageDir() {
        if FileManager.default.fileExists(atPath: imageDataPath!) {
            XCTAssert(FileManager.default.fileExists(atPath: imageDataPath!))
        }
    }
    
    func testNumberOfSeaches() {
        let dirContents = try? FileManager.default.contentsOfDirectory(atPath: searchDataPath!)
        let count = dirContents?.count
        XCTAssert(count! == 11)
    }
    
    func testNumberOfImageDir() {
        let dirContents = try? FileManager.default.contentsOfDirectory(atPath: imageDataPath!)
        let count = dirContents?.count
        XCTAssert(count! == 11)
    }
    
    func testSearchFileIsJson() {
        let dirContents = try? FileManager.default.contentsOfDirectory(atPath: searchDataPath!)
        let count = dirContents?.count
        if count! >= 10 {
            for file in dirContents! {
                XCTAssert(file.contains(".json") || file.contains(".DS_Store"))
            }
        }
    }
}
