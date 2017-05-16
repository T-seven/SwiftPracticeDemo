//
//  TMYImgTableViewController.swift
//  TMYSegmentController
//
//  Created by TMY on 2017/5/15.
//  Copyright © 2017年 TMY. All rights reserved.
//

import UIKit
import AVFoundation

class TMYImgTableViewController: UITableViewController {

    var imgArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        
        title = "图片展示"
        tableView.register(TMYImgCell.self, forCellReuseIdentifier: "imgCellIdentifier")
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UIScreen.main.bounds.size.height/3
        
        let rightBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(slipImgsBtnClick))
        navigationItem.rightBarButtonItem = rightBtn
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imgArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.size.height/3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imgCellIdentifier", for: indexPath) as!  TMYImgCell
        cell.imgView.image = imgArray[indexPath.row]

        return cell
    }
    
    func slipImgsBtnClick() {
        imgArray.removeAll()
        
        //电脑桌面的一份mp4文件，时长3分20秒。。。path看情况自己定。。。。
        let tmpFileUrl = URL(fileURLWithPath: "/Users/tmy/Downloads/好好(你的名字).mp4")
        
        //调用视频分解func
        self.splitVideoFileUrlFps(splitFileUrl: tmpFileUrl, fps: 1, splitCompleteClosure: { [weak self](isSuccess, splitImgs) in
            
            if isSuccess {
                self?.imgArray = splitImgs as! [UIImage]
                
                //UI回主线程刷新
                DispatchQueue.main.async {[weak self] in
                    self?.tableView.reloadData()
                }
                print("图片总数目imgcount:\(String(describing: self?.imgArray.count))")
            }
        })
    }
}

class TMYImgCell: UITableViewCell {
    
    let imgView = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
         imgView.frame = CGRect(x: 10, y: 0, width: UIScreen.main.bounds.size.width - 20, height: UIScreen.main.bounds.size.height/3)
        imgView.contentMode = .scaleAspectFit
        addSubview(imgView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TMYImgTableViewController {
    
    /// 视频分解成帧
    /// - parameter fileUrl                 : 视频地址
    /// - parameter fps                     : 自定义帧数 每秒内取的帧数
    /// - parameter splitCompleteClosure    : 回调
    func splitVideoFileUrlFps(splitFileUrl:URL, fps:Float, splitCompleteClosure:@escaping completeClosure) {
        
        // TODO: 判断fileUrl是否为空
        print("QQQQQQQQQQ ==> split: \(splitFileUrl)")
        
        var splitImages = [UIImage]()
        let optDict = NSDictionary(object: NSNumber(value: false), forKey: AVURLAssetPreferPreciseDurationAndTimingKey as NSCopying)
        let urlAsset = AVURLAsset(url: splitFileUrl, options: optDict as? [String : Any])
        
        let cmTime = urlAsset.duration
        let durationSeconds: Float64 = CMTimeGetSeconds(cmTime) //视频总秒数
        
        var times = [NSValue]()
        let totalFrames: Float64 = durationSeconds * Float64(fps) //获取视频的总帧数
        var timeFrame: CMTime
        
        for i in 0...Int(totalFrames) {
            timeFrame = CMTimeMake(Int64(i), Int32(fps)) //第i帧， 帧率
            let timeValue = NSValue(time: timeFrame)
            
            times.append(timeValue)
        }
        
        let imgGenerator = AVAssetImageGenerator(asset: urlAsset)
        imgGenerator.requestedTimeToleranceBefore = kCMTimeZero //防止时间出现偏差
        imgGenerator.requestedTimeToleranceAfter = kCMTimeZero
        
        let timesCount = times.count
        
        //获取每一帧的图片
        imgGenerator.generateCGImagesAsynchronously(forTimes: times) { (requestedTime, image, actualTime, result, error) in
            
            //times有多少次body就循环多少次。。。。
            print("current-----\(requestedTime.value)   timesCount == \(timesCount)")
            print("timeScale-----\(requestedTime.timescale) requestedTime:\(requestedTime.value)")
            
            var isSuccess = false
            switch (result) {
            case AVAssetImageGeneratorResult.cancelled:
                print("cancelled------")
                
            case AVAssetImageGeneratorResult.failed:
                print("failed++++++")
                
            case AVAssetImageGeneratorResult.succeeded:
                let framImg = UIImage(cgImage: image!)
                splitImages.append(framImg)
                
                if (Int(requestedTime.value) == (timesCount-1)) { //最后一帧时 回调赋值
                    isSuccess = true
                    splitCompleteClosure(isSuccess, splitImages)
                    print("completed")
                }
            }
        }
    }
}
