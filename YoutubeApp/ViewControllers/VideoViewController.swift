//
//  VideoViewController.swift
//  YoutubeApp
//
//  Created by yasuyoshi on 2021/04/07.
//

import UIKit
//
import Nuke
//import YoutubePlayer_in_WKWebView
import youtube_ios_player_helper

class VideoViewController: UIViewController, YTPlayerViewDelegate {
    
    var selectedItem: Item?
    
    private var imageViewCenterY: CGFloat?
    var videoImageMaxY: CGFloat {
        let ecludeValue = self.view.safeAreaInsets.bottom + (imageViewCenterY ?? 0)
        return self.view.frame.maxY - ecludeValue
    }
    var minimumImageViewTrailingConstant: CGFloat {
        view.frame.width - (164 - 12)
    }
    
    // YoutubePlayer
    @IBOutlet weak var youtubePlayerView: YTPlayerView!
    @IBOutlet weak var youtubePlayerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var youtubePlayerViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var youtubePlayerViewTrailingConstraint: NSLayoutConstraint!
    
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
        // ビデオプレイヤー
        guard let videId = self.selectedItem?.id.videoId else { return }
//        youtubePlayerView.load(withVideoId: videId, playerVars: ["playsinline":1])
        youtubePlayerView.load(withVideoId: videId)
    }
    //
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
//        self.youtubePlayerView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            UIView.animate(withDuration: 0.3) {
                self.youtubePlayerView.alpha = 1
            }
        }

    }
    //
    private func setupViews() {
        youtubePlayerView.delegate = self

        // youtubePlayerViewを最前面に移動
//        youtubePlayerView.isHidden = true
        youtubePlayerView.alpha = 0
        
        self.view.bringSubviewToFront(youtubePlayerView)

        imageViewCenterY = youtubePlayerView.center.y
        
        // チャンネルイメージビュー
        channelImageView.contentMode = .scaleAspectFill
        channelImageView.layer.cornerRadius = channelImageView.frame.size.height / 2
        if let channelUrl = URL(string: selectedItem?.channel?.items[0].snippet.thumbnails.medium.url ?? "") {
            Nuke.loadImage(with: channelUrl, into: channelImageView)
        }
        guard let videoTitle = selectedItem?.snippet.title else { return }
        videoTitleLabel.text = videoTitle
        channelTitleLabel.text = selectedItem?.channel?.items[0].snippet.title
        channelSubscriberCountLabel.text = "チャンネル登録者数 " + (selectedItem?.channel?.items[0].statistics.subscriberCount)!

    }
    
    
    @IBAction func tapVideoImageView(_ sender: Any) {
        
    }
    
    // パンジェスチャー(YoutubePlayerView)
    @IBAction func panYoutubePlayerView(_ gesture: UIPanGestureRecognizer) {
        guard let YoutubePlayerView = gesture.view else { return }
        let move = gesture.translation(in: YoutubePlayerView)
        
        if gesture.state == .changed {
            // 最大値までドラッグしたら止める
            if videoImageMaxY <= move.y {
                moveToBottom(YTView: YoutubePlayerView as! YTPlayerView)
                return
            }
            
            // imageViewをドラッグに合わせて下に移動
            YoutubePlayerView.transform = CGAffineTransform(translationX: 0, y: move.y)
            videoImageBackView.transform = CGAffineTransform(translationX: 0, y: move.y)
            
            // imageViewの左右のpadding設定
            adjustPaddingChange(move: move)
            
            // imageViewの高さの動き（最大値：280 - 最小値：70 = 210）
            adjustHeigtChange(move: move)
            
            // Alpha値の設定
            adjustAlphaChange(move: move)
            
            // imageViewの横幅の動き(最小値が150)
            adjustWidthChange(move: move)
            
        } else if gesture.state == .ended {
            imageViewEndedAnimation(move: move, YTView: YoutubePlayerView as! YTPlayerView)
         }

    }
    
    
    // MARK: - パンジェスチャーの state == .changed の動き
    // 左右の余白調整
    private func adjustPaddingChange(move: CGPoint) {
        let movingConstant = move.y / 30
        if movingConstant < 12 {
            
            youtubePlayerViewTrailingConstraint.constant = -movingConstant
            youtubePlayerViewLeadingConstraint.constant = movingConstant

            backViewTrailingConstraint.constant = -movingConstant
        }
     }
    // imageViewの高さの動き（最大値：280 - 最小値：70 = 210）
    private func adjustHeigtChange(move: CGPoint) {
        let parantViewHeight = self.view.frame.height
        let heightRatio = 210 / videoImageMaxY
        let moveHeight = move.y * heightRatio
        backViewTopConstraint.constant = move.y
        youtubePlayerViewHeightConstraint.constant = 280 - moveHeight
        describeViewTopConstraint.constant = move.y * 0.8
        
        let bottomMoveY = parantViewHeight - videoImageMaxY
        let bottomMoveRatio = bottomMoveY / videoImageMaxY
        let bottomMoveConstant = move.y * bottomMoveRatio
        backViewBottomConstraint.constant = bottomMoveConstant

    }
    // alpha値の設定
    private func adjustAlphaChange(move: CGPoint) {
        let alphaRatio = move.y / (self.view.frame.height / 2)
        describeView.alpha = 1 - alphaRatio
        baseBackGroundView.alpha = 1 - alphaRatio

    }
    // 横幅の動き(最小値が150)
    private func adjustWidthChange(move: CGPoint) {
        let originalWidth = self.view.frame.width
        let constant = originalWidth - move.y
        if minimumImageViewTrailingConstant < (constant * -1) {
            youtubePlayerViewTrailingConstraint.constant = -minimumImageViewTrailingConstant
            return
        }
        if constant < -12 {
            youtubePlayerViewTrailingConstraint.constant = constant
        }

    }
    
    // MARK: - パンジェスチャーの state == .ended の動き
    private func imageViewEndedAnimation(move: CGPoint,YTView: YTPlayerView) {
        if move.y < self.view.frame.height / 3 {
            // 元の位置に戻る
            // animate：アニメーション
            //  durationはアニメーション時間、delayは開始までの遅延時間、usingSpringWithDampingは振幅の大きさを指定(1.0が最大で、この値が小さいほど振幅が大きくなる)
            //  initialSpringVelocityは、アニメーションの初速、optionsではアニメーション中に使用するタイミング曲線の種類やアニメーションの逆再生などを指定
            //  animationsクロージャの中でアニメーションしたいUIViewクラスのプロパティの値を変更
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: []) {
                self.backToIdentitiyAllViews(YTView: YTView )
            }
        } else {
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: []) {
                
                self.moveToBottom(YTView: YTView )
                
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.backView.isHidden = true
                    // NotificationCenterで通知（別なビューにイメージを渡す）
                    let userInfo:[String:Any] = ["videoPlayerMinY": YTView.frame.minY,
                                                 "videoPlayerViewWidth": YTView.frame.width   ]
                    NotificationCenter.default.post(name: .init("thumnailImage"), object: nil, userInfo: userInfo as [AnyHashable : Any])
                    
                } completion: { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.7) {
                        self.dismiss(animated: false, completion: nil)
                    }
                }
            }
            
        }

    }
    //　下に小さく固定する(youtubePlayerView)
    private func moveToBottom(YTView: YTPlayerView) {
        // CGAffineTransform translationX x,y方向に指定したtranslationの分移動

        // imageViewの設定（ビデオ）
        YTView.transform = CGAffineTransform(translationX: 0, y: videoImageMaxY)
        
        youtubePlayerViewTrailingConstraint.constant = -minimumImageViewTrailingConstant
        youtubePlayerViewHeightConstraint.constant = 70   // 最小値の70
        youtubePlayerViewLeadingConstraint.constant = 12
        
        videoImageBackView.transform = CGAffineTransform(translationX: 0, y: videoImageMaxY)
        describeView.alpha = 0
        backView.alpha = 0
        baseBackGroundView.alpha = 0
//        print("videoImageView.frame.width: ",videoImageView.frame.width)
        // 確実に反映させる
        self.view.layoutIfNeeded()
    }
    // 元の位置に戻す
    private func backToIdentitiyAllViews(YTView: YTPlayerView) {
        // imageViewの設定 (.identity 元の位置)
        YTView.transform = .identity
        
        // youtubePlayerView
        youtubePlayerView.transform = .identity
        youtubePlayerViewHeightConstraint.constant = 280
        youtubePlayerViewLeadingConstraint.constant = 0
        youtubePlayerViewTrailingConstraint.constant = 0

        // backViewの設定
        backViewTrailingConstraint.constant = 0
        backViewBottomConstraint.constant = 0
        backViewTopConstraint.constant = 0
        backView.alpha = 1
        
        // describeViewの設定
        describeViewTopConstraint.constant = 0
        describeView.alpha = 1
        
        baseBackGroundView.alpha = 1

        // 確実に反映させる
        self.view.layoutIfNeeded()
    }


}

