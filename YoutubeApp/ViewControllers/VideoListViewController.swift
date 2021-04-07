//
//  ViewController.swift
//  YoutubeApp
//
//  Created by yasuyoshi on 2021/04/05.
//

import UIKit
//
import Alamofire

class VideoListViewController: UIViewController {
    
    // ヘッダービュー
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerHightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    // プロフィールイメージ
    @IBOutlet weak var profileImageView: UIImageView!
    // コレクションビュー
    @IBOutlet weak var videoListCollectionView: UICollectionView!
    private let cellId = "cellId"
    private let attentionCellId = "attentionCellId"
    private var videoItems = [Item]()
    // ０．５秒前のスクロール位置
    private var prevContentOffset: CGPoint = .init(x: 0, y: 0)
    // ヘッダーの表示速度
    private let headerMoveHight: CGFloat = 3
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        fetchYoutubeSearchInfo()
        
    }
    // MARK: ビューの初期設定
    private func setupViews() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2
        
        videoListCollectionView.delegate = self
        videoListCollectionView.dataSource = self
        videoListCollectionView.register(UINib(nibName: "VideoListCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        videoListCollectionView.register(AttentionCell.self, forCellWithReuseIdentifier: attentionCellId)
        
    }
    
    // MARK: YoutubeAPIで検索
    private func fetchYoutubeSearchInfo() {
        let parms = [
            "q": "camp"
        ]
        API.shared.request(path: .search, parms: parms, type: Video.self) { (video) in
            self.videoItems = video.items
            let id = self.videoItems[0].snippet.channelId
            self.fetchYoutubeChannelInfo(id: id)
        }
    }
    // MARK: YoutubeAPIでチャンネルを検索
    private func fetchYoutubeChannelInfo(id: String) {
        let parms = [
            "id": id
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
    // MARK: ヘッダービューのアニメーション
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
        print("didSelectItemAt: ", indexPath.row)
        let storyboard = UIStoryboard(name: "Video", bundle: nil)
        let videoViewController = storyboard.instantiateViewController(identifier: "VideoViewController") as! VideoViewController
        videoViewController.modalPresentationStyle = .fullScreen
        present(videoViewController, animated: true, completion: nil)
        
    }
    
}
