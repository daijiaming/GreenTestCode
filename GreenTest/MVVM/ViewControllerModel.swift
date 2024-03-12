//
//  ViewControllerModel.swift
//  GreenTest
//
//  Created by djm on 2024/3/7.
//

import Foundation
import RxSwift

struct MusiciTunesApiResponse: Codable {
    var resultCount: Int
    var results: [MusicModel]
}

struct MusicModel: Codable {
    /// 封面
    var artworkUrl60: String?
    /// 艺术家姓名
    var artistName: String?
    /// 曲目名称
    var trackName: String?
    /// 价格
    var trackPrice: Double?
    /// 发布日期
    var releaseDate: String?
}

/*
 Section II - Write an application (90%)
 Story
 AC1:Get song data from iTunes API
 Implement a network request function that fetches song data from the iTunes API.
 Parse the API response to extract relevant information such as artist name, track name, price, rating, and release date.
 Ensure error handling is in place to handle any errors that occur during the API request and display appropriate error messages to the user.
 API as follows: https://itunes.apple.com/search?term=歌&limit=200&country=HK
 */
class MusicModelServer: NSObject {
    private let urlString = "https://itunes.apple.com/search?term=歌&限额=200&国家=香港".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    
    func getiTunesApiData() -> Observable<[MusicModel]> {
        let url = URL(string: urlString)!
        return URLSession.shared.rx.data(request: URLRequest(url: url))
            .map { data in
                if let result = try? JSONDecoder().decode(MusiciTunesApiResponse.self, from: data).results {
                    let dataArr = result.sorted {
                        ($0.artistName ?? "").lowercased() < ($1.artistName ?? "").lowercased()
                    }
                    return dataArr
                }
                return []
            }
    }
    
    func search(_ array: [MusicModel], text: String, sortType: SortType) -> [MusicModel] {
        if text.isEmpty {
            return array
        }
        let t = text.lowercased()
        return array.filter {
            let artistName = ($0.artistName ?? "").lowercased()
            let trackName = ($0.trackName ?? "").lowercased()
            return artistName.contains(t) || trackName.contains(t)
        }
    }

    func sortedByPrice(_ array: [MusicModel], sortType: SortType) -> [MusicModel] {
        if array.count == 0 || sortType == .off {
            return array
        }
        let rst = array.sorted {
            let mTrackPrice = $0.trackPrice ?? 0.0
            let nTrackPrice = $1.trackPrice ?? 0.0
            return mTrackPrice < nTrackPrice
        }
        return rst
    }
}
