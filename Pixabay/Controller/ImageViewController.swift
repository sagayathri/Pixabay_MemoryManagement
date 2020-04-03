//
//  ImageViewController.swift
//  Pixabay
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var biggerImage: UIImageView!
    
    var image: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        biggerImage.image = image
    }
}
