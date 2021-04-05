//
//  ViewController.swift
//  YoutubeApp
//
//  Created by yasuyoshi on 2021/04/05.
//

import UIKit
//
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var videoListCollectionView: UICollectionView!
    private let cellId = "cellId"
    private var videoItems = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoListCollectionView.delegate = self
        videoListCollectionView.dataSource = self
        videoListCollectionView.register(UINib(nibName: "VideoListCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        
        fetchYoutubeSearchInfo()
        
    }
    
    private func fetchYoutubeSearchInfo() {
        
        let filePath = Bundle.main.path(forResource: "YoutubeApp", ofType:"plist" )
        let plist = NSDictionary(contentsOfFile: filePath!)
        let apiKey = plist!["ApiKey"] as! String
        let urlString = "https://www.googleapis.com/youtube/v3/search?q=camp&key=\(apiKey)&part=snippet"
        let request = AF.request(urlString)
        request.responseJSON { (response) in
//            print("response: ", response)
            guard let data = response.data else { return }
            let decode = JSONDecoder()
            do {
                let video = try decode.decode(Video.self, from: data)
                self.videoItems = video.items
                let id = self.videoItems[0].snippet.channelId
                self.fetchYoutubeChannelInfo(id: id)
                
                self.videoListCollectionView.reloadData()
            } catch {
                print("変換に失敗しました: ", error)
            }
        }
    }
    
    private func fetchYoutubeChannelInfo(id: String) {
        
        let filePath = Bundle.main.path(forResource: "YoutubeApp", ofType:"plist" )
        let plist = NSDictionary(contentsOfFile: filePath!)
        let apiKey = plist!["ApiKey"] as! String
        let urlString = "https://www.googleapis.com/youtube/v3/channels?key=\(apiKey)&part=snippet&id=\(id)"
        let request = AF.request(urlString)
        request.responseJSON { (response) in
            print("response: ", response)
            guard let data = response.data else { return }
            let decode = JSONDecoder()
            do {
                let channel = try decode.decode(Channel.self, from: data)
                self.videoItems.forEach { (item) in
                    item.channel = channel
                }
                self.videoListCollectionView.reloadData()
            } catch {
                print("変換に失敗しました: ", error)
            }
        }
    }


}

//
// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
//
extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        return .init(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = videoListCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! VideoListCell
        cell.videoItem = videoItems[indexPath.row]
        return cell
    }
    
    
    
    
}
