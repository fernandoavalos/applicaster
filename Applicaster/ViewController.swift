//
//  ViewController.swift
//  Applicaster
//
//  Created by Fernando Avalos on 7/19/18.
//  Copyright © 2018 Fernando Avalos. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var tblVideos: UITableView!
    @IBOutlet weak var viewWait: UIView!
    @IBOutlet weak var segDisplayedContent: UISegmentedControl!
    @IBOutlet weak var txtSearch: UITextField!
    
    var apiKey = "AIzaSyDwqLGuJfQuBkcGvOuLubofMpRZNIyu_Ng"
    
    var desiredChannelsArray = ["Apple", "Google", "Microsoft"]
    
    var channelIndex = 0
    
    var channelsDataArray: Array<Dictionary<String, AnyObject>> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tblVideos.delegate = self
        tblVideos.dataSource = self
        txtSearch.delegate = self
        
        getChannelDetails(useChannelIDParam: false)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBAction method implementation
    
    @IBAction func changeContent(sender: AnyObject) {
        
    }
    
    // MARK: UITableView method implementation
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segDisplayedContent.selectedSegmentIndex == 0 {
            return channelsDataArray.count
        }
        else {
            
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()
        if segDisplayedContent.selectedSegmentIndex == 0 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "idCellChannel", for: indexPath) as! UITableViewCell
            
            let channelTitleLabel = cell.viewWithTag(10) as! UILabel
            let channelDescriptionLabel = cell.viewWithTag(11) as! UILabel
            let thumbnailImageView = cell.viewWithTag(12) as! UIImageView
            
            let channelDetails = channelsDataArray[indexPath.row]
            channelTitleLabel.text = channelDetails["title"] as? String
            channelDescriptionLabel.text = channelDetails["description"] as? String
            thumbnailImageView.image = UIImage(data: ((NSData(contentsOf: URL(string: (channelDetails["thumbnail"] as? String)!)!)) as Data?)!)
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "idCellVideo", for: indexPath) as! UITableViewCell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140.0
    }
    
    
    // MARK: UITextFieldDelegate method implementation
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    
    // MARK: HTTP Requests implementation
    
    func doGetRequest(targetURL: URL!, completion: @escaping (_ data: Data?, _ HTTPStatusCode: Int, _ error: Error?)-> ()) {
        let request = URLRequest(url: targetURL)
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data!, response: URLResponse!, error: Error!) -> Void in
            DispatchQueue.main.async {
                completion(data, (response as! HTTPURLResponse).statusCode, error)
            }
        })
        
        task.resume()
    }
    
    func getChannelDetails(useChannelIDParam: Bool) {
        var urlString: String!
        if !useChannelIDParam {
            urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&forUsername=\(desiredChannelsArray[channelIndex])&key=\(apiKey)"
        }
        else {
            urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&id=SOME_ID_VALUE&key=\(apiKey)"
        }
        
        let targetURL = URL(string: urlString)
        
        
        doGetRequest(targetURL: targetURL) { (data, HTTPStatusCode, error) in
            if HTTPStatusCode == 200 && error == nil {
                //Parse Data, cast data to dictionary
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data!, options: [])
                        as! Dictionary<String, AnyObject>
                    let itemsArray: Array<Dictionary<String, AnyObject>> = dictionary["items"] as! Array<Dictionary<String, AnyObject>>
                    let firstItemDict = itemsArray[0]
                    
                    let snippetDict = firstItemDict["snippet"] as! Dictionary<String, AnyObject>
                    
                    var desiredValuesDict: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
                    desiredValuesDict["title"] = snippetDict["title"]
                    desiredValuesDict["description"] = snippetDict["description"]
                    desiredValuesDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
                    desiredValuesDict["playlistID"] = ((firstItemDict["contentDetails"] as! Dictionary<String, AnyObject>)["relatedPlaylists"] as! Dictionary<String, AnyObject>)["uploads"]
                    
                    self.channelsDataArray.append(desiredValuesDict)
                    
                    self.tblVideos.reloadData()
                    
                    //check if ther's another channel to load
                    self.channelIndex = self.channelIndex + 1
                    if self.channelIndex < self.desiredChannelsArray.count {
                        self.getChannelDetails(useChannelIDParam: useChannelIDParam)
                    }
                    else {
                        self.viewWait.isHidden = true
                    }
                }
                
                catch{
                    print("error trying to convert data to JSON")
                    print("HTTP Status Code = \(HTTPStatusCode)")
                    print("Error while loading channel details: \(error)")
                    return
                }
                
                
            }
        }
    }
}

