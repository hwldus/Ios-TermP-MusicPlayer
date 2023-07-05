//
//  MusicViewController.swift
//  jyhwnag-TermP-MusicPlayer
//
//  Created by 지연 on 2023/06/14.
//

import UIKit
import AVFoundation
import FirebaseFirestore
import FirebaseStorage

class MusicViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    
    var musicURL: String?
    var imageURL: String?
    var titlelabel: String?
    var artistlabel: String?
    
    var player: AVPlayer?
    var observer: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadImage()
        loadTitleAndArtist()
        playMusic()

    }
        
    // 음악 재생
    func playMusic() {
        guard let musicURLString = musicURL else {
            print("음악 URL이 nil입니다.")
            return
        }

        print(musicURLString) // gs://iostermp.appspot.com/song/Mysea.mp3
        
        let storageRef = Storage.storage().reference(forURL: musicURLString)
        print(storageRef)
        
        let filename = (musicURLString as NSString).lastPathComponent
        let localURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
            
        print(localURL)
        let downloadTask = storageRef.write(toFile: localURL) { (url, error) in
            guard error == nil, let localURL = url else {
                print("음악 파일 다운로드에 실패했습니다.")
                return
            }
            
            DispatchQueue.main.async { //메인스레드에서 실행
                let playerItem = AVPlayerItem(url: localURL)
                self.player = AVPlayer(playerItem: playerItem)
                
                // 종료할 때 까지 계속 확인
                NotificationCenter.default.addObserver(self as Any, selector: #selector(self.playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
                self.player?.play()

                // 시작 시간 지정
                let startTime = 0
                self.currentLabel.text = self.formatTime(time: TimeInterval(startTime))

                // 끝나는 시간 지정
                self.player?.addObserver(self, forKeyPath: "status", options: [.new], context: nil) // observe status change
                self.player?.addObserver(self, forKeyPath: "currentItem.duration", options: [.new], context: nil) // observe duration change
                    
                // 재생바 업데이트
                self.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main) { [weak self] time in
                    guard let player = self?.player else {
                        return
                    }
                    
                    let currentTime = player.currentTime().seconds
                    let totalTime = player.currentItem?.duration.seconds ?? 0
                    
                    let progress = Float(currentTime / totalTime)
                    self?.progressView.progress = progress
                    
                    self?.currentLabel.text = self?.formatTime(time: currentTime)
                }
           }
        }
        
        downloadTask.observe(.progress) { snapshot in
            guard let progress = snapshot.progress else {
                return
            }
            
            let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
            print("다운로드 진행 상황: \(percentComplete)%")
        }
    }
    
    //시간 타입으로 변경
    func formatTime(time: TimeInterval) -> String {
        if time.isFinite && !time.isNaN {
            // Perform time formatting
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad
            formatter.allowedUnits = [.minute, .second]
            return formatter.string(from: time) ?? ""
            }
        else {
            return "Invalid time"
        }
    }
    
    //endlabel 업데이트
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            // "status" 키 경로에 대한 값 변경을 관찰
            if player?.status == .readyToPlay {
                // 현재 아이템이 존재하고, 재생 시간이 정의된 경우
                if let currentItem = player?.currentItem, currentItem.duration.isIndefinite == false {
                    let endTime = currentItem.duration.seconds
                    self.endLabel.text = self.formatTime(time: endTime)
                }
                else {
                    self.endLabel.text = "Invalid time" // 재생 시간이 유효하지 않은 경우
                }
            }
        } else if keyPath == "currentItem.duration" {
            // "currentItem.duration" 키 경로에 대한 값 변경을 관찰
            if let currentItem = player?.currentItem, currentItem.duration.isIndefinite == false {
                let endTime = currentItem.duration.seconds
                self.endLabel.text = self.formatTime(time: endTime)
            }
            else {
                self.endLabel.text = "Invalid time"
            }
        }
    }
    
    //이미지 불러오기
    func loadImage() {
        guard let imageURLString = imageURL else {
            print("이미지 URL이 nil입니다.")
            return
        }
        let storageRef = Storage.storage().reference(forURL: imageURLString)
            storageRef.getData(maxSize: 100 * 1024 * 1024) { [weak self] (data, error) in
                if let error = error {
                    print("이미지 다운로드에 실패했습니다: \(error)")
                    return
                }

                if let imageData = data, let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                } else {
                    print("유효하지 않은 이미지 데이터입니다.")
                }
            }
        }
    
    //title, artist 불러오기
    func loadTitleAndArtist() {
        titleLabel.text = titlelabel
        artistLabel.text = artistlabel
    }
    
    @objc func playerDidFinishPlaying() {
        DispatchQueue.main.async {
            // 재생 중인 플레이어를 일시정지하고, 메모리에서 해제
            self.player?.pause()
            self.player = nil
            
            // 다시 돌아가기
            self.navigationController?.popViewController(animated: true)
        }
        
        // 등록된 옵저버를 제거
        if let observer = self.observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
    }
}

