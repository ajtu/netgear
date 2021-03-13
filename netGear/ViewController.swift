//
//  ViewController.swift
//  netGear
//
//  Created by Alvin Tu on 3/12/21.
//

import UIKit
import Alamofire

class ViewController: UIViewController,UIScrollViewDelegate {
    //MARK: PROPERTIES

    let scrollView = UIScrollView()
    var frame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var pageControl : UIPageControl = UIPageControl(frame:CGRect(x: 0, y: 0, width: 200, height: 50))
    var nextButton = UIButton()
    var backButton = UIButton()

    var imageGroups = [ImageGroup]()
    var currentImageGroup : ImageGroup?
    var currentIndex = 0
    //MARK: VIEW SETUP
    override func viewDidLoad() {
        super.viewDidLoad()
        getManifest()
        scrollViewSetup()
        addButtonsAndGestures()
    }
    
    private func scrollViewSetup() {
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame =  CGRect(x: 0, y: view.frame.height/3, width: view.frame.width, height: self.view.frame.height * 0.45)

        pageControl.center = CGPoint(x: scrollView.center.x, y: scrollView.frame.maxY + 10)
        self.view.addSubview(scrollView)
        
        nextButton.setTitle("Next", for: .normal)
        nextButton.backgroundColor = .systemYellow
        nextButton.layer.cornerRadius = 8.8

        backButton.setTitle("back", for: .normal)
        backButton.backgroundColor = .blue
        backButton.layer.cornerRadius = 8.8
        
        self.view.addSubview(nextButton)
        self.view.addSubview(backButton)
        
    }
    
    func configureViews(for imageGroupIdentifiersCount: Int) {
        addNumberOfSubviewsForPage(for: imageGroupIdentifiersCount)
        configurePageControl(for: imageGroupIdentifiersCount)
    }
    
    private func addNumberOfSubviewsForPage(for imageGroupCount: Int) {
        
        scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width * CGFloat(imageGroupCount), height: scrollView.frame.size.height)
        
        for index in 0..<imageGroupCount {
            frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
            frame.size = self.scrollView.frame.size
            
            let imageView = UIImageView(frame:CGRect(x: frame.origin.x  , y: frame.origin.y, width: frame.width, height: frame.width * 0.5625) )
            let imageNameLabel = UILabel(frame:CGRect(x: frame.origin.x  , y: imageView.frame.maxY, width: frame.width, height: 60))
            
            getImageData(for: (currentImageGroup?.imageIdentifiers[index])!) { image, imageName in
                imageNameLabel.text = imageName
                imageNameLabel.backgroundColor = .white
                imageNameLabel.textAlignment = .center
                imageView.image = image
                imageView.contentMode = .scaleToFill
            }
            self.scrollView.addSubview(imageView)
            self.scrollView.addSubview(imageNameLabel)

        }
    }
    
    private func configurePageControl(for imageGroupCount: Int) {
        pageControl.currentPage = 0
        pageControl.numberOfPages = imageGroupCount
        pageControl.tintColor = UIColor.gray
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.currentPageIndicatorTintColor = UIColor.systemYellow
        view.addSubview(pageControl)
        
    }
    
    //MARK: ACTIONS AND ANIMATIONS
    
    @objc func backButtonPressed(_ sender: UIButton) {
        guard currentIndex  != 0 && imageGroups.count != 0  else {
            addPulse(plainView: backButton)
            return }
        
        currentIndex -= 1
        currentImageGroup = imageGroups[currentIndex]
        configureViews(for: (currentImageGroup?.imageIdentifiers.count)!)
    }
    
    @objc func nextButtonPressed(_ sender: UIButton) {
        guard currentIndex < imageGroups.count - 1 else {
            addPulse(plainView: nextButton)
            return }
        
        currentIndex += 1
        currentImageGroup = imageGroups[currentIndex]
        configureViews(for: (currentImageGroup?.imageIdentifiers.count)!)
    }
    
    @objc func swipePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x,y :0), animated: true)
    }
    
    func addButtonsAndGestures() {
        nextButton = UIButton(frame:CGRect(x: view.frame.midX - 50, y: view.frame.height - 100, width: 100, height: 50))
        backButton = UIButton(frame:CGRect(x: 10, y: 40, width: 50, height: 50))

        pageControl.addTarget(self, action: #selector(self.swipePage(sender:)), for: UIControl.Event.valueChanged)
        nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        backButton.addTarget(self,action: #selector(backButtonPressed), for: .touchUpInside)

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
        
    func addPulse(plainView: UIView) {
            let pulse = Pulsing(numberOfPulses: 1, radius: 110, position: plainView.center)
            pulse.animationDuration = 0.8
            pulse.backgroundColor = UIColor.blue.cgColor
            self.view.layer.insertSublayer(pulse, below: plainView.layer)
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
 
}

//MARK: NETWORKING - can move to networking manager
extension ViewController {
    func getManifest() {
        let apiKey = "33626b03-88b8-4c6e-af34-ac4e6f7faa7c"
        let headers: HTTPHeaders = [
            "X-API-KEY" : "\(apiKey)"]
        AF.request("https://afternoon-bayou-28316.herokuapp.com/manifest", headers: headers)
            .responseDecodable(of:Manifest.self) {  [self] response in
                if let manifest = response.value{
                    if let imageGroups = manifest.structure{
                        for imageGroup in imageGroups {
                            let model =  ImageGroup(imageIdentifiers: imageGroup)
        
                            self.imageGroups.append(model)
                        }
                        currentImageGroup = self.imageGroups[currentIndex]
                        configureViews(for: (currentImageGroup?.imageIdentifiers.count)!)
                        return
                    }
                }
    
            }
            .responseDecodable(of:ImageError.self) { [self] response in
                if let error = response.value {
                    let alert = UIAlertController(title: "We're sorry.", message: error.error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                }))
                self.present(alert, animated: true, completion: nil)
                }
            }
    }
    
    
    func getImageData(for identifier: String, completion: @escaping (UIImage, String) -> Void) {
        let apiKey = "33626b03-88b8-4c6e-af34-ac4e6f7faa7c"
        let headers: HTTPHeaders = [
            "X-API-KEY" : "\(apiKey)"]
        AF.request("https://afternoon-bayou-28316.herokuapp.com/image/\(identifier)", headers: headers)
            .responseDecodable(of:Image.self) { response in
                if let imageData = response.value{
                    let imageName = imageData.name
                    AF.request(imageData.url, headers: headers)
                        .responseData { response in
                            if let dataValue = response.value {
                                if let image = UIImage(data: dataValue){

                                    completion(image, imageName)
                                }
                            }
                        }
                }
            }
            .responseDecodable(of:ImageError.self) { [self] response in
                if let error = response.value {
                    let alert = UIAlertController(title: "We're sorry. Could not fetch Images", message: error.error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                }))
                self.present(alert, animated: true, completion: nil)
                }
            }
    }
}




