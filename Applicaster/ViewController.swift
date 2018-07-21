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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tblVideos.delegate = self
        tblVideos.dataSource = self
        txtSearch.delegate = self
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
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140.0
    }
    
    
    // MARK: UITextFieldDelegate method implementation
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
}

