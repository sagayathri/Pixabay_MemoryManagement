//
//  GalleryCollectionViewCell.swift
//  Pixabay
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var pictureImageView: UIImageView!
    
    @IBOutlet weak var favoritesTF: UILabel!
    @IBOutlet weak var likesTF: UILabel!
    @IBOutlet weak var tagsTF: UILabel!
    
    let imageSrc: UIImage? = nil
    
    var item: Hit? {
        didSet {
            self.loadUI()
        }
    }
    
    func loadUI() {
        favoritesTF.text = String(describing: item!.favorites!)
        likesTF.text = String(describing: item!.likes!)
        tagsTF.text = String(describing: item!.tags!)

//        imageDownloading()
    }
    
    func imageDownloading() {
        let urlString = item!.previewURL!
       if urlString != "" {
        let url = URL(string: urlString)!
            do {
                let data = try Data(contentsOf: url)
                DispatchQueue.main.async {
                    self.pictureImageView.image = UIImage(data: data)
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
}
