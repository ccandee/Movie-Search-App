//
//  FirstViewController.swift
//  lab4
//
//  Created by 王力冉 on 17/2/22.
//  Copyright © 2017年 王力冉. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var searchMovie: UISearchBar!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    var movieData : [Info] = []
    var theImageCache: [UIImage] = []
    var boxView = UIView()
    
    
    func addSavingPhotoView() {
        boxView = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25, width: 180, height: 50))
        boxView.backgroundColor = UIColor.gray
        boxView.alpha = 0.8
        boxView.layer.cornerRadius = 20
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityView.startAnimating()
        
        let textLabel = UILabel(frame: CGRect(x: 60, y: 0, width: 200, height: 50))
        textLabel.textColor = UIColor.red
        textLabel.text = "Loading data"
        
        boxView.addSubview(activityView)
        boxView.addSubview(textLabel)
        
        view.addSubview(boxView)
    }

    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("searched")
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let originalString = searchMovie.text
        let escapedString = originalString?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        let url1 = "http://www.omdbapi.com/?s=\(escapedString!)&page=1"
        let url2 = "http://www.omdbapi.com/?s=\(escapedString!)&page=2"

        movieData = []
        theImageCache = []
        self.addSavingPhotoView()
        DispatchQueue.global(qos: .userInitiated).async {
//            self.addSavingPhotoView()
            self.fetchData(url1)
            self.fetchData(url2)
            self.cacheImages()
            self.boxView.removeFromSuperview()

            DispatchQueue.main.async {
                self.mainCollectionView.reloadData()
            }
            
        }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath)
        cell.backgroundColor = UIColor.yellow
        let poster : UIImageView = UIImageView(image: theImageCache[indexPath.row])
        poster.frame = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height)
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height-100))
        poster.addSubview(title)
        cell.addSubview(poster)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detailedViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailedVC")
        
        let detailUrl = "http://www.omdbapi.com/?i=\(movieData[indexPath.row].id)"
        let detailJson = getJSON(detailUrl)

        let poster : UIImageView = UIImageView(image: theImageCache[indexPath.row])
        poster.frame = CGRect(x: 0, y: 0, width: view.frame.size.width/2, height: view.frame.size.height/2)
        poster.center.x = detailedViewController.view.center.x
        poster.center.y = detailedViewController.view.center.y-100
        detailedViewController.view.addSubview(poster)
        
        let labelFrame = CGRect(x: 0, y: 0, width: 300, height: 21)
        let yearLabel = UILabel(frame: labelFrame)
        yearLabel.center = CGPoint(x: 200, y: 495)
        yearLabel.textAlignment = .center
        yearLabel.text = "Released: " + detailJson["Released"].stringValue
        detailedViewController.view.addSubview(yearLabel)
        
        let rateLabel = UILabel(frame: labelFrame)
        rateLabel.center = CGPoint(x: 200, y: 535)
        rateLabel.textAlignment = .center
        rateLabel.text = "Imdb rating: " + detailJson["imdbRating"].stringValue
        detailedViewController.view.addSubview(rateLabel)
        
        let genreLabel = UILabel(frame: labelFrame)
        genreLabel.center = CGPoint(x: 200, y: 575)
        genreLabel.textAlignment = .center
        genreLabel.text = "Genre: " + detailJson["Genre"].stringValue
        detailedViewController.view.addSubview(genreLabel)
        
        let saveButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 21))
        
        
        saveButton.backgroundColor = UIColor.blue
        saveButton.center = CGPoint(x: 200, y: 615)
        saveButton.setTitle("Save movie", for: .normal)
//        saveButton.tag = 
        saveButton.accessibilityIdentifier = detailJson["Title"].stringValue

        saveButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        saveButton.layer.cornerRadius = 10
        saveButton.layer.borderColor = UIColor.blue.cgColor
        detailedViewController.view.addSubview(saveButton)
        

        
        detailedViewController.title = detailJson["Title"].stringValue
        navigationController?.pushViewController(detailedViewController, animated: true)

    }
    func buttonClicked(_sender: UIButton){
//        let alertViewController = UIAlertController(title: "Movie saved", message: "a", preferredStyle: UIAlertControllerStyle.alert)
        let alertView = UIAlertView()
        alertView.addButton(withTitle: "Ok")
        alertView.title = "Movie saved"
//        alertViewController.show()
        
        let s = _sender.accessibilityIdentifier!
        
        let defaults = UserDefaults.standard
        var movieArray = defaults.stringArray(forKey: "SavedMovie") ?? [String]()
        if movieArray == nil{
            movieArray = [s]
        }else{
            if movieArray.contains(s){
                alertView.title = "Movie already saved";
            }else{
            movieArray.append(s)
            }
        }
        alertView.show()
        defaults.set(movieArray, forKey: "SavedMovie")

        
//        prefs.removeObject(forKey: s)
//        keyValue = prefs.string(forKey: s)
//        print("Key Value after remove \(keyValue)")
        
        
        
//        self.presentViewController(alertViewController, animated: true, completion: nil)
        
    }
    
    private func fetchData(_ url: String) {
        
        let json = getJSON(url)
        for result in json["Search"].arrayValue {
            let title = result["Title"].stringValue
            let rate = result["imdbRating"].floatValue
            let year = result["Year"].intValue
            let id = result["imdbID"].stringValue
            let url = result["Poster"].stringValue
            movieData.append(Info(title: title, rate: rate, year: year, id: id, url: url))
        }
    }
    
    private func getJSON(_ url: String) -> JSON {
        
        if let url = URL(string: url){
            if let data = try? Data(contentsOf: url) {
                let json = JSON(data: data)
                return json
            } else {
                return JSON.null
            }
        } else {
            return JSON.null
        }
        
    }
    
    private func cacheImages() {
        
        for item in movieData {
            let url = URL(string: item.url)
            let data = try? Data(contentsOf: url!)
            if (data == nil){
                let image = UIImage?(#imageLiteral(resourceName: "no-image-found.jpg"))
                theImageCache.append(image!)
            }
            else{
                let image = UIImage(data: data!)
                theImageCache.append(image!)
            }
        }
        
    }

    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let savedMovie : [String] = ["my movie"]
//        let defaults = UserDefaults.standard
//        defaults.set(savedMovie, forKey: "SavedMovie")

        
        
        // Do any additional setup after loading the view, typically from a nib.
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenWidth / 3.8, height: screenHeight / 5)
//        layout.minimumInteritemSpacing = 20


        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        mainCollectionView.collectionViewLayout = layout
        searchMovie.delegate = self
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.addSavingPhotoView()
            self.fetchData("http://www.omdbapi.com/?s=day&page=1")
            self.fetchData("http://www.omdbapi.com/?s=day&page=2")
            self.cacheImages()
            self.boxView.removeFromSuperview()

            DispatchQueue.main.async {
                self.mainCollectionView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

