//
//  CustomCollectionViewCell.swift
//  jyhwnag-TermP-MusicPlayer
//
//  Created by 지연 on 2023/06/15.
//

import UIKit
import FirebaseStorage

class CustomCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var didSelectItem: (() -> Void)?

    func configure(with imageURL: String, title: String?) {
        // 이미지를 로드하기 전에 이미지 뷰를 숨김
        imageView.isHidden = true
        titleLabel.isHidden = true

        // 이미지 로드
        let storageRef = Storage.storage().reference(forURL: imageURL)
        storageRef.getData(maxSize: 100 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("Error loading image: \(error)")
                return
            }
            
            if let imageData = data, let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    // 이미지 로드가 완료되면 이미지 뷰에 이미지를 설정하고, 이미지 뷰를 표시
                    self.imageView.image = image
                    self.imageView.isHidden = false
                    self.titleLabel.text = title
                    self.titleLabel.isHidden = false
                }
            } else {
                // 이미지 로드 실패 시 기본 이미지를 설정하고, 이미지 뷰를 표시
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(named: "ImageTest")
                    self.imageView.isHidden = false
                    self.titleLabel.text = title
                    self.titleLabel.isHidden = false
                }
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
            imageView.addGestureRecognizer(tapGesture)
            imageView.isUserInteractionEnabled = true
    }
    @objc private func imageViewTapped() {
        didSelectItem?()
    }
  
}
