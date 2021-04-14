//
//  ViewController.swift
//  YoutubeApp
//
//  Created by yasuyoshi on 2021/04/05.
//

import UIKit
//
import Alamofire
import YoutubePlayer_in_WKWebView

class VideoListViewController: UIViewController, WKYTPlayerViewDelegate {
    
    // ヘッダービュー
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerHightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    //
    @IBOutlet weak var searchButton: UIButton!
    // プロフィールイメージ
    @IBOutlet weak var profileImageView: UIImageView!
    // コレクションビュー（ビデオリスト一覧）
    @IBOutlet weak var videoListCollectionView: UICollectionView!
    private let cellId = "cellId"
    private let attentionCellId = "attentionCellId"
    private var videoItems = [Item]()
    var selectedItem: Item?
    // bottomVideoViewの制約（サムネイルとタイトルなどを含む枠）
    @IBOutlet weak var bottomVideoView: UIView!
    @IBOutlet weak var bottomVideoViewTraing: NSLayoutConstraint!
    @IBOutlet weak var bottomVideoViewLeading: NSLayoutConstraint!
    @IBOutlet weak var bottomVideoViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomVideoViewBottom: NSLayoutConstraint!
    // bottomVideoImageの制約（サムネイル画像）
    @IBOutlet weak var bottomVideoImageView: UIImageView!
    @IBOutlet weak var bottomVideoImageWidth: NSLayoutConstraint!
    @IBOutlet weak var bottomVideoImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var bottomVideoPlayerView: WKYTPlayerView!
    @IBOutlet weak var bottomVideoPlayerWidth: NSLayoutConstraint!
    @IBOutlet weak var bottomVideoPlayerHeight: NSLayoutConstraint!
    //
    @IBOutlet weak var bottomSubscribeView: UIView!
    @IBOutlet weak var bottomVideoTitleLabel: UILabel!
    @IBOutlet weak var bottomVideoDescriptoin: UILabel!
    
