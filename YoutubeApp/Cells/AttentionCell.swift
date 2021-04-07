//
//  AttentionCell.swift
//  YoutubeApp
//
//  Created by yasuyoshi on 2021/04/06.
//

import UIKit

class AttentionCell: UICollectionViewCell {
    
    var videoItems = [Item]()

    private let attentionId = "attentionId"
    lazy var attentionCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        // 横スクロール
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        // オートレイアウトの設定
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        // delegate
        collectionView.delegate = self
        collectionView.dataSource = self
        
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        backgroundColor = .blue
        addSubview(attentionCollectionView)
        // オートレイアウトの設定
        [
        attentionCollectionView.topAnchor.constraint(equalTo: self.topAnchor),
        attentionCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        attentionCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
        attentionCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ].forEach { $0.isActive = true}
        // xibの登録
        attentionCollectionView.register(UINib(nibName: "AttentionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: attentionId)
        // 左右に余白をつける
        attentionCollectionView.contentInset = .init(top: 0, left: 15, bottom: 0, right: 15)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//
// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
//
extension AttentionCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // セルとセルの間を開ける
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = attentionCollectionView.dequeueReusableCell(withReuseIdentifier: attentionId, for: indexPath) as! AttentionCollectionViewCell
        cell.videoItem = videoItems[indexPath.row]
        return cell
    }
    // セルの大きさを指定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = self.frame.height
        
        return .init(width: height , height: height)
    }
    
    
}
