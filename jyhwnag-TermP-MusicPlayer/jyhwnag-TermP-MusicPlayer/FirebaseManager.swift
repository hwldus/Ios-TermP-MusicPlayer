//
//  Firebase.swift
//  jyhwnag-TermP-MusicPlayer
//
//  Created by 지연 on 2023/06/14.
//

/*
import Firebase

struct Music {
    let title: String
    let imageURL: String
    let songURL: String
}

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    func saveMusicData(title: String, imageURL: String, songURL: String) {
        let collection = db.collection("music")
        
        collection.addDocument(data: [
            "title": title,
            "image": imageURL,
            "song": songURL
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
            }
        }
    }
    
    func fetchMusicData(completion: @escaping ([Music]) -> Void) {
        let collection = db.collection("music")
        
        collection.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }
            
            var musicArray: [Music] = []
            
            for document in querySnapshot!.documents {
                let title = document.data()["title"] as? String ?? ""
                let imageURL = document.data()["image"] as? String ?? ""
                let songURL = document.data()["song"] as? String ?? ""
                
                let music = Music(title: title, imageURL: imageURL, songURL: songURL)
                musicArray.append(music)
            }
            
            completion(musicArray)
        }
    }
}
*/

//import Firebase
//import FirebaseStorage
//
//class FirebaseManager {
//    static let shared = FirebaseManager()
//    private let db = Firestore.firestore()
//    private let storage = Storage.storage()
//    
//    func saveMusicData(title: String, imageFileURL: URL, songFileURL: URL) {
//        let collection = db.collection("music")
//        
//        // 이미지 파일을 Firebase Storage에 업로드하고 다운로드 URL을 가져옴
//        let imageRef = storage.reference().child("images/\(UUID().uuidString).jpg")
//        let imageUploadTask = imageRef.putFile(from: imageFileURL, metadata: nil) { (metadata, error) in
//            if let error = error {
//                print("Error uploading image: \(error)")
//                return
//            }
//            
//            // 이미지 다운로드 URL 가져오기
//            imageRef.downloadURL { (url, error) in
//                if let error = error {
//                    print("Error retrieving image URL: \(error)")
//                    return
//                }
//                
//                if let imageURL = url?.absoluteString {
//                    // 노래 파일을 Firebase Storage에 업로드하고 다운로드 URL을 가져옴
//                    let songRef = storage.reference().child("songs/\(UUID().uuidString).mp3")
//                    let songUploadTask = songRef.putFile(from: songFileURL, metadata: nil) { (metadata, error) in
//                        if let error = error {
//                            print("Error uploading song: \(error)")
//                            return
//                        }
//                        
//                        // 노래 다운로드 URL 가져오기
//                        songRef.downloadURL { (url, error) in
//                            if let error = error {
//                                print("Error retrieving song URL: \(error)")
//                                return
//                            }
//                            
//                            if let songURL = url?.absoluteString {
//                                // 이미지 URL과 노래 URL을 Firestore에 저장
//                                collection.addDocument(data: [
//                                    "title": title,
//                                    "image": imageURL,
//                                    "song": songURL
//                                ]) { error in
//                                    if let error = error {
//                                        print("Error adding document: \(error)")
//                                    } else {
//                                        print("Document added successfully")
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        
//        // 파일 업로드 태스크 모니터링 및 진행률 추적 등 추가적인 로직을 구현할 수 있습니다.
//        // 예시: imageUploadTask.observe(.progress) { snapshot in ... }
//        // 예시: songUploadTask.observe(.success) { snapshot in ... }
//    }
//}
