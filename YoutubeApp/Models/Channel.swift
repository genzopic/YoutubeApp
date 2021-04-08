//
//  Channel.swift
//  YoutubeApp
//
//  Created by yasuyoshi on 2021/04/05.
//

import Foundation

class Channel: Decodable {
    let items: [ChannelItems]
}

class ChannelItems: Decodable {
    let id: String
    let snippet: ChannelSnippet
    let statistics: Statistics
}

class ChannelSnippet: Decodable {
    let title: String
    let description: String
    let publishedAt: String
    let thumbnails: ChannelThumbnail
}

class ChannelThumbnail: Decodable {
    let medium: ChannelThumbnailDetail
}

class ChannelThumbnailDetail: Decodable {
    let url: String
    let width: Int
    let height: Int
}

class Statistics: Decodable {
    let viewCount: String
    let subscriberCount: String
    let hiddenSubscriberCount: Bool
    let videoCount: String
}
