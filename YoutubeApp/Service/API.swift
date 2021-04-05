//
//  APIRequest.swift
//  YoutubeApp
//
//  Created by yasuyoshi on 2021/04/05.
//

import Foundation
//
import Alamofire

class API {
    
    // シングルトンにする(毎回インスタンス化せずに、APIRequest.shared.request で使えるようになる）
    static let shared = API()
    // YoutubeAPI
    private let baseUrl = "https://www.googleapis.com/youtube/v3/"
    // APIKey
    private var apiKey = String()
    //
    enum PathType: String {
        case search
        case channels
    }
    
    // MARK: - init
    //
    init() {
        let filePath = Bundle.main.path(forResource: "YoutubeApp", ofType:"plist" )
        let plist = NSDictionary(contentsOfFile: filePath!)
        apiKey = plist!["ApiKey"] as! String
    }

    // MARK: - request
    // <T: Decodable> Genericsの書き方
    func request<T: Decodable>(path: PathType, parms: [String: Any], type: T.Type, completion: @escaping (T) -> Void) {
        let path = path.rawValue
        let url = baseUrl + path + "?"
        var parms = parms
        parms["key"] = apiKey
        parms["part"] = "snippet"
        let request = AF.request(url, method: .get, parameters: parms)
        request.responseJSON { (response) in
            print("response: ", response)
            guard let statusCode = response.response?.statusCode else { return }
            if statusCode <= 300 {
                do {
                    guard let data = response.data else { return }
                    let decoder = JSONDecoder()
                    let value = try decoder.decode(T.self, from: data)
                    completion(value)
                } catch {
                    print("変換に失敗しました: ", error)
                }
            }
        }

    }

}
