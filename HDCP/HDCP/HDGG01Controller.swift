//
//  HDGG01Controller.swift
//  HDCP
//
//  Created by 徐琰璋 on 16/1/4.
//  Copyright © 2016年 batonsoft. All rights reserved.
//

import UIKit
import SDWebImage
private let gg01Array = [["title":"厨房宝典","image":"CFBDIcon"],
    ["title":"应用推荐","image":"YYTJIcon"],
    ["title":"意见反馈","image":"YJFKIcon"],
    ["title":"菜谱专辑","image":"CPZJIcon"],
    ["title":"营养餐桌","image":"YYCZIcon"],
    ["title":"食材百科","image":"SCBKIcon"]]

class HDGG01Controller: BaseViewController ,UITableViewDelegate,UITableViewDataSource,HDGG01RowViewProtocol{

    var hdGG01Response:HDGG01Response!
    var tableView:UITableView?
    var headerView:UIView?
    var count:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = UIRectEdge.None;
        self.navigationController?.navigationBar.translucent = false
        
        //双击TabItem通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(gg01Notification(_:)), name: Constants.HDREFRESHHDGG01, object: nil)
        
        count = 0
        setupUI()
        
        if HDGG01Service().isExistEntity() {
            /**
            *  读取本地数据
            */
            
            self.hdGG01Response =  HDGG01Service().getAllResponseEntity()
            self.count = hdGG01Response.array2D!.count
            self.tableView!.reloadData()
            
            self.tableView?.hidden = false
            
            doGetRequestData()
            
        }else{
        
            if CoreUtils.networkIsReachable() {
                
                showHud()
                doGetRequestData()
                
            }
        }
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        hidenHud()
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
    }

    deinit{
    
        tableView?.delegate = nil
        tableView?.dataSource = nil
    }
    // MARK: - 创建UI视图
   
    func setupUI(){
    
        createTableView()
        createHeaderView()
        
        
        
    }
    
    func createHeaderView(){
    
        if headerView == nil {
            
            headerView = UIView(frame: CGRectMake(0,0,Constants.HDSCREENWITH/3,2*Constants.HDSCREENWITH/3+2*CGFloat(Constants.HDSpace)))
            headerView?.backgroundColor = UIColor.clearColor()
            tableView?.tableHeaderView = headerView
            
            var index = 0
            
            for i in 0 ..< 2 {
                
                for j in 0 ..< 3 {
                
                    let btn = HDGG01Button()
                    btn.tag = index+400
                    btn.setImage(UIImage(named: gg01Array[index]["image"]!), forState: UIControlState.Normal)
                    btn.setTitle(gg01Array[index]["title"]!, forState: UIControlState.Normal)
                    btn.titleLabel?.font = UIFont.systemFontOfSize(15)
                    btn.backgroundColor = UIColor.whiteColor()
                    btn.titleLabel?.textAlignment = NSTextAlignment.Center
                    btn.layer.borderWidth = 0.5
                    btn.layer.borderColor = Constants.HDBGViewColor.CGColor
                    btn.setTitleColor(Constants.HDMainTextColor, forState: UIControlState.Normal)
                    btn.addTarget(self, action: #selector(menuBtnOnclick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                    headerView!.addSubview(btn)

                    btn.snp_makeConstraints(closure: { (make) -> Void in
                        
                        make.top.equalTo(headerView!).offset(CGFloat(i)*Constants.HDSCREENWITH/3+10)
                        make.left.equalTo(headerView!).offset(CGFloat(j)*Constants.HDSCREENWITH/3)
                        make.width.equalTo(Constants.HDSCREENWITH/3)
                        make.height.equalTo(Constants.HDSCREENWITH/3)
                        
                    })
                    index += 1
                }
                
            }
            
        }
        
    }
    
    func createTableView(){
    
        if tableView == nil {
        
            tableView = UITableView()
            tableView?.tableFooterView = UIView()
            tableView?.delegate = self
            tableView?.dataSource = self
            tableView?.backgroundColor = UIColor.clearColor()
            tableView?.separatorStyle = UITableViewCellSeparatorStyle.None
            self.tableView?.hidden = true
            self.view.addSubview(self.tableView!)
            tableView?.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "myCell")
            tableView?.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "mycell2")
            tableView?.snp_makeConstraints(closure: { (make) -> Void in
                
                make.top.equalTo(self.view).offset(0)
                make.left.equalTo(self.view).offset(0)
                make.bottom.equalTo(self.view).offset(0)
                make.width.equalTo(Constants.HDSCREENWITH)
                
            })
            
            tableView?.mj_header = HDRefreshGifHeader(refreshingBlock: { () -> Void in
                
                self.doGetRequestData()
                
            })

        }
        
    }
    
    // MARK: - 提示动画显示和隐藏
    func showHud(){
        
        CoreUtils.showProgressHUD(self.view)
        
    }
    
    func hidenHud(){
        
        CoreUtils.hidProgressHUD(self.view)
    }
    
    // MARK: - 通知事件
    
    func gg01Notification(noti:NSNotification){
        
        let flag = noti.userInfo!["FLAG"] as? String
        
        if flag == Constants.HDREFRESHHDGG01 {
            
            /**
            *  开始刷新 获取最新数据
            */
            self.tableView?.mj_header.beginRefreshing()
            
        }
        
        
    }
    
    // MARK: - onclik events
    
    func menuBtnOnclick(btn:UIButton){
    
        let tag:Int = btn.tag - 400
        switch tag {
            
        case 0:
            /**
            *   厨房宝典
            */
            let hdHM07VC = HDHM07Controller()
            self.hidesBottomBarWhenPushed = true;
            self.navigationController?.pushViewController(hdHM07VC, animated: true)
            self.hidesBottomBarWhenPushed = false
            print("\(btn.currentTitle)")
            break
        case 1:
            /**
            *   应用推荐
            */
            let hdgg02VC = HDGG02Controller()
            self.hidesBottomBarWhenPushed = true;
            self.navigationController?.pushViewController(hdgg02VC, animated: true)
            self.hidesBottomBarWhenPushed = false
            print("\(btn.currentTitle)")
            break
            
        case 2:
            /**
            *   意见反馈
            */
            let hdgg04VC = HDGG04Controller()
            self.hidesBottomBarWhenPushed = true;
            self.navigationController?.pushViewController(hdgg04VC, animated: true)
            self.hidesBottomBarWhenPushed = false
            print("\(btn.currentTitle)")
            break
            
        case 3:
            /**
            *   菜谱专辑
            */
            let hdHM06VC = HDHM06Controller()
            self.hidesBottomBarWhenPushed = true;
            self.navigationController?.pushViewController(hdHM06VC, animated: true)
            self.hidesBottomBarWhenPushed = false
            print("\(btn.currentTitle)")
            break
        case 4:
            /**
            *   营养餐桌
            */
            let hdHM03VC = HDHM03Controller()
            self.hidesBottomBarWhenPushed = true;
            self.navigationController?.pushViewController(hdHM03VC, animated: true)
            self.hidesBottomBarWhenPushed = false
            print("\(btn.currentTitle)")
            break
        case 5:
            /**
            *   食材百科
            */
            let hdcg02VC = HDCG02Controller()
            hdcg02VC.name = "流行食材"
            self.hidesBottomBarWhenPushed = true;
            self.navigationController?.pushViewController(hdcg02VC, animated: true)
            self.hidesBottomBarWhenPushed = false
            print("\(btn.currentTitle)")
            break

        default:
            "default"
        }
        
    }
    
    // MARK: - 数据加载
    /**
     *  加载数据
     */
    func doGetRequestData(){
    
        
        HDGG01Service().doGetRequest_HDGG01_URL({ (hdResponse) -> Void in
            
            self.hidenHud()
            self.count = hdResponse.array2D!.count
            self.hdGG01Response = hdResponse
            self.tableView!.reloadData()
            
            self.tableView?.hidden = false
            
            self.tableView?.mj_header.endRefreshing()
            
            }) { (error) -> Void in
                
                self.tableView?.mj_header.endRefreshing()
                CoreUtils.showWarningHUD(self.view, title: Constants.HD_NO_NET_MSG)
                
        }

        
    }
    
    // MARK: - HDGG01RowView delegate
    func didSelectHDGG01RowView(indexPath:NSIndexPath,index:Int)->Void{
    
        print("\(indexPath.row)    \(index) ")
        
        let array2d = self.hdGG01Response.array2D![indexPath.row] as! Array<HDGG01ListModel>
        let model:HDGG01ListModel = array2d[index]
        
        if model.url.hasPrefix("http") {
        
            //进入webView
            let webVC = HDWebController()
            webVC.name = model.title
            webVC.url = model.url
            self.hidesBottomBarWhenPushed = true;
            self.navigationController?.pushViewController(webVC, animated: true)
            self.hidesBottomBarWhenPushed = false
            
        }else{
        
            //菜谱专辑
            let hdhm05VC = HDHM05Controller()
            hdhm05VC.name = model.title
            hdhm05VC.cid = NSInteger(model.url)
            self.hidesBottomBarWhenPushed = true;
            self.navigationController?.pushViewController(hdhm05VC, animated: true)
            self.hidesBottomBarWhenPushed = false
            
            
        }
        
        
    }
    
    // MARK: - UIScrollView delegate
    func tableView(tableView:UITableView, numberOfRowsInSection section: Int) ->Int
    {
        return count
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) ->UITableViewCell
    {
        
        
        
        if indexPath.row%2==0 {
        
            /**
             *  左边大图
             */
            
            let cell = tableView .dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath)
            
            // 大图 左
            var leftImageView = cell.viewWithTag(1000)  as? HDGG01RowView
            if leftImageView == nil {
                
                leftImageView = HDGG01RowView()
                leftImageView?.tag = 1000
                cell.contentView.addSubview(leftImageView!)
                
                leftImageView?.snp_makeConstraints(closure: { (make) -> Void in
                    
                    make.left.equalTo(cell.contentView).offset(10)
                    make.top.equalTo(cell.contentView).offset(10)
                    make.height.equalTo(3*Constants.HDSCREENWITH/5)
                    make.width.equalTo(3*Constants.HDSCREENWITH/5)
                })
                
            }
            
            // 小图 上
            var topImageView = cell.viewWithTag(2000)  as? HDGG01RowView
            if topImageView == nil {
                
                topImageView = HDGG01RowView()
                topImageView?.tag = 2000
                cell.contentView.addSubview(topImageView!)
                
                topImageView?.snp_makeConstraints(closure: { (make) -> Void in
                    
                    make.right.equalTo(cell.contentView).offset(-10)
                    make.top.equalTo(cell.contentView).offset(10)
                    make.height.equalTo((3*Constants.HDSCREENWITH/5-5)/2)
                    make.width.equalTo(2*Constants.HDSCREENWITH/5-30)
                })
                
            }
            // 小图 下
            var bottomImageView = cell.viewWithTag(3000)  as? HDGG01RowView
            if bottomImageView == nil {
                
                bottomImageView = HDGG01RowView()
                bottomImageView?.tag = 3000
                cell.contentView.addSubview(bottomImageView!)
                
                bottomImageView?.snp_makeConstraints(closure: { (make) -> Void in
                    
                    make.right.equalTo(cell.contentView).offset(-10)
                    make.bottom.equalTo(cell.contentView).offset(-20)
                    make.height.equalTo((3*Constants.HDSCREENWITH/5-5)/2)
                    make.width.equalTo(2*Constants.HDSCREENWITH/5-30)
                })
                
            }
    
            var bgLine =  cell.viewWithTag(10000) as? UILabel
            
            if bgLine == nil {
                
                bgLine = UILabel()
                bgLine?.tag = 10000
                bgLine?.backgroundColor = Constants.HDBGViewColor
                cell.contentView.addSubview(bgLine!)
                
                bgLine?.snp_makeConstraints(closure: { (make) -> Void in
                    
                    make.bottom.equalTo(0)
                    make.left.equalTo(0)
                    make.width.equalTo(Constants.HDSCREENWITH)
                    make.height.equalTo(Constants.HDSpace)
                    
                })
            }
            
            let array2d = self.hdGG01Response.array2D![indexPath.row] as! Array<HDGG01ListModel>
            
            let leftModel = array2d[0]
            
            let leftImage:UIImage? = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(leftModel.image!)
            if let _ = leftImage {
                leftImageView!.imageView.image = leftImage
            }else{
                leftImageView!.imageView.sd_setImageWithURL(NSURL(string: (leftModel.image!)), placeholderImage: UIImage(named: "noDataDefaultIcon"), completed: { (image, error, type, url) -> Void in
                    //保存图片，并保存到物理存储上
                    SDImageCache.sharedImageCache().storeImage(image, forKey: leftModel.image!, toDisk: true)
                })
            }
            
            leftImageView?.title.text = leftModel.title
            leftImageView?.delegate = self
            leftImageView?.indexPath = indexPath
            leftImageView!.index = 0
            
            let topModel = array2d[1]
            let topImage:UIImage? = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(topModel.image!)
            if let _ = topImage {
                topImageView!.imageView.image = topImage
            }else{
                topImageView!.imageView.sd_setImageWithURL(NSURL(string: (topModel.image!)), placeholderImage: UIImage(named: "noDataDefaultIcon"), completed: { (image, error, type, url) -> Void in
                    //保存图片，并保存到物理存储上
                    SDImageCache.sharedImageCache().storeImage(image, forKey: topModel.image!, toDisk: true)
                })
            }
            
            topImageView?.title.text = topModel.title
            topImageView?.delegate = self
            topImageView?.indexPath = indexPath
            topImageView!.index = 1
            
            let bottomModel = array2d[2]
            let bottomImage:UIImage? = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(bottomModel.image!)
            if let _ = bottomImage {
                bottomImageView!.imageView.image = bottomImage
            }else{
                bottomImageView!.imageView.sd_setImageWithURL(NSURL(string: (bottomModel.image!)), placeholderImage: UIImage(named: "noDataDefaultIcon"), completed: { (image, error, type, url) -> Void in
                    //保存图片，并保存到物理存储上
                    SDImageCache.sharedImageCache().storeImage(image, forKey: bottomModel.image!, toDisk: true)
                })
            }
            
            bottomImageView?.title.text = bottomModel.title
            bottomImageView?.delegate = self
            bottomImageView?.indexPath = indexPath
            bottomImageView!.index = 2
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell
        }else{
        
            /**
             *  右边大图
             */

            let cell = tableView .dequeueReusableCellWithIdentifier("mycell2", forIndexPath: indexPath)
            
            //  右大图
            var rightImageView = cell.viewWithTag(4000)  as? HDGG01RowView
            if rightImageView == nil {
                rightImageView = HDGG01RowView()
                rightImageView?.tag = 4000
                cell.contentView.addSubview(rightImageView!)
                
                rightImageView?.snp_makeConstraints(closure: { (make) -> Void in
                    
                    make.right.equalTo(cell.contentView).offset(-10)
                    make.top.equalTo(cell.contentView).offset(10)
                    make.height.equalTo(3*Constants.HDSCREENWITH/5)
                    make.width.equalTo(3*Constants.HDSCREENWITH/5)
                })
                
            }

            //  上小图
            var topImageView = cell.viewWithTag(5000)  as? HDGG01RowView
            if topImageView == nil {
                
                topImageView = HDGG01RowView()
                topImageView?.tag = 5000
                cell.contentView.addSubview(topImageView!)
                
                topImageView?.snp_makeConstraints(closure: { (make) -> Void in
                    
                    make.left.equalTo(cell.contentView).offset(10)
                    make.top.equalTo(cell.contentView).offset(10)
                    make.height.equalTo((3*Constants.HDSCREENWITH/5-5)/2)
                    make.width.equalTo(2*Constants.HDSCREENWITH/5-30)
                })
                
            }
            
            //  下小图
            var bottomImageView = cell.viewWithTag(6000)  as? HDGG01RowView
            if bottomImageView == nil {
                
                bottomImageView = HDGG01RowView()
                bottomImageView?.tag = 6000
                cell.contentView.addSubview(bottomImageView!)
                
                bottomImageView?.snp_makeConstraints(closure: { (make) -> Void in
                    
                    make.left.equalTo(cell.contentView).offset(10)
                    make.bottom.equalTo(cell.contentView).offset(-20)
                    make.height.equalTo((3*Constants.HDSCREENWITH/5-5)/2)
                    make.width.equalTo(2*Constants.HDSCREENWITH/5-30)
                })
                
            }


            var bgLine =  cell.viewWithTag(20000) as? UILabel
            
            if bgLine == nil {
                
                bgLine = UILabel()
                bgLine?.tag = 20000
                bgLine?.backgroundColor = Constants.HDBGViewColor
                cell.contentView.addSubview(bgLine!)
                
                bgLine?.snp_makeConstraints(closure: { (make) -> Void in
                    
                    make.bottom.equalTo(0)
                    make.left.equalTo(0)
                    make.width.equalTo(Constants.HDSCREENWITH)
                    make.height.equalTo(Constants.HDSpace)
                    
                })
            }
            
            let array2d = self.hdGG01Response.array2D![indexPath.row] as! Array<HDGG01ListModel>
            
            let rightModel:HDGG01ListModel = array2d[0]
            rightImageView!.imageView.sd_setImageWithURL(NSURL(string: rightModel.image!), placeholderImage: UIImage(named: "noDataDefaultIcon"))
            rightImageView?.title.text = rightModel.title
            rightImageView?.delegate = self
            rightImageView?.indexPath = indexPath
            rightImageView!.index = 0
            
            let topModel = array2d[1]
            topImageView!.imageView.sd_setImageWithURL(NSURL(string: topModel.image!), placeholderImage: UIImage(named: "noDataDefaultIcon"))
            topImageView?.title.text = topModel.title
            topImageView?.delegate = self
            topImageView?.indexPath = indexPath
            topImageView!.index = 1
            
            let bottomModel = array2d[2] 
            bottomImageView!.imageView.sd_setImageWithURL(NSURL(string: bottomModel.image!), placeholderImage: UIImage(named: "noDataDefaultIcon"))
            bottomImageView?.title.text = bottomModel.title
            bottomImageView?.delegate = self
            bottomImageView?.indexPath = indexPath
            bottomImageView!.index = 2
        
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 3*Constants.HDSCREENWITH/5+20+10
    }

}
