//
//  VideoViewController.swift
//  YoutubeApp
//
//  Created by yasuyoshi on 2021/04/07.
//

import UIKit
//
import Nuke

class VideoViewController: UIViewController {
    
    var selectedItem: Item?
    
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var videoImageViewHeightConstrait: NSLayoutConstraint!
    @IBOutlet weak var videoImageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoImageViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var channelSubscriberCountLabel: UILabel!
    @IBOutlet weak var baseBackGroundView: UIView!
    @IBOutlet weak var backView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3) {
            self.baseBackGroundView.alpha = 1
        }
    }
    //
    private func setupViews() {
        // ビデオイメージビュー
        videoImageView.contentMode = .scaleAspectFill
        videoImageView.isUserInteractionEnabled = true
        if let url = URL(string: selectedItem?.snippet.thumbnails.medium.url ?? "" ) {
            Nuke.loadImage(with: url, into: videoImageView)
        }
        // チャンネルイメージビュー
        channelImageView.contentMode = .scaleAspectFill
        channelImageView.layer.cornerRadius = channelImageView.frame.size.height / 2
        if let channelUrl = URL(string: selectedItem?.channel?.items[0].snippet.thumbnails.medium.url ?? "") {
            Nuke.loadImage(with: channelUrl, into: channelImageView)
        }
        videoTitleLabel.text = selectedItem?.snippet.title
        channelTitleLabel.text = selectedItem?.channel?.items[0].snippet.title
        channelSubscriberCountLabel.text = "チャンネル登録者数 " + (selectedItem?.channel?.items[0].statistics.subscriberCount)!

    }
    // パンジェスチャー
    @IBAction func panVideoImageView(_ gesture: UIPanGestureRecognizer) {
        guard let imageView = gesture.view else { return }
        let move = gesture.translation(in: imageView)
        
        if gesture.state == .changed {
            // x:横方向の動き、y:縦方向の動き
            imageView.transform = CGAffineTransform(translationX: 0, y: move.y)
            // imageViewの左右のpadding設定
            let movingConstant = move.y / 30
            if movingConstant < 12 {
                videoImageViewTrailingConstraint.constant = movingConstant
                videoImageViewLeadingConstraint.constant = movingConstant
            }
            // imageViewの高さの動き（最大値：280 - 最小値：70 = 210）
            let parantViewHeight = self.view.frame.height
            let heightRatio = 210 / (parantViewHeight - (parantViewHeight / 6))
            let moveHeight = move.y * heightRatio
            videoImageViewHeightConstrait.constant = 280 - moveHeight
            // imageViewの横幅の動き(最小値が150
            let originalWidth = self.view.frame.width
            let minimumImageViewTrailingConstant = originalWidth - (150 - 12)
            let constant = originalWidth - move.y
            if minimumImageViewTrailingConstant < (constant * -1) {
                videoImageViewTrailingConstraint.constant = minimumImageViewTrailingConstant
                return
            }
            if constant < -12 {
                videoImageViewTrailingConstraint.constant = constant * -1
            }
            
        } else if gesture.state == .ended {
            // アニメーション
            // durationはアニメーション時間
            // delayは開始までの遅延時間
            // usingSpringWithDampingは振幅の大きさを指定(1.0が最大で、この値が小さいほど振幅が大きくなる)
            // initialSpringVelocityは、アニメーションの初速
            // optionsではアニメーション中に使用するタイミング曲線の種類やアニメーションの逆再生などを指定
            // animationsクロージャの中でアニメーションしたいUIViewクラスのプロパティの値を変更
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: []) {
                self.backToIdentitiyAllViews(imageView: imageView as! UIImageView)
            }
            
        }
        
    }
    
    private func backToIdentitiyAllViews(imageView: UIImageView) {
        // .identity 元の位置
        imageView.transform = .identity
        self.videoImageViewHeightConstrait.constant = 280
        self.videoImageViewLeadingConstraint.constant = 0
        self.videoImageViewTrailingConstraint.constant = 0
        // 確実に反映させる
        self.view.layoutIfNeeded()
    }


}
