//
//  MiltonTabBarController.swift
//  SwiftMilton
//
//  Created by Tim Harris on 1/13/17.
//  Copyright © 2017 Tim Harris. All rights reserved.
//

import UIKit
import EmbeddedAgent

class MiltonTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        updateTabsFromConfiguration()
        //loadStaticTabs()
        
        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func loadStaticTabs() {
        var viewControllers:[UIViewController] = []
        var controller:MiltonFeedViewController = MiltonFeedViewController.init(_url:(URL.init(string: "http://www.app47.com/feed/"))!)
        var navController:UINavigationController = UINavigationController.init(rootViewController: controller)
        var image:UIImage = UIImage.init(named: "cellphone.png")!
        var tabBarItem:UITabBarItem = UITabBarItem.init(title: "App47", image: image, tag: 500)
        navController.tabBarItem = tabBarItem
        viewControllers.append(navController)
        
        controller = MiltonFeedViewController.init(_url:(URL.init(string: "http://rssfeeds.usatoday.com/usatoday-NewsTopStories"))!)
        navController = UINavigationController.init(rootViewController: controller)
        image = UIImage.init(named: "book.png")!
        tabBarItem = UITabBarItem.init(title: "USA Today", image: image, tag: 500)
        navController.tabBarItem = tabBarItem
        viewControllers.append(navController)
        
        self.setViewControllers(viewControllers as [UIViewController], animated: true)
    }
    
    
    // Update the displayed tabs from configuration. This is expecting at least three configuration groups defined below:
    //
    // Configuration group 1:
    // Name: "UI Configuration"
    // Description: The starting point of the UI configuration, today it only has one value, the tab listing name, but
    //              in the future it may contain other UI configuration parameters we may want to adjust.
    // Expected key/values
    // ____________________________________________________
    // |  Key          |            Value                 |
    // |--------------------------------------------------|
    // |  Tab listing  | Tabs                             |
    // |--------------------------------------------------|
    //
    // Configuration group 2:
    // Name: "Tabs"
    // Description: Actually the name of this group needs to match the value in the previous table for the
    //              "Tab listing" key. However in our example, it is "Tabs". This group has a list of tabs
    //              to display in milton along with their order. The order is the key value and the value is
    //              name of the correspoding group for the tab.
    // Expected key/values
    // ____________________________________________________
    // |  Key          |            Value                 |
    // |--------------------------------------------------|
    // |  Order        | Name of the group for the tab    |
    // |--------------------------------------------------|
    //
    // Example
    // ____________________________________________________
    // |  1            | App47                            |
    // |--------------------------------------------------|
    //
    // Configuration group 3:
    // Name: "App47"
    // Description: There needs to be one of these groups for each of tabs listed in the previous configuration group.
    // Expected key/values
    // ____________________________________________________
    // |  Key          |            Value                 |
    // |--------------------------------------------------|
    // |  title        | Title of the tab on the UI       |
    // |--------------------------------------------------|
    // |  image_name   | Filename for the tab image       |
    // |--------------------------------------------------|
    // |  url          | URL for the atomic RSS feed      |
    // |--------------------------------------------------|
    //
    // Example
    // ____________________________________________________
    // |  title        | App47                            |
    // |--------------------------------------------------|
    // |  image_name   | cellphone.png                    |
    // |--------------------------------------------------|
    // |  url          | http://www.app47.com/feed/       |
    // |--------------------------------------------------|
    // 
    @objc func updateTabsFromConfiguration() {
        
        // make sure we are on the main thread, if not get us there
        if (!Thread.isMainThread){
            DispatchQueue.main.async {
                self.updateTabsFromConfiguration()
            }
            return;
        }
        let tabGroupName:String? = EmbeddedAgent.configurationString(forKey:"Tab listing", group:"UI Configuration")
        var tabKeys:[String] = EmbeddedAgent.allKeys(forConfigurationGroup: tabGroupName) as! [String]
        tabKeys = tabKeys.sorted { (obj1, obj2) -> Bool in
            return obj1.caseInsensitiveCompare(obj2) == ComparisonResult.orderedAscending
        }
        
        // if we didnt't get any tabs then just load up the defaults
        if (tabKeys.count <= 0) {
            loadStaticTabs()
            return;
        }
        
        // we got  tabs back from the configuration so set them up
        var viewControllers:[UIViewController] = []
        for key in tabKeys {
            let tabGroupName:String = EmbeddedAgent.configurationString(forKey: key, group: tabGroupName)
            let tabTitle:String = EmbeddedAgent.configurationString(forKey: "title", group: tabGroupName)
            let imageName:String = EmbeddedAgent.configurationString(forKey: "image_name", group: tabGroupName)
            let urlString:String = EmbeddedAgent.configurationString(forKey: "url", group: tabGroupName)
            let url:URL = URL.init(string: urlString)!
            
            let controller:MiltonFeedViewController = MiltonFeedViewController.init(_url: url)
            let navController:UINavigationController = UINavigationController.init(rootViewController: controller)
            let image:UIImage = UIImage.init(named: imageName)!
            
            let tabBarItem:UITabBarItem = UITabBarItem.init(title: tabTitle, image: image, tag: 500)
            navController.tabBarItem = tabBarItem
            viewControllers.append(navController)
            
        }
        
        self.setViewControllers(viewControllers as [UIViewController], animated: true)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
