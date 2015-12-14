//
//  NRStoriesTableViewController.swift
//  NewsReader
//
//  Created by Philip Henson on 12/11/15.
//  Copyright © 2015 Phil Henson. All rights reserved.
//

import UIKit
import CoreData

class NRStoriesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var headerImage: UIImageView!
    var headerView: UIView!

    @IBOutlet weak var refreshLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var fetchedResultsController: NSFetchedResultsController!
    var parseOperation: NRParseOperation?
    var dateLabelFormatter = NSDateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add observers for Parse Operation
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addStories:", name: Constants.Story.notificationName, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "storiesError:", name: Constants.Story.errorNotificationName, object: nil)

        // Setup date formatter
        dateLabelFormatter.dateFormat = "MMM dd yyyy"

        // Setup refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.tintColor = UIColor.clearColor()
        refreshControl.backgroundColor = UIColor.clearColor()
        self.refreshControl = refreshControl
        tableView.addSubview(refreshControl)

        setupHeaderView()

    }

    func refresh(sender: AnyObject) {
        print("refresh")
        performParseOperationWithURL(NSURL(string: Constants.feedURLString)!)
        self.refreshControl?.endRefreshing()
    }

    func performParseOperationWithURL(url: NSURL) {
        if NRReachability.isConnectedToNetwork() == true {
            parseOperation = NRParseOperation()
            parseOperation!.parseDataWithURL(NSURL(string: Constants.feedURLString)!)
        } else {
            let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }

    }

    override func viewWillAppear(animated: Bool) {
        initializeFetchedResultsController()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.Story.notificationName, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.Story.errorNotificationName, object: nil)
    }

    func addStories(notif: NSNotification) {

        // Clear cache when we repopulate with new news stories
         // NSFetchedResultsController.deleteCacheWithName("rootCache")

        assert(NSThread.isMainThread())
        if self.fetchedResultsController != nil {
                do {
                    try self.fetchedResultsController.performFetch()
                } catch {
                    fatalError("Failed to initialize FetchedResultsController: \(error)")
                }
            }else {
                self.initializeFetchedResultsController()
            }
    }

    func storieserror(notif: NSNotification) {
        assert(NSThread.isMainThread())
        handleError(notif.userInfo![Constants.Story.messageErrorKey] as! NSError)
    }

    func handleError(error: NSError) {
        let alert = UIAlertController(title: "Error", message: "Unable to download news.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (self.fetchedResultsController != nil) {
            return self.fetchedResultsController.sections!.count
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.fetchedResultsController != nil) {
            let sections = self.fetchedResultsController.sections
            let sectionInfo = sections![section]
            return sectionInfo.numberOfObjects
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NRStoryTableViewCell

        // Configure the cell...
        self.configureCell(cell, indexPath: indexPath)

        return cell
    }

    func configureCell(cell: NRStoryTableViewCell, indexPath: NSIndexPath) {
        let story = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NRStoryMO
        cell.titleLabel.text = story.title
        cell.descriptionLabel.text = story.textDescription
        cell.dateLabel.text = dateLabelFormatter.stringFromDate(story.pubDate!)
    }

    // MARK: - Fetched Results Controller Methods
    func initializeFetchedResultsController() {

        let request = NSFetchRequest(entityName: Constants.storyEntity)
        let pubDateSort = NSSortDescriptor(key: Constants.Story.pubDate, ascending: false)
        request.sortDescriptors = [pubDateSort]

        let appDelegate = UIApplication.sharedApplication().delegate as! NRAppDelegate
        let moc = appDelegate.dataController.managedObjectContext
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: "rootCache")
        self.fetchedResultsController.delegate = self
        do {
            // Fetch results from cache
            try self.fetchedResultsController.performFetch()

            // If cache is empty, perform parse operation
            if (self.fetchedResultsController.fetchedObjects?.count == 0) {
               performParseOperationWithURL(NSURL(string: Constants.feedURLString)!)
            }

        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Move:
            break
        case .Update:
            break
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(self.tableView.cellForRowAtIndexPath(indexPath!) as! NRStoryTableViewCell, indexPath: indexPath!)
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            self.tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }

    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    // MARK: - Header View Methods

    func setupHeaderView() {
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        tableView.contentInset = UIEdgeInsets(top: Constants.headerHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -Constants.headerHeight)
        updateHeaderView()
    }

    func updateHeaderView() {
        var headerRect = CGRect(x: 0, y: -Constants.headerHeight, width: tableView.bounds.width, height: Constants.headerHeight)
        if tableView.contentOffset.y < -Constants.headerHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
            if (-tableView.contentOffset.y > Constants.headerHeight*1.5){
                activityIndicator.startAnimating()
                refreshLabel.hidden = false
            }
        } else {
            activityIndicator.stopAnimating()
            refreshLabel.hidden = true
        }
        headerView.frame = headerRect
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        updateHeaderView()
    }

    // MARK: - Navigation
    let CellDetailIdentifier = "ToCellDetailSegue"

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case CellDetailIdentifier:
            let destination = segue.destinationViewController as! NRStoryDetailViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            let selectedObject = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NRStoryMO
            destination.story = selectedObject
        default:
            print("Unknown segue: \(segue.identifier)")
        }
    }

}
