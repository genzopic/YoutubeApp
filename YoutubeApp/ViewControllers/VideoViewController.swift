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
    
    private var imageViewCenterY: CGFloat?
    var videoImageMaxY: CGFloat {
        let ecludeValue = self.view.safeAreaInsets.bottom + (imageViewCenterY ?? 0)
        return self.view.frame.maxY - ecludeValue
    }
    
    // videoImageView
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var videoImageViewHeightConstrait: NSLayoutConstraint!
    @IBOutlet weak var videoImageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoImageViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var videoImageBackView: UIView!
    
    
    // backView
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var backViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var backViewBottomConstraint: NSLayoutConstraint!
    // describeView
    @IBOutlet weak var describeView: UIView!
    @IBOutlet weak var describeViewTopConstraint: NSLayoutConstraint!
    //
    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var channelSubscriberCountLabel: UILabel!
    @IBOutlet weak var baseBackGroundView: UIView!
    
    
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
        // videoImageViewを最前面に移動
        self.view.bringSubviewToFront(videoImageView)
        
        imageViewCenterY = videoImageView.center.y
        
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

        print("videoImageMaxY: ",videoImageMaxY)
    }
    // パンジェスチャー
    @IBAction func panVideoImageView(_ gesture: UIPanGestureRecognizer) {
        guard let imageView = gesture.view else { return }
        let move = gesture.translation(in: imageView)
        
        if gesture.state == .changed {
            print("videoImageMaxY: ",videoImageMaxY)
            print("move.y: ",move.y)
            // 最大値までドラッグしたら止める
            if videoImageMaxY <= move.y {
                moveToBottom(imageView: imageView as! UIImageView)
                return
            }
            
            // imageViewをドラッグに合わせて下に移動
            imageView.transform = CGAffineTransform(translationX: 0, y: move.y)
            videoImageBackView.transform = CGAffineTransform(translationX: 0, y: move.y)
            
            // imageViewの左右のpadding設定
            let movingConstant = move.y / 30
            if movingConstant < 12 {
                videoImageViewTrailingConstraint.constant = movingConstant
                videoImageViewLeadingConstraint.constant = movingConstant

                backViewTrailingConstraint.constant = movingConstant
            }
            
            // imageViewの高さの動き（最大値：280 - 最小値：70 = 210）
            let parantViewHeight = self.view.frame.height
            let heightRatio = 210 / (parantViewHeight - (parantViewHeight / 6))
            let moveHeight = move.y * heightRatio
            backViewTopConstraint.constant = move.y
            videoImageViewHeightConstrait.constant = 280 - moveHeight
            describeViewTopConstraint.constant = move.y * 0.8
            
            let bottomMoveY = parantViewHeight - videoImageMaxY
            let bottomMoveRatio = bottomMoveY / videoImageMaxY
            let bottomMoveConstant = move.y * bottomMoveRatio
            backViewBottomConstraint.constant = bottomMoveConstant
            
            // Alpha値の設定
            let alphaRatio = move.y / (parantViewHeight / 2)
            describeView.alpha = 1 - alphaRatio
            baseBackGroundView.alpha = 1 - alphaRatio
            
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
    //
    private func moveToBottom(imageView: UIImageView) {
        // CGAffineTransform translationX x,y方向に指定したtranslationの分移動
        videoImageBackView.transform = CGAffineTransform(translationX: 0, y: videoImageMaxY)
        imageView.transform = CGAffineTransform(translationX: 0, y: videoImageMaxY)
        backView.transform = CGAffineTransform(translationX: 0, y: videoImageMaxY)
    }
    // 元の位置に戻す
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
