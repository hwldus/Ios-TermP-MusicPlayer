//
//  ImageCell.swift
//  jyhwnag-TermP-MusicPlayer
//
//  Created by 지연 on 2023/06/14.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    func configure(with imageUrl: String) {
        // 이미지를 가져와서 imageView에 표시하는 로직을 구현합니다.
            if let url = URL(string: imageUrl) {
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let error = error {
                        print("Error downloading image: \(error.localizedDescription)")
                        return
                    }
                    
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.imageView.image = image
                        }
                    }
                }.resume()
            }
    }
}
