//
//  ViewController.swift
//  TMYSegmentController
//
//  Created by TMY on 2017/5/8.
//  Copyright © 2017年 TMY. All rights reserved.
//
/**
 播放网络视频...
 */

import UIKit
import AVFoundation

typealias completeClosure = (_ success:Bool, _ splitImgs: Array<Any>) -> ()

class ViewController: UIViewController {

    private var playItem: AVPlayerItem?
    private var player: AVPlayer?
    private var playLayer: AVPlayerLayer?
    private let timeLabel = UILabel()
    private let slider = UISlider()
    private var sliding = false
    private var link: CADisplayLink?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "视频播放"
        view.backgroundColor = #colorLiteral(red: 0.7277651429, green: 0.738256216, blue: 0.978562057, alpha: 1)
        
        guard let url = URL.init(string: "http://bos.nj.bpc.baidu.com/tieba-smallvideo/11772_3c435014fb2dd9a5fd56a57cc369f6a0.mp4") else {
            fatalError("链接错误")
        }
        playItem = AVPlayerItem(url: url)
        playItem?.addObserver(self, forKeyPath: "loadTimeRanges", options: .new, context: nil)
        playItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        
        player = AVPlayer(playerItem: playItem)
        playLayer = AVPlayerLayer(player: player)
        
        playLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        playLayer?.contentsScale = UIScreen.main.scale
        
        playLayer?.frame = UIScreen.main.bounds
        playLayer?.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1).cgColor
        view.layer.addSublayer(playLayer!)
        
        bottomTools()
    }
    
    func bottomTools() {
        timeLabel.do {
            $0.textColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            $0.text = "xxx"
            $0.font = UIFont.systemFont(ofSize: 14)
            $0.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 20, width: 100, height: 25)
        }
        view.addSubview(timeLabel)
        
        link = CADisplayLink(target: self, selector: #selector(update))
        link?.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
        
        slider.do {
            $0.minimumValue = 0
            $0.maximumValue = 1
            $0.value = 0
            $0.maximumTrackTintColor = UIColor.cyan
            $0.minimumTrackTintColor = UIColor.white
            $0.setThumbImage(#imageLiteral(resourceName: "my_icon_info.png"), for: .normal)
            $0.frame = CGRect(x: 10, y: UIScreen.main.bounds.size.height - 20, width: UIScreen.main.bounds.size.width - 110, height: 25)
            $0.addTarget(self, action: #selector(sliderTouchDowm(slider:)), for: .touchDown)
            $0.addTarget(self, action: #selector(sliderTouchDowm(slider:)), for: .touchUpOutside)
            $0.addTarget(self, action: #selector(sliderTouchDowm(slider:)), for: .touchUpInside)
            $0.addTarget(self, action: #selector(sliderTouchDowm(slider:)), for: .touchCancel)

        }
        timeLabel.frame = CGRect(x: slider.frame.maxX + 10, y: UIScreen.main.bounds.size.height - 20, width: 100, height: 25)
        view.addSubview(slider)
    }
    
    func formatPlayTime(secounds: TimeInterval) -> String {
        if secounds.isNaN {
            return "00:00"
        }
        let minit = Int(secounds/60)
        let sec = Int(secounds.truncatingRemainder(dividingBy: 60))
        
        return String(format: "%02d:%02d", minit, sec)
    }
    
    func update() {
        let currentTime = CMTimeGetSeconds((player?.currentTime())!)
        let totalTime = TimeInterval((playItem?.duration.value)!) / TimeInterval((playItem?.duration.timescale)!)
        let timeStr = "\(formatPlayTime(secounds: currentTime))/\(formatPlayTime(secounds: totalTime))"
        timeLabel.text = timeStr
        slider.value = Float(currentTime/totalTime)
        if !sliding {
            slider.value = Float(currentTime/totalTime)
        }
    }
    
    func sliderTouchDowm(slider:UISlider) {
        sliding = true
        if player?.status == AVPlayerStatus.readyToPlay {
            let duration = slider.value * Float(CMTimeGetSeconds((player?.currentItem?.duration)!))
            let seekTime = CMTime(value: CMTimeValue(duration), timescale: 1)
            player?.seek(to: seekTime, completionHandler: { (b) in
                self.sliding = false
            })
        }
    }
    
    func sliderTouchUpOut(slider: UISlider) {
        print("xxxxxxxxxxxx touchUPout, insider, cancel")
    }
    
    //一共有三种状态  Unknown 、ReadyToPlay 、 Failed 只有在 ReadyToPlay 状态下视频才能播放。
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "CMTime" {
            print("缓存进度")
        }else if keyPath == "status" {
            if playItem?.status == .readyToPlay {
                player?.play()
                print("xxx 正常加载")
            }else {
                print("加载异常")
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("video is viewDidDisappear or not")
        link?.invalidate()//退出页面的时候需停止CADisplayLink 避免循环引用
        link = nil
    }
    
    deinit {
        print("video is deinit or not")
        playItem?.removeObserver(self, forKeyPath: "loadTimeRanges")
        playItem?.removeObserver(self, forKeyPath: "status")
        playItem = nil
        playLayer = nil
        player = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

