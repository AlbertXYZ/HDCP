//
//  HDCG01ViewController.swift
//  HDCP
//
//  Created by 徐琰璋 on 16/1/4.
//  Copyright © 2016年 batonsoft. All rights reserved.
//

import UIKit
import Kingfisher

private let cateArray = [["title":"口味","image":"KWIcon"],
    ["title":"菜系","image":"CXIcon"],
    ["title":"菜品","image":"CPIcon"],
    ["title":"场景","image":"CJIcon"],
    ["title":"热门分类","image":"RMFLIcon"],
    ["title":"流行食材","image":"LXSCIcon"],
    ["title":"常见功效","image":"CJGXIcon"],
    ["title":"加工工艺","image":"JGGYIcon"],
    ["title":"厨房用具","image":"CFYJIcon"]]

class HDCG01Controller: UITableViewController,UISearchBarDelegate {

 
    var searchBar:UISearchBar!
    var dataArray = Array<HDCG01ListModel>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge();
        self.navigationController?.navigationBar.isTranslucent = false
        
        setupUI()
        
        if HDCG01Service().isExistEntity() {
            /**
            *  读取本地数据
            */
            dataArray = HDCG01Service().getAllTagListEntity()
            
        }else{
        
            if CoreUtils.networkIsReachable() {
                
                doGetRequestData()
                
            }
        }
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hidenHud()
    }
    
    
    deinit{
        
        HDLog.LogClassDestory("HDCG01Controller" as AnyObject)
        
    }
    
    // MARK: - 提示动画显示和隐藏
    func showHud(){
        
        CoreUtils.showProgressHUD(self.view)
        
    }
    
    func hidenHud(){
        
        CoreUtils.hidProgressHUD(self.view)
    }
    
    // MARK: - 创建UI视图
    
    func setupUI(){
        
        self.tableView?.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "myCell")
        self.tableView.backgroundColor = Constants.HDBGViewColor
        self.tableView.tableFooterView = UIView()
        
        
        searchBar =  UISearchBar()
        searchBar.placeholder = "搜索菜谱、食材或功效"
        searchBar.delegate = self
        searchBar.frame = CGRect(x: 0, y: 0, width: Constants.HDSCREENWITH, height: 44)
        searchBar.sizeToFit()
        searchBar.barTintColor = Constants.HDBGViewColor
        searchBar.layer.borderWidth = 1;
        searchBar.layer.borderColor = Constants.HDBGViewColor.cgColor;
        searchBar.showsCancelButton = false
        self.tableView.tableHeaderView = searchBar
        
    }
    
    // MARK: - 数据加载
    func doGetRequestData(){
        
        
        showHud()
        unowned let WS = self
        HDCG01Service().doGetRequest_HDCG02_URL({ (HDCG01Response) -> Void in
            
            WS.hidenHud()
            if (HDCG01Response.result?.list!.count)!>0 {
                WS.dataArray = (HDCG01Response.result?.list!)!
            }
            WS.tableView!.reloadData()
            
            }) { (error) -> Void in
                
                CoreUtils.showWarningHUD(WS.view, title: Constants.HD_NO_NET_MSG)
                
        }
        
        
    }
    

    // MARK: - UISearchBar delegate
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        let hdHM04VC = HDCG03Controller()
        self.hidesBottomBarWhenPushed = true;
        self.navigationController?.pushViewController(hdHM04VC, animated: false)
        self.hidesBottomBarWhenPushed = false;
        
        return false
    }
    
    
    // MARK: - UITableView delegate/datasource
    
    override func tableView(_ tableView:UITableView, numberOfRowsInSection section: Int) ->Int
    {
        return dataArray.count
    }
    
    override func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) ->UITableViewCell
    {
        let cell = tableView .dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        /**
         *  图标
         */
        var icon:UIImageView? = cell.viewWithTag(1000) as? UIImageView
        if icon == nil {
            
            icon = UIImageView()
            icon?.tag = 1000
            cell.contentView.addSubview(icon!)
            icon?.snp.makeConstraints({ (make) -> Void in
                
                make.width.equalTo(20)
                make.height.equalTo(20)
                make.left.equalTo(cell.contentView).offset(16)
                make.top.equalTo(cell.contentView).offset(12)
                
            })
            
        }
        
        
        /**
         *  名称
         */
        var title:UILabel? = cell.viewWithTag(2000) as? UILabel
        if title == nil {
            
            title = UILabel()
            title?.tag = 2000
            title?.textColor = Constants.HDMainTextColor
            title?.font = UIFont.systemFont(ofSize: 15)
            cell.contentView.addSubview(title!)
            title?.snp.makeConstraints({ (make) -> Void in
                
                make.width.equalTo(200)
                make.height.equalTo(44)
                make.left.equalTo((icon?.snp.right)!).offset(16)
                make.top.equalTo(cell.contentView).offset(0)
            })
        }
        
        /**
         *  箭头
         */
        var arrow:UIImageView? = cell.viewWithTag(3000) as? UIImageView
        if arrow == nil {
            
            arrow = UIImageView()
            arrow?.tag = 3000
            cell.contentView.addSubview(arrow!)
            
            arrow?.snp.makeConstraints({ (make) -> Void in
                
                make.width.equalTo(20)
                make.height.equalTo(20)
                make.right.equalTo(cell.contentView).offset(-20)
                make.top.equalTo(cell.contentView).offset(12)
                
            })
            
        }
        
        
        let model = dataArray[(indexPath as NSIndexPath).row] as HDCG01ListModel
        
        icon?.kf.setImage(with: URL(string:model.imgUrl!),
                          placeholder: UIImage(named: "noDataDefaultIcon"),
                          options: nil,
                          progressBlock: { receivedSize, totalSize in
                            
        },
                          completionHandler: { image, error, cacheType, imageURL in
                            
        })

        
        title?.text =   model.cate!
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        /**
        *  分类列表
        */
        let model = dataArray[(indexPath as NSIndexPath).row] as HDCG01ListModel
        
        let hdcg02VC = HDCG02Controller()
        hdcg02VC.name = model.cate
        self.hidesBottomBarWhenPushed = true;
        self.navigationController?.pushViewController(hdcg02VC, animated: true)
        self.hidesBottomBarWhenPushed = false;
        
    }

}
