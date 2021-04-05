//
//  BaseTabBarController.swift
//  YoutubeApp
//
//  Created by yasuyoshi on 2021/04/05.
//

import UIKit

class BaseTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers?.enumerated().forEach({ (index,viewController) in
            switch index {
            case 0:
                setTabBarInfo(viewController,selectedImage: "home-select",unselectedImageName: "home",title: "ホーム")
            case 1:
                setTabBarInfo(viewController,selectedImage: "explore-select",unselectedImageName: "explore",title: "検索")
            case 2:
                setTabBarInfo(viewController,selectedImage: "bell-select",unselectedImageName: "bell",title: "通知")
            case 3:
                setTabBarInfo(viewController,selectedImage: "channel-select",unselectedImageName: "channel",title: "登録チャンネル")
            case 4:
                setTabBarInfo(viewController,selectedImage: "liblary-select",unselectedImageName: "liblary",title: "ライブラリ")
            default :
                break
            }
        })
        
    }
    
     private func setTabBarInfo(_ viewController: UIViewController, selectedImage: String, unselectedImageName: String, title: String) {
        viewController.tabBarItem.selectedImage = UIImage(named: selectedImage)?.resize(size: CGSize(width: 25, height: 25))?.withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem.image = UIImage(named: unselectedImageName)?.resize(size: CGSize(width: 25, height: 25))?.withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem.title = title
    }

}
