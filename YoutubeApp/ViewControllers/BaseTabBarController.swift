//
//  BaseTabBarController.swift
//  YoutubeApp
//
//  Created by yasuyoshi on 2021/04/05.
//

import UIKit

enum ControllerName: Int {
    case home, explore, videoAdd, channel, liblary
}

class BaseTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
    }
    
    private func setupViewControllers() {
        viewControllers?.enumerated().forEach({ (index,viewController) in
            
            if let name = ControllerName.init(rawValue: index) {
                switch name {
                case .home:
                    setTabBarInfo(viewController,selectedImage: "home-select",unselectedImageName: "home",title: "ホーム",size: 25)
                case .explore:
                    setTabBarInfo(viewController,selectedImage: "explore-select",unselectedImageName: "explore",title: "検索",size: 25)
                case .videoAdd:
                    setTabBarInfo(viewController,selectedImage: "videoadd-select",unselectedImageName: "videoadd",title: "",size: 40)
                case .channel:
                    setTabBarInfo(viewController,selectedImage: "channel-select",unselectedImageName: "channel",title: "登録チャンネル",size: 25)
                case .liblary:
                    setTabBarInfo(viewController,selectedImage: "library-select",unselectedImageName: "liblary",title: "ライブラリ",size: 25)
                }
            }
            
        })
    }
    
    private func setTabBarInfo(_ viewController: UIViewController, selectedImage: String, unselectedImageName: String, title: String, size: CGFloat) {
        viewController.tabBarItem.selectedImage = UIImage(named: selectedImage)?.resize(size: CGSize(width: size, height: size))?.withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem.image = UIImage(named: unselectedImageName)?.resize(size: CGSize(width: size, height: size))?.withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem.title = title
    }
    
}
