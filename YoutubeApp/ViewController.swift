//
//  ViewController.swift
//  YoutubeApp
//
//  Created by yasuyoshi on 2021/04/05.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var videoListCollectionView: UICollectionView!
    private let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoListCollectionView.backgroundColor = .red
        videoListCollectionView.delegate = self
        videoListCollectionView.dataSource = self
        
        videoListCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
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
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = videoListCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        
        cell.backgroundColor = .green
        
        return cell
    }
    
    
    
    
}
