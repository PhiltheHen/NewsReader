//
//  NRStoryDetailViewController.swift
//  NewsReader
//
//  Created by Philip Henson on 12/11/15.
//  Copyright © 2015 Phil Henson. All rights reserved.
//

import UIKit

class NRStoryDetailViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var noNetworkView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    weak var story: NRStoryMO?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        noNetworkView.hidden = true
        if story != nil {
            if story!.link != nil {
                loadURL(story!.link!)
            } else {
                print("no link found with story")
            }
        } else {
            print("no story found")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Additional Helpers
    func loadURL(urlString: String) {
        webView.loadRequest(NSURLRequest(URL: NSURL(string: urlString)!))
    }

    // MARK: - Web View Delegate Methods

    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicator.startAnimating()
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.stopAnimating()
    }

    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        noNetworkView.hidden = false
        let alert = UIAlertController(title: "Page Load Error", message: error?.localizedDescription, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: -  IBActions
    @IBAction func onShareButtonPressed(sender: UIBarButtonItem) {
        let shareText = "I thought you would like this article!"
        let activityViewController = UIActivityViewController(activityItems: [shareText, story!.link!], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
