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
    var videosArray: Array<Dictionary<String, AnyObject>> = []
    var videosDurationDict: Dictionary<String, String> = [:]
    var selectedVideoIndex: Int!
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "idSeguePlayer" {
            let playerViewController = segue.destination as! PlayerViewController
            playerViewController.videoID = videosArray[selectedVideoIndex]["videoID"] as! String
        }
    }
    
    // MARK: IBAction method implementation
    
    @IBAction func changeContent(sender: AnyObject) {
        tblVideos.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.fade)
    }
    
    // MARK: UITableView method implementation
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segDisplayedContent.selectedSegmentIndex == 0 {
            return channelsDataArray.count
        }
        else {
            return videosArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()
        if segDisplayedContent.selectedSegmentIndex == 0 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "idCellChannel", for: indexPath)
            
            let channelTitleLabel = cell.viewWithTag(10) as! UILabel
            let channelDescriptionLabel = cell.viewWithTag(11) as! UILabel
            let thumbnailImageView = cell.viewWithTag(12) as! UIImageView
            
            let channelDetails = channelsDataArray[indexPath.row]
            channelTitleLabel.text = channelDetails["title"] as? String
            channelDescriptionLabel.text = channelDetails["description"] as? String
            thumbnailImageView.image = UIImage(data: ((NSData(contentsOf: URL(string: (channelDetails["thumbnail"] as? String)!)!)) as Data?)!)
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "idCellVideo", for: indexPath)
            
            let videoTitle = cell.viewWithTag(10) as! UILabel
            let videoThumbnail = cell.viewWithTag(11) as! UIImageView
            
            let videoDetails = videosArray[indexPath.row]
            videoTitle.text = videoDetails["title"] as? String
            videoThumbnail.image = UIImage(data: ((NSData(contentsOf: URL(string: (videoDetails["thumbnail"] as? String)!)!)) as Data?)!)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segDisplayedContent.selectedSegmentIndex == 0 {
            // In this case the channels are the displayed content.
            // The videos of the selected channel should be fetched and displayed.
            
            // Switch the segmented control to "Videos".
            segDisplayedContent.selectedSegmentIndex = 1
            
            // Show the activity indicator.
            viewWait.isHidden = false
            
            // Remove all existing video details from the videosArray array.
            videosArray.removeAll(keepingCapacity: false)
            
            // Fetch the video details for the tapped channel.
            getVideosForChannelAt(index: indexPath.row)
        }
        else {
            selectedVideoIndex = indexPath.row
            performSegue(withIdentifier: "idSeguePlayer", sender: self)
        }
    }
    
    
    // MARK: UITextFieldDelegate method implementation
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        viewWait.isHidden = false
        
        var type = "channel"
        if segDisplayedContent.selectedSegmentIndex == 1 {
            type = "video"
            videosArray.removeAll(keepingCapacity: false)
        }
        
        //Format url target
        var urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=10&order=rating&q=\(String(describing: textField.text))&type=\(type)&key=\(apiKey)"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let targetURL = URL(string: urlString)
        
        doGetRequest(targetURL: targetURL) { (data, HTTPStatusCode, error) in
            //Parse Data, cast data to dictionary
            do {
                let dictionary = try JSONSerialization.jsonObject(with: data!, options: [])
                    as! Dictionary<String, AnyObject>
                let itemsArray: Array<Dictionary<String, AnyObject>> = dictionary["items"] as! Array<Dictionary<String, AnyObject>>
                
                for item in itemsArray {
                    let snippetDict = item["snippet"] as! Dictionary<String, AnyObject>
                    
                    if self.segDisplayedContent.selectedSegmentIndex == 0 {
                        //it's channel
                        self.desiredChannelsArray.append(snippetDict["channelId"] as! String)
                    } else {
                        //it's video
                        var videoDetailsDict = Dictionary<String, AnyObject>()
                        videoDetailsDict["title"] = snippetDict["title"]
                        videoDetailsDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
                        videoDetailsDict["videoID"] = (item["id"] as! Dictionary<String, AnyObject>)["videoId"]
                        
                        self.videosArray.append(videoDetailsDict)
                        self.tblVideos.reloadData()
                    }
                }//for
                
                if self.segDisplayedContent.selectedSegmentIndex == 0 {
                    self.getChannelDetails(useChannelIDParam: true)
                }
                
                self.viewWait.isHidden = true
                
            }//do
                
            catch{
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel details: \(error)")
                return
            }//catch
        }//doGetRequest
        
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
            urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&id=\(desiredChannelsArray[channelIndex])&key=\(apiKey)"
        }
        
        let targetURL = URL(string: urlString)
        
        
        doGetRequest(targetURL: targetURL) { (data, HTTPStatusCode, error) in
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
            }//do
            
            catch{
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel details: \(error)")
                return
            }//catch
        }//doGetRequest
    }//getChannelDetails
    
    
    func getVideosForChannelAt(index: Int!) {
        // Get the selected channel's playlistID value from the channelsDataArray array and use it for fetching the proper video playlst.
        let playlistID = channelsDataArray[index]["playlistID"] as! String
        let urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=10&playlistId=\(playlistID)&key=\(apiKey)"
        let targetURL = URL(string: urlString)
        
        doGetRequest(targetURL: targetURL) { (data, HTTPStatusCode, error) in
            //Parse Data, cast data to dictionary
            do {
                let dictionary = try JSONSerialization.jsonObject(with: data!, options: [])
                    as! Dictionary<String, AnyObject>
                let itemsArray: Array<Dictionary<String, AnyObject>> = dictionary["items"] as! Array<Dictionary<String, AnyObject>>
                
                for item in itemsArray {
                    let playlistSnippetDict = (item as Dictionary<String, AnyObject>)["snippet"] as! Dictionary<String, AnyObject>
                    
                    var desiredPlaylistItemDataDict = Dictionary<String, AnyObject>()
                    desiredPlaylistItemDataDict["title"] = playlistSnippetDict["title"]
                    desiredPlaylistItemDataDict["thumbnail"] = ((playlistSnippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
                    desiredPlaylistItemDataDict["publishedDate"] = playlistSnippetDict["publishedAt"]
                    desiredPlaylistItemDataDict["playlistTitle"] = playlistSnippetDict["channelTitle"]
                    desiredPlaylistItemDataDict["videoID"] = (playlistSnippetDict["resourceId"] as! Dictionary<String, AnyObject>)["videoId"]
                    
                    self.videosArray.append(desiredPlaylistItemDataDict)
                    self.tblVideos.reloadData()
                }//for
                self.getDurationOf(videosArray: self.videosArray)
                
                self.viewWait.isHidden = true
                
            }//do
                
            catch{
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel details: \(error)")
                return
            }//catch
        }//doGetRequest
    }//getVideosForChannelAt
    
    func getDurationOf(videosArray: Array<Dictionary<String, AnyObject>>) {
        //Order videoIDs into string separated by commas
        var videoIDsString = ""
        
        for video  in videosArray {
            videoIDsString += "\(String(describing: video["videoID"])),"
        }
        
        let urlString = "https://www.googleapis.com/youtube/v3/videos?part=contentDetails&maxResults=10&id=\(videoIDsString)&key=\(apiKey)"
        let targetURL = URL(string: urlString)
        
        doGetRequest(targetURL: targetURL) { (data, HTTPStatusCode, error) in
            //Parse Data, cast data to dictionary
            do {
                let dictionary = try JSONSerialization.jsonObject(with: data!, options: [])
                    as! Dictionary<String, AnyObject>
                let itemsArray: Array<Dictionary<String, AnyObject>> = dictionary["items"] as! Array<Dictionary<String, AnyObject>>
                
                for item in itemsArray {
                    
                    let videoContentDetailDict = (item as Dictionary<String, AnyObject>)["contentDetails"] as! Dictionary<String, AnyObject>
                    var duration = videoContentDetailDict["duration"] as! String
                    duration = self.getYoutubeFormattedDurationFrom(duration)
                    
                    self.videosDurationDict[item["id"] as! String] = duration
                }//for
            }//do
                
            catch{
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel details: \(error)")
                return
            }//catch
        }//doGetRequest
    }//getDurationOf
    
    
    func getYoutubeFormattedDurationFrom(_ string: String) -> String {
        
        let formattedDuration = string.replacingOccurrences(of: "PT", with: "").replacingOccurrences(of: "H", with:":").replacingOccurrences(of: "M", with: ":").replacingOccurrences(of: "S", with: "")
        
        let components = formattedDuration.components(separatedBy: ":")
        var duration = ""
        for component in components {
            duration = duration.count > 0 ? duration + ":" : duration
            if component.count < 2 {
                duration += "0" + component
                continue
            }
            duration += component
        }
        return duration
    }//getYoutubeFormattedDurationFrom
}