    @IBOutlet weak var bottomCloseButton: UIButton!
    
    
    // ０．５秒前のスクロール位置
    private var prevContentOffset: CGPoint = .init(x: 0, y: 0)
    // ヘッダーの表示速度
    private let headerMoveHight: CGFloat = 3
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        fetchYoutubeSearchInfo()
        setupGestureRecognizer()
        setupNotifications()
        
    }
    
    private func setupNotifications() {
        // 動画再生画面から、下にドラッグした時に、通知を受け取り画面下に固定表示する
        NotificationCenter.default.addObserver(self, selector: #selector(showThumnailImage), name: .init("thumnailImage"), object: nil)
        // 検索画面からの通知を受けとる
        NotificationCenter.default.addObserver(self, selector: #selector(showSearchedItem), name: .init("searchedItem"), object: nil)
    }
    
    // MARK: 検索画面から遷移してきた時の処理
    @objc private func showSearchedItem() {
        let storyboard = UIStoryboard(name: "Video", bundle: nil)
        let videoViewController = storyboard.instantiateViewController(identifier: "VideoViewController") as! VideoViewController

        videoViewController.selectedItem = self.selectedItem
        bottomVideoView.isHidden = true
        present(videoViewController, animated: true, completion: nil)

    }
    
    // VideoView（サムネイル画面）から遷移してきた時の処理
    @objc private func showThumnailImage(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo as? [String:Any] else { return }
        guard let videoPlayerMinY = userInfo["videoPlayerMinY"] as? CGFloat else { return }
        guard let videoPlayerViewWidth = userInfo["videoPlayerViewWidth"] as? CGFloat else { return }
        
        let diffBottomConstant = videoPlayerMinY - bottomVideoView.frame.minY
        bottomVideoPlayerWidth.constant = videoPlayerViewWidth
        bottomVideoViewBottom.constant -= diffBottomConstant
        bottomVideoTitleLabel.text = selectedItem?.snippet.title
        bottomVideoDescriptoin.text = selectedItem?.snippet.description

        bottomVideoView.isHidden = false
        bottomSubscribeView.isHidden = false
        bottomVideoPlayerView.isHidden = true
        bottomVideoPlayerView.load(withVideoId: (selectedItem?.id.videoId)!)

    }
    
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        bottomVideoPlayerView.isHidden = false
    }
    
    // MARK: ビューの初期設定
    private func setupViews() {
        
        bottomVideoPlayerView.delegate = self
        
        // 最前面にbottomVideoViewを表示
        view.bringSubviewToFront(bottomVideoView)
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2
        
        videoListCollectionView.delegate = self
        videoListCollectionView.dataSource = self
        videoListCollectionView.register(UINib(nibName: "VideoListCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        videoListCollectionView.register(AttentionCell.self, forCellWithReuseIdentifier: attentionCellId)
        
        bottomVideoView.isHidden = true
        
        bottomCloseButton.addTarget(self, action: #selector(tappedCloseButton), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(tappedSearchButton), for: .touchUpInside)
    }
    
    @objc private func tappedCloseButton() {
        
        UIView.animate(withDuration: 0.2) {
            self.bottomVideoViewBottom.constant = -150
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.bottomVideoView.isHidden = true
            self.selectedItem = nil
        }
        
    }
    
    @objc private func tappedSearchButton() {
        
        let searchViewController = SearchViewController()
        let nav = UINavigationController(rootViewController: searchViewController)
        self.present(nav, animated: true, completion: nil)
        
    }
    
}

//
// MARK: API通信
//
extension VideoListViewController {
    
    // MARK: YoutubeAPIで検索
    private func fetchYoutubeSearchInfo() {
        let parms = [
            "q": "drikin",
            "part": "snippet",
            "type": "video",
            "maxResults": 10
        ] as [String : Any]
        API.shared.request(path: .search, parms: parms, type: Video.self) { (video) in
            self.videoItems = video.items
            let id = self.videoItems[0].snippet.channelId
            self.fetchYoutubeChannelInfo(id: id)
        }
    }
    // MARK: YoutubeAPIでチャンネルを検索
    private func fetchYoutubeChannelInfo(id: String) {
        let parms = [
            "id": id,
            "part": "snippet,statistics"
        ]
        API.shared.request(path: .channels, parms: parms, type: Channel.self) { (channel) in
            self.videoItems.forEach { (item) in
                item.channel = channel
            }
            self.videoListCollectionView.reloadData()
        }
    }

}

//
// MARK: - スクロール処理
//
extension VideoListViewController {
    // MARK: スクロールした時に呼ばれる
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerAnimation(scrollView: scrollView)
    }
    private func headerAnimation(scrollView: UIScrollView) {
        // 0.5秒前のスクロール位置を退避
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.prevContentOffset = scrollView.contentOffset
        }
        // 現在のスクロール位置から、表示されているセルの位置を取得して、最後のセルの１つ前まで来たら余分な動作をしないようにする
        guard let presentIndexPath = videoListCollectionView.indexPathForItem(at: scrollView.contentOffset) else { return }
        if presentIndexPath.row >= videoItems.count - 2 { return }
        // 一番上が表示された状態で下にひっぱた時は、余分な動作をしないようにする
        if scrollView.contentOffset.y < 0 { return }
        // 透過値
        let alphaRatio = 1 / headerHightConstraint.constant
        // headerTopConstraintは、０が初期値
        if self.prevContentOffset.y < scrollView.contentOffset.y {
            // 下にスクロールしている時は、徐々に隠す
            if headerTopConstraint.constant < -headerHightConstraint.constant { return }
            headerTopConstraint.constant -= headerMoveHight
            headerView.alpha -= alphaRatio * headerMoveHight
        } else if self.prevContentOffset.y > scrollView.contentOffset.y {
            // 上にスクロールしている、徐々に表示する
            if headerTopConstraint.constant >= 0 { return }
            headerTopConstraint.constant += headerMoveHight
            headerView.alpha += alphaRatio * headerMoveHight
        }

    }
    // MARK: スクロールがピタッと止まった時
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // decelerate == true → ドラッグ開始
        // decelerate == false → ドラッグ終了
        if !decelerate {
            // ドラッグしてピタッと指で止めた時
            headerViewEndAnimation()
        }
    }
    // MARK: 惰性でスクロールしたものが止まった時
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
         headerViewEndAnimation()
    }

}

