//
//  SecondViewController.swift
//  lab4
//
//  Created by 王力冉 on 17/2/22.
//  Copyright © 2017年 王力冉. All rights reserved.
//

import UIKit
import WebKit


class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var theTableView: UITableView!
    var movieArray : [String] = []
    var webView: WKWebView!


    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        myCell.textLabel?.text = movieArray[indexPath.row]
        return myCell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            movieArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            UserDefaults.standard.set(movieArray, forKey: "SavedMovie")
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = tableView.cellForRow(at: indexPath)?.textLabel?.text
        print(title!)
        let escapedTitle = title?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)

//        view = webView
        
        
        let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailedVC")
        let webView = WKWebView(frame: webViewController.view.bounds)
        webView.navigationDelegate = webViewController.navigationController as! WKNavigationDelegate?
        let url = URL(string: "http://www.imdb.com/find?ref_=nv_sr_fn&q=\(escapedTitle!)&s=all" )
        webView.load(URLRequest(url: url!))
        webView.allowsBackForwardNavigationGestures = true
        
        webViewController.view = webView

        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        let defaults = UserDefaults.standard
        movieArray = defaults.stringArray(forKey: "SavedMovie") ?? [String]()
        self.theTableView.reloadData()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theTableView.delegate = self
        theTableView.dataSource = self
        let defaults = UserDefaults.standard
        movieArray = defaults.stringArray(forKey: "SavedMovie") ?? [String]()

        DispatchQueue.global(qos: .userInitiated).async {
            
            let defaults = UserDefaults.standard
            self.movieArray = defaults.stringArray(forKey: "SavedMovie") ?? [String]()

            DispatchQueue.main.async {
                self.theTableView.reloadData()
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
  
    }


}

