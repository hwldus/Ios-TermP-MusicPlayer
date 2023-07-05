//
//  AddMusicViewController.swift
//  jyhwnag-TermP-MusicPlayer
//
//  Created by 지연 on 2023/06/19.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class AddMusicViewController: UIViewController {
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var artistLabel: UITextField!
    
    var songURL: URL?
    var imageURL: URL?
    
    let storage = Storage.storage()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    // 음악 파일 업로드 버튼 액션
    @IBAction func uploadSongButtonTapped(_ sender: UIButton) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    // 이미지 파일 업로드 버튼 액션
    @IBAction func uploadImageButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    // 추가 버튼 액션
    @IBAction func addButtonTapped(_ sender: UIButton) {

        guard let songFileURL = songURL, let imageFileURL = imageURL,
              let title = titleLabel.text, let artist = artistLabel.text,
              !title.isEmpty, !artist.isEmpty else {
            print("음악 파일과 이미지 파일, 그리고 제목과 아티스트를 모두 입력해주세요.")
            return
        }
        
        uploadSongFile(fileURL: songFileURL) { songDownloadURL in
            self.uploadImageFile(fileURL: imageFileURL) { [self] imageDownloadURL in
                guard let songDownloadURL = songDownloadURL,
                      let imageDownloadURL = imageDownloadURL
                else {
                    print("음악 파일 및 이미지 파일 업로드 후 URL을 얻지 못했습니다.")
                    return
                }
                let artist = self.artistLabel.text ?? "artist"
                let title = self.titleLabel.text ?? "title"
                
                saveDataToFirestore(artist: artist, title: title, songURL: songDownloadURL, imageURL: imageDownloadURL)
                }
            }
        }
    
    // 음악 파일을 Firebase Storage에 업로드하는 함수
    func uploadSongFile(fileURL: URL, completion: @escaping (URL?) -> Void) {

        let fileName = "\(UUID().uuidString).mp3"
        let storageRef = storage.reference().child("song/\(fileName)")

        storageRef.putFile(from: fileURL, metadata: nil) { (metadata, error) in
            if let error = error {
                print("파일 업로드 에러: \(error.localizedDescription)")
                completion(nil)
                return
            }

            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("URL 다운로드 에러: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                guard let downloadURL = url else {
                    print("다운로드 URL이 유효하지 않습니다.")
                    completion(nil)
                    return
                }
                
                let bucket = storageRef.bucket
                let fullPath = storageRef.fullPath
                let urlString = "gs://\(bucket)/\(fullPath)"
                if let modifiedURL = URL(string: urlString) {
                    completion(modifiedURL)
                } else {
                    completion(nil)
                }
            }
        }
    }

    // 이미지 파일을 Firebase Storage에 업로드하는 함수
    func uploadImageFile(fileURL: URL, completion: @escaping (URL?) -> Void) {
        let storageRef = storage.reference()
        let filename = UUID().uuidString + ".jpg"
        let imageRef = storageRef.child("image/\(filename)")

        imageRef.putFile(from: fileURL, metadata: nil) { (metadata, error) in
            if let error = error {
                print("이미지 파일 업로드 에러:", error)
                completion(nil)
                return
            }

            imageRef.downloadURL { (url, error) in
                if let error = error {
                    print("이미지 파일 다운로드 URL 얻기 에러:", error)
                    completion(nil)
                    return
                }

                if let downloadURL = url {
                    print("이미지 파일 다운로드 URL:", downloadURL.absoluteString)
                    completion(downloadURL)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    // Firestore에 데이터를 저장하는 함수
    func saveDataToFirestore(artist: String, title: String, songURL: URL, imageURL: URL) {
            let songURLString = songURL.absoluteString
            print("다운로드 URL: \(songURLString)")

            let songRef = db.collection("music").document()
            let songData: [String: Any] = [
                "song": songURLString,
                "artist": artist,
                "title": title,
                "image": imageURL.absoluteString
            ]
            
            songRef.setData(songData) { (error) in
                if let error = error {
                    print("스토어에 저장하는 도중 에러: \(error.localizedDescription)")
                } else {
                    print("스토어에 저장 완료")
                }
            }
        }
}

extension AddMusicViewController: UIDocumentPickerDelegate { //파일에서 음악 선택
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else {
            return
        }
        
        songURL = fileURL
        print("선택한 음악 파일 URL:", fileURL)
    }
}

extension AddMusicViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate { //이미지 선택
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let fileURL = info[UIImagePickerController.InfoKey.imageURL] as? URL else {
            return
        }
        
        imageURL = fileURL
        print("선택한 이미지 파일 URL:", fileURL)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
