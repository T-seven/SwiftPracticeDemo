//
//  TMYTableViewController.swift
//  TMYSegmentController
//
//  Created by TMY on 2017/5/11.
//  Copyright © 2017年 TMY. All rights reserved.
//

import UIKit

class TMYTableViewController: UITableViewController {

    private let dataSource = ["播放视频", "拍摄视频", "视频分解"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "目录"
        view.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        tableView.rowHeight = 55
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifiercell")
        cell.textLabel?.text = dataSource[indexPath.section]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
        let str = dataSource[indexPath.section]
        var vc: Any?
        
        switch str {
        case "播放视频":
            vc = ViewController()
        case "拍摄视频":
            vc = TMYViewController()
        case "视频分解":
            vc = TMYImgTableViewController()
        default:
            print("xxxx ----- xxxx")
        }
        navigationController?.pushViewController(vc as! UIViewController, animated: true)
    }
 
}
