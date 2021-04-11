//
//  SearchViewController.swift
//  YoutubeApp
//
//  Created by yasuyoshi on 2021/04/10.
//

import UIKit

class SearchViewController: UIViewController {
    var video: Video?
    lazy var searchBar: UISearchBar =  {
        let sb = UISearchBar()
        sb.placeholder = "Youtubeを検索"
        sb.delegate = self
        return sb
    }()
    lazy var videoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    private let videoCellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        navigationItem.titleView = searchBar
        navigationItem.titleView?.frame = searchBar.frame
        
        videoCollectionView.frame = self.view.frame
        self.view.addSubview(videoCollectionView)
        videoCollectionView.register(UINib(nibName: "VideoListCell", bundle: nil), forCellWithReuseIdentifier: videoCellId )

    }

}

// MARK: - UICollectionViewDelegate
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // セルを選択した時
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // モーダル表示元のcontroller
        let prevController = self.presentingViewController as! BaseTabBarController
        // tabbarの１番目のタブのcontroller
        let videoList = prevController.viewControllers?[0] as! VideoListViewController
        videoList.selectedItem = video?.items[indexPath.row]
        
        dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name("searchedItem"), object: nil)
        }
        
    }
    // セルのサイズ調整（UICollectionViewDelegateFlowLayout）
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        return .init(width: width, height: width)
    }
    // セルの数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return video?.items.count ?? 0
    }
    // セルの構築
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: videoCellId, for: indexPath) as! VideoListCell
        cell.videoItem = video?.items[indexPath.row]
        return cell
    }
    
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    // 検索欄の入力開始
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    // キャンセルボタンをタップ
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    // 検索ボタンをタップ
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        // TODO:api通信を呼ぶ
        guard let text = searchBar.text else { return }
        fetchYoutubeSearchInfo(searchText: text)
    }
    
}

// MARK: - api通信
extension SearchViewController {
    
    // MARK: YoutubeAPIで検索
    private func fetchYoutubeSearchInfo(searchText: String) {
        let parms = [
            "q": searchText,
            "part": "snippet"
        ]
        API.shared.request(path: .search, parms: parms, type: Video.self) { (video) in
            self.video = video
            self.fetchYoutubeChannelInfo()
         }
    }
    // MARK: YoutubeAPIでチャンネルを検索
    private func fetchYoutubeChannelInfo() {
        guard let video = self.video else { return }
        
        for (index,item) in video.items.enumerated() {
            
            let parms = [
                "id": item.snippet.channelId,
                "part": "snippet,statistics"
            ]
            API.shared.request(path: .channels, parms: parms, type: Channel.self) { (channel) in
                self.video?.items[index].channel = channel
                self.videoCollectionView.reloadData()
            }

        }
        
    }

}
