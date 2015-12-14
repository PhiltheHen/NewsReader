//
//  NRConstants.swift
//  NewsReader
//
//  Created by Philip Henson on 12/12/15.
//  Copyright © 2015 Phil Henson. All rights reserved.
//

import Foundation
import UIKit

struct Constants {

    static let storyEntity = "Story"
    static let feedURLString = "https://www.apple.com/main/rss/hotnews/hotnews.rss"
    static let maxStoriesToParse = 30
    static let sizeOfStoryBatch = 10
    static let headerHeight = CGFloat(150)

    struct Story {
        static let item = "item"
        static let title = "title"
        static let description = "description"
        static let textDescription = "textDescription"
        static let link = "link"
        static let pubDate = "pubDate"

        static let notificationName = "AddStoryNotif"
        static let resultsKey = "StoryResultsKey"
        static let errorNotificationName = "StoryErrorNotif"
        static let messageErrorKey = "StoryMsgErrorKey"
    }

}