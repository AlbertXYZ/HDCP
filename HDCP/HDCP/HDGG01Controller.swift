//
//  HDGG01Controller.swift
//  HDCP
//
//  Created by 徐琰璋 on 16/1/4.
//  Copyright © 2016年 batonsoft. All rights reserved.
//

import UIKit



class HDGG01Controller: BaseViewController ,UITableViewDelegate,UITableViewDataSource{

    let gg01Array = [["title":"厨房宝典","image":"CFBDIcon"],
        ["title":"应用推荐","image":"YYTJIcon"],
        ["title":"意见反馈","image":"YJFKIcon"],
        ["title":"菜谱专辑","image":"CPZJIcon"],
        ["title":"营养餐桌","image":"YYCZIcon"],
        ["title":"食材百科","image":"SCBKIcon"]]
    
    
    var hdGG01Response:HDGG01Response!
    var tableView:UITableView?
    var headerView:UIView?
    var count:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        count = 0
        setupUI()
        showHud()
        doGetRequestData()
        
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
    }

    // MARK: - 创建UI视图
   
    func setupUI(){
    
        createTableView()
        createHeaderView()
        
        
        
    }
    
    func createHeaderView(){
    
        if headerView == nil {
            
            headerView = UIView(frame: CGRectMake(0,0,Constants.kSCREENWITH/3,2*Constants.kSCREENWITH/3+2*CGFloat(Constants.HDSpace)))
            headerView?.backgroundColor = UIColor.clearColor()
            tableView?.tableHeaderView = headerView
            
            var index = 0
            
            for var i=0;i<2;i++ {
                
                for var j=0;j<3;j++ {
                
                    let btn = HDGG01Button()
                    btn.tag = i+400
                    btn.setImage(UIImage(named: gg01Array[index]["image"]!), forState: UIControlState.Normal)
                    btn.setTitle(gg01Array[index]["title"]!, forState: UIControlState.Normal)
                    btn.titleLabel?.font = UIFont.systemFontOfSize(16)
                    btn.backgroundColor = UIColor.whiteColor()
                    btn.titleLabel?.textAlignment = NSTextAlignment.Center
                    btn.layer.borderWidth = 0.5
                    btn.layer.borderColor = Constants.HDBGViewColor.CGColor
                    btn.setTitleColor(Constants.HDMainTextColor, forState: UIControlState.Normal)
                    btn.addTarget(self, action: "menuBtnOnclick:", forControlEvents: UIControlEvents.TouchUpInside)
                    headerView!.addSubview(btn)

                    btn.snp_makeConstraints(closure: { (make) -> Void in
                        
                        make.top.equalTo(headerView!).offset(CGFloat(i)*Constants.kSCREENWITH/3+10)
                        make.left.equalTo(headerView!).offset(CGFloat(j)*Constants.kSCREENWITH/3)
                        make.width.equalTo(Constants.kSCREENWITH/3)
                        make.height.equalTo(Constants.kSCREENWITH/3)
                        
                    })
                    index++
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
            tableView?.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "mycell")
            tableView?.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "mycell2")
            tableView?.snp_makeConstraints(closure: { (make) -> Void in
                
                make.top.equalTo(self.view).offset(0)
                make.left.equalTo(self.view).offset(0)
                make.bottom.equalTo(self.view).offset(0)
                make.width.equalTo(Constants.kSCREENWITH)
                
            })
            
            tableView?.mj_header = HDRefreshGifHeader(refreshingBlock: { () -> Void in
                
                self.doGetRequestData()
                
            })

        }
        
    }
    
    func showHud(){
        
        CoreUtils.showProgressHUD(self.view)
        
    }
    
    func hidenHud(){
        
        CoreUtils.hidProgressHUD(self.view)
    }
    
    // MARK: - events 
    
    func menuBtnOnclick(btn:UIButton){
    
        let tag:Int = btn.tag - 400
        switch tag {
            
        case 0:
            /**
            *   厨房宝典
            */
            print("\(btn.currentTitle)")
            break
        case 1:
            /**
            *   应用推荐
            */
            print("\(btn.currentTitle)")
            break
            
        case 2:
            /**
            *   意见反馈
            */
            print("\(btn.currentTitle)")
            break
            
        case 3:
            /**
            *   菜谱专辑
            */
            print("\(btn.currentTitle)")
            break
        case 4:
            /**
            *   营养餐桌
            */
            print("\(btn.currentTitle)")
            break
        case 5:
            /**
            *   食材百科
            */
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
            
            NSThread.sleepForTimeInterval(1)
            
            self.hidenHud()
            self.count = hdResponse.array2D!.count
            self.hdGG01Response = hdResponse
            self.tableView!.reloadData()
            
            self.tableView?.hidden = false
            
            self.tableView?.mj_header.endRefreshing()
            
            }) { (error) -> Void in
                
                self.tableView?.mj_header.endRefreshing()
                CoreUtils.showProgressHUD(self.view, title: "网络不给力")
                
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
            
            let cell = tableView .dequeueReusableCellWithIdentifier("mycell", forIndexPath: indexPath)
            
            // 大图 左
            var leftImageView = cell.viewWithTag(1000)  as? HDGG01RowView
            if leftImageView == nil {
                
                leftImageView = HDGG01RowView()
                leftImageView?.tag = 1000
                cell.contentView.addSubview(leftImageView!)
                
                leftImageView?.snp_makeConstraints(closure: { (make) -> Void in
                    
                    make.left.equalTo(cell.contentView).offset(10)
                    make.top.equalTo(cell.contentView).offset(10)
                    make.height.equalTo(3*Constants.kSCREENWITH/5)
                    make.width.equalTo(3*Constants.kSCREENWITH/5)
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
                    make.height.equalTo((3*Constants.kSCREENWITH/5-5)/2)
                    make.width.equalTo(2*Constants.kSCREENWITH/5-30)
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
                    make.height.equalTo((3*Constants.kSCREENWITH/5-5)/2)
                    make.width.equalTo(2*Constants.kSCREENWITH/5-30)
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
                    make.width.equalTo(Constants.kSCREENWITH)
                    make.height.equalTo(Constants.HDSpace)
                    
                })
            }
            
            let array2d = self.hdGG01Response.array2D![indexPath.row]
            
            let leftModel:HDGG01ListModel = array2d[0] as! HDGG01ListModel
            leftImageView!.imageView.sd_setImageWithURL(NSURL(string: leftModel.image!), placeholderImage: UIImage(named: "noDataDefaultIcon"))
            leftImageView?.title.text = leftModel.title
            
            let topModel = array2d[1] as! HDGG01ListModel
            topImageView!.imageView.sd_setImageWithURL(NSURL(string: topModel.image!), placeholderImage: UIImage(named: "noDataDefaultIcon"))
            topImageView?.title.text = topModel.title
            
            let bottomModel = array2d[2] as! HDGG01ListModel
            bottomImageView!.imageView.sd_setImageWithURL(NSURL(string: bottomModel.image!), placeholderImage: UIImage(named: "noDataDefaultIcon"))
            bottomImageView?.title.text = bottomModel.title
            
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
                    make.height.equalTo(3*Constants.kSCREENWITH/5)
                    make.width.equalTo(3*Constants.kSCREENWITH/5)
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
                    make.height.equalTo((3*Constants.kSCREENWITH/5-5)/2)
                    make.width.equalTo(2*Constants.kSCREENWITH/5-30)
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
                    make.height.equalTo((3*Constants.kSCREENWITH/5-5)/2)
                    make.width.equalTo(2*Constants.kSCREENWITH/5-30)
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
                    make.width.equalTo(Constants.kSCREENWITH)
                    make.height.equalTo(Constants.HDSpace)
                    
                })
            }
            
            let array2d = self.hdGG01Response.array2D![indexPath.row]
            
            let rightModel:HDGG01ListModel = array2d[0] as! HDGG01ListModel
            rightImageView!.imageView.sd_setImageWithURL(NSURL(string: rightModel.image!), placeholderImage: UIImage(named: "noDataDefaultIcon"))
            rightImageView?.title.text = rightModel.title
            
            let topModel = array2d[1] as! HDGG01ListModel
            topImageView!.imageView.sd_setImageWithURL(NSURL(string: topModel.image!), placeholderImage: UIImage(named: "noDataDefaultIcon"))
            topImageView?.title.text = topModel.title
            
            let bottomModel = array2d[2] as! HDGG01ListModel
            bottomImageView!.imageView.sd_setImageWithURL(NSURL(string: bottomModel.image!), placeholderImage: UIImage(named: "noDataDefaultIcon"))
            bottomImageView?.title.text = bottomModel.title
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 3*Constants.kSCREENWITH/5+20+10
    }

}
