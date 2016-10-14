//
//  ViewController.swift
//  Tumblr
//
//  Created by Keith Smyth on 12/10/2016.
//  Copyright © 2016 Keith Smyth. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var blogTable: UITableView!
    var PhotoList: NSDictionary!
    var postNumber: Int = 0
    let refreshControl: UIRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.blogTable.rowHeight = 320.0
        self.refreshControl.addTarget(self, action: #selector(requestBlogList(_:)), for: UIControlEvents.valueChanged)
        self.blogTable.insertSubview(self.refreshControl, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestBlogList(self.refreshControl)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postNumber
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell") as! TableViewCell
        
        if let responseData = self.PhotoList["response"] as? NSDictionary {
            if let postData = responseData["posts"] as? NSArray {
                if let blogData = postData[indexPath.row] as? NSDictionary {
                    if let photosData = blogData["photos"] as? NSArray {
                        if let photoContent = photosData[0] as? NSDictionary {
                            if let originalImage = photoContent["original_size"] as? NSDictionary {
                                if let imgURL = originalImage["url"] as? String {
                                    cell.photoImageView.setImageWith(URL(string: imgURL)!)
                                    cell.blogNameLabel.text = blogData["blog_name"] as? String
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! PhotoDetailsViewController
        let indexPath = self.blogTable.indexPath(for: sender as! UITableViewCell)!
        
        if let responseData = self.PhotoList["response"] as? NSDictionary {
            if let postData = responseData["posts"] as? NSArray {
                if let blogData = postData[indexPath.row] as? NSDictionary {
                    if let photosData = blogData["photos"] as? NSArray {
                        if let photoContent = photosData[0] as? NSDictionary {
                            if let originalImage = photoContent["original_size"] as? NSDictionary {
                                if let imgURL = originalImage["url"] as? String {
                                    
                                    vc.photoUrl = imgURL
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    // helper functions
    func requestBlogList(_ refreshControl: UIRefreshControl) {
        let apiKey = "Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV"
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    //NSLog("response: \(responseDictionary)")
                    self.PhotoList = responseDictionary
                    if let responseData = responseDictionary["response"] as? NSDictionary {
                        if let postData = responseData["posts"] as? NSArray {
                            self.postNumber = postData.count
                        }
                    }
                    self.blogTable.reloadData()
                    refreshControl.endRefreshing()
                }
            }
        });
        task.resume()
    }

}

