//
//  MiltonFeedViewController.swift
//  SwiftMilton
//
//  Created by Tim Harris on 1/13/17.
//  Copyright © 2017 Tim Harris. All rights reserved.
//

import UIKit
import MWFeedParser
import EmbeddedAgent


class MiltonFeedViewController: UITableViewController, MWFeedParserDelegate {
    
    var url:URL?
    var feedItems:NSMutableArray?
    var feedLoadEventID:String?
    

    convenience init(_url:URL) {
        self.init(style:UITableViewStyle.plain)
        url = _url
        feedItems = NSMutableArray()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var urlString:String
        urlString = (url?.absoluteString)!
        if (urlString == "http://rssfeeds.usatoday.com/usatoday-NewsTopStories") {
            // force a crash
            var foo:String?
            foo = nil
            foo!.capitalized
        }
        
        // otherwise, get a parser and start going at it
        let parser:MWFeedParser = MWFeedParser.init(feedURL: url)
        parser.delegate = self
        parser.parse()
        
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedItems!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            else {
                // Never fails:
                return UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
            }
            return cell
        }()

        let item:MWFeedItem = feedItems?.object(at: indexPath.row) as! MWFeedItem
        
        cell.textLabel?.text = item.title
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        
        cell.detailTextLabel?.text = formatter.string(from: item.date)

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Feed Parser
    
    func addFeedItem(item:MWFeedItem) {
        let path = IndexPath.init(row:(feedItems?.count)!, section:0)
        self.tableView.beginUpdates()
        feedItems?.add(item)
        self.tableView.insertRows(at: [path], with: UITableViewRowAnimation.fade)
        self.tableView.endUpdates()
    }
    
    func feedParserDidStart(_ parser: MWFeedParser!) {
        let eventName:String = String.localizedStringWithFormat("Load feed %@", (self.navigationController?.tabBarItem.title)!)
        EmbeddedAgent.logDebug(withMessage: (String.localizedStringWithFormat("Started parsing feed %@", eventName)), fileName: #file, lineNumber: #line)
        feedLoadEventID = EmbeddedAgent.startTimedEvent(eventName)
        
    }
    
    func feedParser(_ parser: MWFeedParser!, didParseFeedInfo info: MWFeedInfo!) {
        DispatchQueue.main.async {
            self.navigationItem.title = info.title
        }
    }
    
    func feedParser(_ parser: MWFeedParser!, didParseFeedItem item: MWFeedItem!) {
        NSLog("New Item - %@", item)
        DispatchQueue.main.async {
            self.addFeedItem(item: item)
        }
    }
    
    func feedParserDidFinish(_ parser: MWFeedParser!) {
        let eventName:String = String.localizedStringWithFormat("Load feed %@", (self.navigationController?.tabBarItem.title)!)
        EmbeddedAgent.logDebug(withMessage: (String.localizedStringWithFormat("Done parsing feed %@", eventName)), fileName: #file, lineNumber: #line)
        EmbeddedAgent.endTimedEvent(feedLoadEventID)
    }
    
    func feedParser(_ parser: MWFeedParser!, didFailWithError error: Error!) {
        let eventName:String = String.localizedStringWithFormat("Load feed %@", (self.navigationController?.tabBarItem.title)!)
        EmbeddedAgent.sendGenericEvent(eventName)
        
        EmbeddedAgent.logErrorWithError(error, message: (String.localizedStringWithFormat("Unable to parse feed %@", (self.url?.absoluteString)!)), fileName: #file, lineNumber: #line)
        
        // create an alert and show it on the main thread
        let view:UIAlertView = UIAlertView.init(title: "Unable to parse feed", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
        DispatchQueue.main.async {
            view.show()
        }
    }

}