//
// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
//
extension VideoListViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // サイズ調整
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        if indexPath.row == 2 {
            // AttensionCollectionView
            return .init(width: width, height: 200)
        } else {
            // VideoListCell
            return .init(width: width, height: width)
        }
    }
    // セルの数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // AttentionCollectionViewの分をプラス１しておく
        return videoItems.count + 1
    }
    // セルの構築
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 2 {
            let cell = videoListCollectionView.dequeueReusableCell(withReuseIdentifier: attentionCellId, for: indexPath) as! AttentionCell
            cell.videoItems = self.videoItems
            return cell
        } else {
            let cell = videoListCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! VideoListCell
            if self.videoItems.count == 0 { return cell }
            if indexPath.row > 2 {
                cell.videoItem = videoItems[indexPath.row - 1]
            } else {
                cell.videoItem = videoItems[indexPath.row]
            }
            return cell
        }
    }
    // タップで遷移
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Video", bundle: nil)
        let videoViewController = storyboard.instantiateViewController(identifier: "VideoViewController") as! VideoViewController

        if videoItems.count == 0 {
            videoViewController.selectedItem = nil
            self.selectedItem = nil
        } else {
            if indexPath.row > 2 {
                let item = videoItems[indexPath.row - 1]
                videoViewController.selectedItem = item
                self.selectedItem = item
            } else {
                let item = videoItems[indexPath.row]
                videoViewController.selectedItem = item
                self.selectedItem = item
            }
        }
        bottomVideoView.isHidden = true
        present(videoViewController, animated: true, completion: nil)
        
    }
    
}

//
// MARK: - アニメーション
//
extension VideoListViewController {
    
    // ヘッダービューのアニメーション
    private func headerViewEndAnimation() {
        if headerTopConstraint.constant < -headerHightConstraint.constant / 2 {
            // 半分以上 隠れたら隠す
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.8, options: []) {
                self.headerTopConstraint.constant = -self.headerHightConstraint.constant
                self.headerView.alpha = 0
                self.view.layoutIfNeeded()
            }
        } else {
            // 半分以上 表示されたら隠す
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.8, options: []) {
                self.headerTopConstraint.constant = 0
                self.headerView.alpha = 1
                self.view.layoutIfNeeded()
            }
        }
    }
    // ジェスチャーイベントの準備
    private func setupGestureRecognizer() {
        // 画面下のビデオイメージをパンした時の処理を追加
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panBottomVideoView))
        bottomVideoView.addGestureRecognizer(panGesture)
        // 画面下のビデオイメージをタップの処理を追加
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapBottomVideoView))
        bottomVideoView.addGestureRecognizer(tapGesture)
    }
    // ビデオのパン
    @objc private func panBottomVideoView(gesture: UIPanGestureRecognizer) {
        let move = gesture.translation(in: view)
        guard let imageView = gesture.view else { return }
        if gesture.state == .changed {
            imageView.transform = CGAffineTransform(translationX: move.x, y: move.y)
        } else if gesture.state == .ended {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: []) {
                imageView.transform = .identity
                self.view.layoutIfNeeded()
            }
        }
    }
    // ビデオのタップ
    @objc private func tapBottomVideoView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: []) {
            self.bottomSubscribeView.isHidden = true
            self.bottomVideoViewExpandAnimation()
        } completion: { _ in
            let storyboard = UIStoryboard(name: "Video", bundle: nil)
            let videoViewController = storyboard.instantiateViewController(identifier: "VideoViewController") as! VideoViewController
            videoViewController.selectedItem = self.selectedItem
            self.present(videoViewController, animated: false, completion: nil)
            self.bottomVideoViewBackToIdentity()
        }

    }
    
    private func bottomVideoViewExpandAnimation() {
        
        let topSafeArea = self.view.safeAreaInsets.top
        let bottomSafeArea = self.view.safeAreaInsets.bottom
                
        // bottomVideoView
        bottomVideoViewLeading.constant = 0
        bottomVideoViewTraing.constant = 0
        bottomVideoViewBottom.constant = -bottomSafeArea
        bottomVideoViewHeight.constant = self.view.frame.height - topSafeArea
        // bottomVideoImageView
        bottomVideoImageWidth.constant = self.view.frame.width
        bottomVideoImageHeight.constant = 280
        //
        tabBarController?.tabBar.isHidden = true
        // アニメーションを実行するためにこれが必須
        self.view.layoutIfNeeded()

    }
    
    private func bottomVideoViewBackToIdentity() {

        // bottomVideoView
        bottomVideoViewLeading.constant = 12
        bottomVideoViewTraing.constant = 12
        bottomVideoViewBottom.constant = 19
        bottomVideoViewHeight.constant = 70
        // bottomVideoImageView
        bottomVideoImageWidth.constant = 126
        bottomVideoImageHeight.constant = 70
        //
        bottomVideoView.isHidden = true
        tabBarController?.tabBar.isHidden = false

    }

    
}
    
