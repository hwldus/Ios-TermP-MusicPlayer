//
//  ViewController.swift
//  jyhwnag-TermP-MusicPlayer
//
//  Created by 지연 on 2023/06/14.
//
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct MusicModel {
    let imageURL: String?
    let musicURL: String?
    let title: String?
    let artist: String?
}

class MainViewController: UIViewController {
    
    @IBAction func addButton(_ sender: UIButton) {
        performSegue(withIdentifier: "AddMusic", sender: nil)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    var musicCollectionRef: CollectionReference! // Firebase의 컬렉션 레퍼런스
    var musicData: [MusicModel] = [] // 파이어스토어에서 가져온 음악 데이터를 저장할 배열
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Firebase 설정
        let db = Firestore.firestore()
        musicCollectionRef = db.collection("music")
                
        // 파이어스토어에서 음악 데이터 가져오기
        fetchMusicData()
    }
    
    func fetchMusicData() {
        musicCollectionRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting music documents: \(error)")
            } else {
                if let documents = snapshot?.documents {
                    self.musicData.removeAll() // 기존 데이터 제거
                    documents.forEach { queryDocumentSnapshot in
                        let data = queryDocumentSnapshot.data()
                        let imageURL = data["image"] as? String
                        let musicURL = data["song"] as? String
                        let title = data["title"] as? String
                        let artist = data["artist"] as? String
                        let music = MusicModel(imageURL: imageURL, musicURL: musicURL, title: title, artist: artist)
                        self.musicData.append(music)
                    }
                    self.collectionView.reloadData() // 콜렉션 뷰 리로드
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //세그웨이에 데이터 전달
        if segue.identifier == "ShowMusic",
           let musicInfo = sender as? (musicURL: String, imageURL: String, title: String, artist: String) {
            let musicVC = segue.destination as! MusicViewController
            musicVC.musicURL = musicInfo.musicURL
            musicVC.imageURL = musicInfo.imageURL
            musicVC.titlelabel = musicInfo.title
            musicVC.artistlabel = musicInfo.artist
        }
    }
}

extension MainViewController:UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return musicData.count // 가져온 음악 데이터 개수 반환
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! CustomCollectionViewCell
        
        let music = musicData[indexPath.item]
        if let imageURL = music.imageURL {
            cell.configure(with: imageURL, title: music.title)
        } else {
            cell.imageView.image = UIImage(named: "ImageTest")
            cell.titleLabel.text = "Nil" // Set the artist label text
            cell.imageView.isHidden = false
            cell.titleLabel.isHidden = false
        }
        
        // 이미지 클릭 시 세그웨이 수행하는 클로저를 설정
        cell.didSelectItem = { [weak self] in
            if let musicUrl = music.musicURL, let imageUrl = music.imageURL, let title = music.title, let artist = music.artist {
                let musicInfo = (musicURL: musicUrl, imageURL: imageUrl, title: title, artist: artist)
                self?.performSegue(withIdentifier: "ShowMusic", sender: musicInfo)
            }
        }
        return cell
    }

}
