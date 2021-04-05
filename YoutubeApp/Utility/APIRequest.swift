//
//  APIRequest.swift
//  YoutubeApp
//
//  Created by yasuyoshi on 2021/04/05.
//

import Foundation
//
import Alamofire

class APIRequest {
    
    // シングルトンにする(毎回インスタンス化せずに、APIRequest.shared.request で使えるようになる）
    static var shared = APIRequest()
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
    // <T: Decodable> Genericの書き方
    func request<T: Decodable>(path: PathType, parms: [String: Any], type: T.Type, completion: @escaping (T) -> Void) {
        // Youtube API
        let path = path.rawValue
        let url = baseUrl + path + "?"
        var parms = parms
        parms["key"] = apiKey
        parms["part"] = "snippet"
        let request = AF.request(url, method: .get, parameters: parms)
        request.responseJSON { (response) in
            print("response: ", response)
            guard let data = response.data else { return }
            let decode = JSONDecoder()
            do {
                let value = try decode.decode(T.self, from: data)
                completion(value)
            } catch {
                print("変換に失敗しました: ", error)
            }
        }

    }

}
