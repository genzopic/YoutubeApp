//
//  VideoListCell.swift
//  YoutubeApp
//
//  Created by yasuyoshi on 2021/04/05.
//

import UIKit
//
import Nuke

class VideoListCell: UICollectionViewCell {
    
    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titileLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var videoItem: Item? {
        didSet {
            if let url = URL(string: videoItem?.snippet.thumbnails.medium.url ?? "" ) {
                Nuke.loadImage(with: url, into: thumbnailImageView)
            }
            if let channelUrl = URL(string: videoItem?.channel?.items[0].snippet.thumbnails.medium.url ?? "") {
                Nuke.loadImage(with: channelUrl, into: channelImageView)
            }
            titileLabel.text = videoItem?.snippet.title
            descriptionLabel.text = videoItem?.snippet.description
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        channelImageView.layer.cornerRadius = channelImageView.frame.size.width / 2
        
    }
    
}
