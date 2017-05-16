//
//  TMYViewController.swift
//  TMYSegmentController
//
//  Created by TMY on 2017/5/11.
//  Copyright © 2017年 TMY. All rights reserved.
//
/**
 视频捕获
 */


import UIKit
import Photos
import AVFoundation

class TMYViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {

    /**
     AVCaptureSession 视频捕获 input和output 的桥梁
     videoDevice 视频输入设备
     audioDevice 音频输入设备
     */
    private let captureSession = AVCaptureSession()
    private let videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    private let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
    private let fileOutPut = AVCaptureMovieFileOutput()
    
    private let startBtn = UIButton()
    private let stopBtn = UIButton()
    var isRecording = false
    private let kScreenW = UIScreen.main.bounds.size.width
    private let kScreenH = UIScreen.main.bounds.size.height
    
    private var tmpFileUrl:URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "拍摄视频"
        view.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        
        creatUI()
    }
    
    func creatUI() {
        //添加视频音频输入设备、添加视频捕获输出
        let videoInput = try! AVCaptureDeviceInput(device: videoDevice)
        captureSession.addInput(videoInput)
        
        let audioInput = try! AVCaptureDeviceInput(device: audioDevice)
        captureSession.addInput(audioInput)
        
        captureSession.addOutput(fileOutPut)
        
        if let videoLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            videoLayer.frame = view.bounds
            videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            view.layer.addSublayer(videoLayer)
        }
        
        //初始化开始跟结束按钮
        startBtn.do {
            $0.frame = CGRect(x: 20, y: kScreenH - 80, width: 100, height: 40)
            $0.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            $0.setTitle("开始", for: .normal)
            $0.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            $0.setTitleColor(#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), for: .highlighted)
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 8
            $0.addTarget(self, action: #selector(startBtnClick(sender:)), for: .touchUpInside)
        }
        view.addSubview(startBtn)
        
        stopBtn.do {
            $0.frame = CGRect(x: kScreenW - 120, y: kScreenH - 80, width: 100, height: 40)
            $0.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            $0.setTitle("停止", for: .normal)
            $0.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            $0.setTitleColor(#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), for: .highlighted)
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 8
            $0.addTarget(self, action: #selector(stopBtnClick(sender:)), for: .touchUpInside)
        }
        view.addSubview(stopBtn)
        
        captureSession.startRunning()
    }
    
    func startBtnClick(sender:UIButton) -> Void {
        if !isRecording {
            //设置目录的保存地址
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentDict: String = paths[0]
            let filePath = "\(documentDict)/temp.mp4"
            let fileUrl = URL(fileURLWithPath: filePath)
            tmpFileUrl = fileUrl
            
            print("xxx fileUrl: \(fileUrl)")
            //启动视频编码输出
            
            fileOutPut.startRecording(toOutputFileURL: fileUrl, recordingDelegate: self)
            
            isRecording = true
            
            changeBtnEnabel(sender: stopBtn, color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), enabel:true)
            changeBtnEnabel(sender: startBtn, color: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), enabel:false)
        }
    }
    
    func stopBtnClick(sender:UIButton) -> Void {
        if isRecording {
            //停止视频编码输出
            fileOutPut.stopRecording()
            self.isRecording = false
            
            changeBtnEnabel(sender: stopBtn, color: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), enabel: false)
            changeBtnEnabel(sender: startBtn, color: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), enabel: true)
            
//            var imgsArr = [UIImage]()
//            var iCount = 0
//            self.splitVideoFileUrlFps(splitFileUrl: tmpFileUrl!, fps: 60, splitCompleteClosure: { (isSuccess, splitImgs) in
//    
//                print("xxxxx isSuccess:\(isSuccess)")
//                print("xxxxx splitimgsCount:\(splitImgs.count),\(splitImgs[iCount]) xxxxx")
//                iCount += 1
//                imgsArr = splitImgs as! [UIImage]
//            })
//            let imgVC = TMYImgTableViewController()
//            imgVC.imgArray = imgsArr
//            navigationController?.pushViewController(imgVC, animated: true)
        }
    }

    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("StartRecording 开始")
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        var message:String!
        
        //将录制好的录像保存到照片库中
        PHPhotoLibrary.shared().performChanges({
            
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }) { (isSuccess:Bool, error:Error?) in
            if isSuccess {
                message = "保存成功"
            }else {
                message = "失败:\(String(describing: error?.localizedDescription))"
            }
            
            DispatchQueue.main.async {[weak self] in
                let alertVC = UIAlertController(title: message, message: nil, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "sure", style: .cancel, handler: nil)
                alertVC.addAction(cancelAction)
                
                self?.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    
    /// 视频分解成帧
    /// - parameter fileUrl                 : 视频地址
    /// - parameter fps                     : 帧数
    /// - parameter splitCompleteClosure    : 回调
//    func splitVideoFileUrlFps(splitFileUrl:URL, fps:Float, splitCompleteClosure:@escaping completeClosure) {
//        
//        // TODO: 判断fileUrl是否为空
//        //        if let furl:URL = fileUrl {
//        //
//        //        }else {
//        //            return
//        //        }
//        print("QQQQQQQQQQ ==> split: \(splitFileUrl)")
//        
//        var splitImages = [UIImage]()
//        let optDict = NSDictionary(object: NSNumber(value: false), forKey: AVURLAssetPreferPreciseDurationAndTimingKey as NSCopying)
//        let urlAsset = AVURLAsset(url: splitFileUrl, options: optDict as? [String : Any])
//        
//        let cmTime = urlAsset.duration
//        let durationSeconds: Float64 = CMTimeGetSeconds(cmTime)
//        
//        var times = [NSValue]()
//        let totalFrames: Float64 = durationSeconds * Float64(fps)
//        var timeFrame: CMTime
//        
//        for i in 0...Int(totalFrames) {
//            timeFrame = CMTimeMake(Int64(i), Int32(fps))
//            let timeValue = NSValue(time: timeFrame)
//            
//            times.append(timeValue)
//        }
//        
//        let imgGenerator = AVAssetImageGenerator(asset: urlAsset)
//        imgGenerator.requestedTimeToleranceBefore = kCMTimeZero
//        imgGenerator.requestedTimeToleranceAfter = kCMTimeZero
//        
//        let timesCount = times.count
//        
//        imgGenerator.generateCGImagesAsynchronously(forTimes: times) { (requestedTime, image, actualTime, result, error) in
//            
//            print("current-----\(requestedTime.value)")
//            print("timeScale-----\(requestedTime.timescale)")
//            
//            var isSuccess = false
//            
//            switch (result) {
//            case AVAssetImageGeneratorResult.cancelled:
//                print("cancelled------")
//            case AVAssetImageGeneratorResult.failed:
//                print("failed++++++")
//            case AVAssetImageGeneratorResult.succeeded:
//                let framImg = UIImage(cgImage: image!)
//                splitImages.append(framImg)
//                
//                if (Int(requestedTime.value) == timesCount) {
//                    isSuccess = true
//                    print("completed")
//                }
//            }
//            splitCompleteClosure(isSuccess, splitImages)
//        }
//    }
    
    func changeBtnEnabel(sender:UIButton, color:UIColor, enabel:Bool) {
        sender.isEnabled = enabel
        sender.backgroundColor = color
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 

}
