//
//  AttentionCollectionViewCell.swift
//  YoutubeApp
//
//  Created by yasuyoshi on 2021/04/07.
//

import UIKit
//
import Nuke

class AttentionCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    
    var videoItem: Item? {
        didSet{
            if let url = URL(string: videoItem?.snippet.thumbnails.medium.url ?? "" ) {
                Nuke.loadImage(with: url, into: thumbnailImageView)
            }
            videoTitleLabel.text = videoItem?.snippet.title
            channelTitleLabel.text = videoItem?.channel?.items[0].snippet.title
            descriptionLabel.text = videoItem?.snippet.description
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

}
