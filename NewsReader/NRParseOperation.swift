//
//  NRParseOperation.swift
//  NewsReader
//
//  Created by Philip Henson on 12/12/15.
//  Copyright © 2015 Phil Henson. All rights reserved.
//
//  Adapted from Apple Developer Resources

import Foundation
import CoreData
import UIKit

class NRParseOperation: NSObject, NSXMLParserDelegate {
    var stories = [NRStoryMO]()

    var parsedStoriesCounter = 0
    var accumulatingParsedCharactersData: Bool?
    var didAbortParsing: Bool?
    var currentStoryObject: NRStoryMO?
    var currentParseBatch: [NRStoryMO]?
    var currentParsedCharactersData = ""
    let appDelegate = UIApplication.sharedApplication().delegate as! NRAppDelegate
    let dateFormatter = NSDateFormatter()

    // MARK: - Parse Helper
    func parseDataWithURL(urlToParse: NSURL) {

        // Remove all managed objects from context
        appDelegate.dataController.managedObjectContext.reset()
        let fetchRequest = NSFetchRequest(entityName: Constants.storyEntity)
        do {
            let results = try appDelegate.dataController.managedObjectContext.executeFetchRequest(fetchRequest) as! [NRStoryMO]
            for storyObject in results {
                appDelegate.dataController.managedObjectContext.deleteObject(storyObject)
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

        // Set up date formatter to convert the pubDate String to NSDate
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"

        // Parse XML Data from url
        let parser = NSXMLParser(contentsOfURL: urlToParse)
        currentParseBatch = [NRStoryMO]()
        parser?.delegate = self
        parser?.parse()

        if currentParseBatch?.count > 0 {
            performSelectorOnMainThread("addStoriesToList:", withObject: currentParseBatch, waitUntilDone: false)
        }
    }


    // MARK: - Parser Delegate Methods
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if (parsedStoriesCounter >= Constants.maxStoriesToParse) {
            didAbortParsing = true
            parser.abortParsing()
        }

        // Create NSManagedObject for each "item" we find in the XML file
        if (elementName == Constants.Story.item) {
            let story = NRStoryMO(entity: NSEntityDescription.entityForName("Story", inManagedObjectContext: appDelegate.dataController.managedObjectContext)!, insertIntoManagedObjectContext: appDelegate.dataController.managedObjectContext)
            currentStoryObject = story

        // Read everything else in to the buffer
        } else if ((elementName == Constants.Story.title && elementName != "Apple Hot News") ||
            elementName == Constants.Story.description ||
            elementName == Constants.Story.link ||
            elementName == Constants.Story.pubDate) {
                accumulatingParsedCharactersData = true
                currentParsedCharactersData = ""
        }
    }

    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

        // Add new story objects and save to Core Data, updating the table view when the batch size is reached
        if elementName == Constants.Story.item {
            currentParseBatch?.append(currentStoryObject!)
            parsedStoriesCounter++
            if (currentParseBatch?.count >= Constants.sizeOfStoryBatch) {
                performSelectorOnMainThread("addStoriesToList:", withObject: currentParseBatch, waitUntilDone: false)
            }
        } else if elementName == Constants.Story.title {
            currentStoryObject?.setValue(currentParsedCharactersData, forKey: Constants.Story.title)
        } else if elementName == Constants.Story.description {
            currentStoryObject?.setValue(currentParsedCharactersData, forKey: Constants.Story.textDescription)
        } else if elementName == Constants.Story.link {
            currentStoryObject?.setValue(currentParsedCharactersData, forKey: Constants.Story.link)
        } else if elementName == Constants.Story.pubDate {

            currentStoryObject?.setValue(dateFormatter.dateFromString(currentParsedCharactersData), forKey: Constants.Story.pubDate)
        }

        accumulatingParsedCharactersData = false
    }

    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if (accumulatingParsedCharactersData == true) {
            currentParsedCharactersData = currentParsedCharactersData + string
        }
    }

    // MARK: - Additional Helpers
    func addStoriesToList(stories: [NRStoryMO]) {
        do {
            try appDelegate.dataController.managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }

        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Story.notificationName, object: self, userInfo: nil)
    }

    // MARK: - Parser error handling
    func handleStoriesError(parseError: NSError) {
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Story.errorNotificationName, object: self, userInfo: [Constants.Story.messageErrorKey : parseError])
    }

    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        if (NSXMLParserError(rawValue: parseError.code) != NSXMLParserError.DelegateAbortedParseError && didAbortParsing == false) {
            performSelectorOnMainThread("handleStoriesError:", withObject: parseError, waitUntilDone: false)
        }
    }

}