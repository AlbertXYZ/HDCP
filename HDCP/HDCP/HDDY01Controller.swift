//
//  HDDY01Controller.swift
//  HDCP
//
//  Created by 徐琰璋 on 16/3/30.
//  Copyright © 2016年 batonsoft. All rights reserved.
//

import UIKit

class DYView: UIView {
    
    var index:Int?
    
}

class HDDY01Controller: UITableViewController {
    
    var videoPlayerController:HDVideoPlayerController?
    var dataArray:NSMutableArray!
    var offset:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge.None;
        self.navigationController?.navigationBar.translucent = false
        
        offset = 0
        dataArray  = NSMutableArray()
        
        setupUI()
        showHud()
        doGetRequestData(10,offset: self.offset)
        
        
    }
    
    deinit{
    
        HDLog.LogClassDestory("HDDY01Controller")
        
    }
    
    // MARK: - 创建UI视图
    func setupUI(){
        
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.registerClass(HDHM04Cell.classForCoder(), forCellReuseIdentifier: "myCell")
        self.tableView.backgroundColor = Constants.HDBGViewColor
        
        
        //当列表滚动到底端 视图自动刷新
        unowned let WS = self
        self.tableView?.mj_footer = HDRefreshGifFooter(refreshingBlock: { () -> Void in
            WS.doGetRequestData(10,offset: WS.offset)
        })
    }
    
    
    // MARK: - 提示动画显示和隐藏
    func showHud(){
        
        CoreUtils.showProgressHUD(self.view)
        
    }
    
    func hidenHud(){
        
        CoreUtils.hidProgressHUD(self.view)
    }
    
    
    // MARK: - 计算cell的高度
    func getRowHeight(){
        
        
        if dataArray.count > 0 {
            
            
            for i in 0 ..< dataArray.count {
                
                let model = dataArray[i] as! HDDY01ListModel
                
                let contentStr = String(format: "[%@]%@", model.data!.tagName!,model.data!.content!)
                
                let contentRect = CoreUtils.getTextRectSize(contentStr, font: UIFont.systemFontOfSize(14), size: CGSizeMake(Constants.HDSCREENWITH-100, 9999))
                model.contentHeight = contentRect.size.height;
                
                let row = Int(contentRect.size.height/16)
                
                if row >= 3 {
                    
                    model.contentHeight = 60.0;
                }else if row == 1 {
                    
                    model.contentHeight = 20.0;
                }else if row == 2 {
                    
                    model.contentHeight = 40.0;
                }
                
                if model.data!.commentList?.count>0 {
                    
                    let comment:HDDY01CommentListModel = model.data!.commentList![0]
                    let commentStr = String(format: "%@: %@",comment.userName!,comment.content!)
                    let commentRect = CoreUtils.getTextRectSize(commentStr, font: UIFont.systemFontOfSize(14), size: CGSizeMake(Constants.HDSCREENWITH-110, 9999))
                    let row = Int(commentRect.size.height/16)
                    model.fcommentRow = row
                    model.rowHeight = 365 + model.contentHeight!
                    
                }else{
                    
                    model.rowHeight = 285 + model.contentHeight!
                }
                
            }
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - events
    func commentAction(tap:UITapGestureRecognizer){
        
        
        let view = tap.view as! DYView;
        
        HDLog.LogOut("index", obj: view.index!)
        
        let model = dataArray[view.index!] as! HDDY01ListModel
        
        let hd10VC = HDHM10Controller()
        hd10VC.rid = model.data?.id
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(hd10VC, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    // MARK: - 数据加载
    func doGetRequestData(limit:Int,offset:Int){
        
        unowned let WS = self
        HDDY01Service().doGetRequest_HDDY01_URL(0, offset: 0, successBlock: { (hdResponse) -> Void in
            
            
            WS.offset = WS.offset+10
            
            WS.hidenHud()
            
            WS.dataArray.addObjectsFromArray((hdResponse.result?.list)!)
            
            WS.getRowHeight();
            
            WS.tableView.mj_footer.endRefreshing()
            
            WS.tableView.reloadData()
            
        }) { (error) -> Void in
            
            WS.tableView.mj_footer.endRefreshing()
            CoreUtils.showWarningHUD(WS.view, title: Constants.HD_NO_NET_MSG)
        }
        
    }
    
    
    // MARK: - UITableView delegate/datasource
    
    override func tableView(tableView:UITableView, numberOfRowsInSection section: Int) ->Int
    {
        return self.dataArray.count
    }
    
    override func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) ->UITableViewCell
    {
        let cell = tableView .dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath)
        cell.accessoryType = UITableViewCellAccessoryType.None
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        //头像
        var icon = cell.contentView.viewWithTag(1000) as? UIImageView
        
        if icon == nil {
            
            icon = UIImageView()
            icon?.layer.cornerRadius = 25
            icon?.tag = 1000
            icon?.layer.masksToBounds = true
            cell.contentView.addSubview(icon!)
            
            icon?.snp_makeConstraints(closure: { (make) -> Void in
                
                make.left.equalTo(15)
                make.top.equalTo(10)
                make.width.equalTo(50)
                make.height.equalTo(50)
                
            })
            
        }
        
        //名称
        var name = cell.contentView.viewWithTag(2000) as? UILabel
        
        if name == nil {
            
            name = UILabel()
            name?.textColor = Constants.HDMainTextColor
            name?.adjustsFontSizeToFitWidth=true
            name?.tag = 2000
            name?.font = UIFont.systemFontOfSize(17)
            cell.contentView.addSubview(name!)
            
            name?.snp_makeConstraints(closure: { (make) -> Void in
                
                make.left.equalTo(icon!.snp_right).offset(10)
                make.top.equalTo(cell.contentView).offset(10)
                make.width.equalTo(60)
                make.height.equalTo(20)
                
            })
        }
        
        //是否是VIP用户
        var vip = cell.contentView.viewWithTag(3000) as? UIImageView
        
        if vip == nil {
            
            vip = UIImageView()
            vip?.tag = 3000
            cell.contentView.addSubview(vip!)
            
            vip?.snp_makeConstraints(closure: { (make) -> Void in
                
                make.top.equalTo(10)
                make.left.equalTo(name!.snp_right).offset(10)
                make.width.equalTo(20)
                make.height.equalTo(20)
                
            })
            
        }
        
        //性别
        var sex = cell.contentView.viewWithTag(4000) as? UIImageView
        
        if sex == nil {
            
            sex = UIImageView()
            sex?.tag = 4000
            cell.contentView.addSubview(sex!)
            
            sex?.snp_makeConstraints(closure: { (make) -> Void in
                
                
                make.top.equalTo(10)
                make.left.equalTo(vip!.snp_right).offset(10)
                make.width.equalTo(20)
                make.height.equalTo(20)
            })
            
        }
        
        //菜谱名称
        var title = cell.contentView.viewWithTag(5000) as? UILabel
        
        if title == nil {
            
            title = UILabel()
            title?.tag = 5000
            title?.textColor = Constants.HDMainTextColor
            title?.font = UIFont.systemFontOfSize(15)
            cell.contentView.addSubview(title!)
            
            title?.snp_makeConstraints(closure: { (make) -> Void in
                
                make.top.equalTo(icon!.snp_bottom).offset(5)
                make.left.equalTo(icon!.snp_right).offset(10)
                make.width.equalTo(Constants.HDSCREENWITH - 120)
                make.height.equalTo(20);
                
            })
            
        }
        
        //内容
        
        var content = cell.contentView.viewWithTag(6000) as? UILabel
        
        if content == nil {
            
            content = UILabel()
            content?.tag = 6000
            content?.textColor = Constants.HDMainTextColor
            content?.numberOfLines = 0
            content?.font = UIFont.systemFontOfSize(14)
            cell.contentView.addSubview(content!)
            
            content?.snp_makeConstraints(closure: { (make) -> Void in
                
                make.top.equalTo(title!.snp_bottom).offset(5)
                make.left.equalTo(icon!.snp_right).offset(10)
                make.width.equalTo(Constants.HDSCREENWITH - 100)
                make.height.equalTo(20);
                
            })
            
        }
        //图片
        var imageView = cell.contentView.viewWithTag(7000) as? UIImageView
        
        
        if imageView == nil {
            
            imageView = UIImageView()
            imageView?.tag = 7000
            cell.contentView.addSubview(imageView!)
            imageView?.snp_makeConstraints(closure: { (make) -> Void in
                
                make.top.equalTo(content!.snp_bottom).offset(5)
                make.left.equalTo(icon!.snp_right).offset(10)
                make.height.equalTo(120)
                make.width.equalTo(Constants.HDSCREENWITH - 150)
                
            })
        }
        
        //播放图片
        var playView = imageView!.viewWithTag(7100) as? UIImageView
        
        if playView == nil {
            
            playView = UIImageView()
            playView?.tag = 7100
            playView?.image = UIImage(named: "playIcon")
            imageView!.addSubview(playView!)
            playView?.snp_makeConstraints(closure: { (make) -> Void in
                
                make.top.equalTo(120/2-25)
                make.left.equalTo((Constants.HDSCREENWITH - 150)/2-25)
                make.height.equalTo(50)
                make.width.equalTo(50)
                
            })
        }
        
        //时间
        var time = cell.contentView.viewWithTag(8000) as? UILabel
        
        if time == nil {
            
            time = UILabel()
            time?.tag = 8000
            time?.textColor = Constants.HDMainTextColor
            time?.font = UIFont.systemFontOfSize(14)
            cell.contentView.addSubview(time!)
            
            time?.snp_makeConstraints(closure: { (make) -> Void in
                
                make.top.equalTo(imageView!.snp_bottom).offset(10)
                make.left.equalTo(icon!.snp_right).offset(10)
                make.width.equalTo(Constants.HDSCREENWITH - 220)
                make.height.equalTo(20);
                
            })
            
        }
        
        
        //赞
        var digIcon = cell.contentView.viewWithTag(16000) as? UIImageView
        
        if digIcon == nil {
            
            digIcon = UIImageView()
            digIcon?.tag = 16000
            digIcon?.image = UIImage(named: "zanIcon")
            cell.contentView.addSubview(digIcon!)
            
            digIcon?.snp_makeConstraints(closure: { (make) in
                
                make.top.equalTo(imageView!.snp_bottom).offset(12.5)
                make.left.equalTo(time!.snp_right).offset(0)
                make.width.equalTo(20)
                make.height.equalTo(20)
                
            })
            
        }
        
        var digCount = cell.contentView.viewWithTag(17000) as? UILabel
        
        if digCount == nil {
            
            digCount = UILabel()
            digCount?.tag = 17000
            digCount?.font = UIFont.systemFontOfSize(13)
            digCount?.textColor = Constants.HDMainTextColor
            cell.contentView.addSubview(digCount!)
            digCount?.snp_makeConstraints(closure: { (make) in
                
                make.top.equalTo(imageView!.snp_bottom).offset(12.5)
                make.left.equalTo(digIcon!.snp_right).offset(5)
                make.width.equalTo(35)
                make.height.equalTo(20)
                
            })
        }
        
        //评论
        var commentIcon = cell.contentView.viewWithTag(18000) as? UIImageView
        
        if commentIcon == nil {
            
            commentIcon = UIImageView()
            commentIcon?.tag = 18000
            commentIcon?.image = UIImage(named: "commIcon")
            cell.contentView.addSubview(commentIcon!)
            
            commentIcon?.snp_makeConstraints(closure: { (make) in
                
                make.top.equalTo(imageView!.snp_bottom).offset(12.5)
                make.left.equalTo(digCount!.snp_right).offset(0)
                make.width.equalTo(20)
                make.height.equalTo(20)
                
            })
            
        }
        
        var commentCount = cell.contentView.viewWithTag(19000) as? UILabel
        
        if commentCount == nil {
            
            commentCount = UILabel()
            commentCount?.tag = 19000
            commentCount?.font = UIFont.systemFontOfSize(13)
            commentCount?.textColor = Constants.HDMainTextColor
            cell.contentView.addSubview(commentCount!)
            commentCount?.snp_makeConstraints(closure: { (make) in
                
                make.top.equalTo(imageView!.snp_bottom).offset(12.5)
                make.left.equalTo(commentIcon!.snp_right).offset(5)
                make.width.equalTo(40)
                make.height.equalTo(20)
                
            })
        }
        
        //评论视图
        var commentView = cell.contentView.viewWithTag(9000) as? DYView
        
        if commentView == nil {
            
            commentView = DYView()
            commentView?.tag = 9000
            commentView?.layer.cornerRadius = 5
            commentView?.layer.masksToBounds = true
            commentView?.backgroundColor = CoreUtils.HDColor(249, g: 249, b: 249, a: 1)
            cell.contentView.addSubview(commentView!)
            
            commentView?.snp_makeConstraints(closure: { (make) -> Void in
                
                make.top.equalTo(time!.snp_bottom).offset(15)
                make.left.equalTo(icon!.snp_right).offset(10)
                make.width.equalTo(Constants.HDSCREENWITH - 100)
                make.height.equalTo(80);
                
            })
            
        }
        
        //豆友评论
        var comment = commentView?.viewWithTag(10000) as? UILabel
        
        if comment == nil {
            
            comment = UILabel()
            comment?.tag = 10000
            comment?.textColor = Constants.HDMainTextColor
            comment?.numberOfLines = 0
            comment?.font = UIFont.systemFontOfSize(14)
            commentView!.addSubview(comment!)
            
            comment?.snp_makeConstraints(closure: { (make) -> Void in
                
                make.top.equalTo(5)
                make.left.equalTo(5)
                make.width.equalTo(Constants.HDSCREENWITH - 110)
                make.height.equalTo(40);
                
            })
            
        }
        
        //评论条数
        var commentCnt = commentView?.viewWithTag(11000) as? UILabel
        
        if commentCnt == nil {
            
            commentCnt = UILabel()
            commentCnt?.tag = 11000
            commentCnt?.textColor = Constants.HDMainTextColor
            commentCnt?.font = UIFont.systemFontOfSize(14)
            commentView!.addSubview(commentCnt!)
            
            commentCnt?.snp_makeConstraints(closure: { (make) -> Void in
                
                make.top.equalTo(comment!.snp_bottom).offset(5)
                make.left.equalTo(5)
                make.width.equalTo(Constants.HDSCREENWITH - 110)
                make.height.equalTo(25);
                
            })
            
        }
        
        var spaceView = cell.contentView.viewWithTag(12000)
        
        if spaceView == nil {
            
            spaceView = UIView()
            spaceView?.tag = 12000
            spaceView?.backgroundColor = Constants.HDBGViewColor
            cell.contentView.addSubview(spaceView!)
            spaceView?.snp_makeConstraints(closure: { (make) -> Void in
                
                make.width.equalTo(Constants.HDSCREENWITH)
                make.height.equalTo(Constants.HDSpace)
                make.left.equalTo(0)
                make.bottom.equalTo(0)
                
            })
            
        }
        
        let model = dataArray[indexPath.row] as! HDDY01ListModel
        
        name?.text = model.userInfo?.userName
        
        icon?.sd_setImageWithURL(NSURL(string: (model.userInfo?.avatar)!), placeholderImage: UIImage(named: "defaultIcon"))
        
        title?.text = model.data?.title
        
        if model.data!.tagName!.characters.count > 0 {
            
            content?.text = String(format: "[%@]%@", model.data!.tagName!,model.data!.content!)
        }else{
            content?.text = String(format: "%@", model.data!.content!)
        }
        
        
        imageView?.sd_setImageWithURL(NSURL(string:  (model.data?.img)!), placeholderImage: UIImage(named: "noDataDefaultIcon"))
        
        time?.text = model.data?.createTime
        
        digCount?.text = String(format: "%d", (model.data?.diggCnt)!)
        commentCount?.text = String(format: "%d", (model.data?.commentCnt)!)
        
        if model.data!.commentList?.count>0 {
            
            if model.fcommentRow == 1 {
                
                let commentModel:HDDY01CommentListModel = model.data!.commentList![0]
                let commentModel2:HDDY01CommentListModel = model.data!.commentList![1]
                comment?.text = String(format: "%@: %@ \n%@: %@",commentModel.userName!,commentModel.content!,commentModel2.userName!,commentModel2.content!)
                
            }else{
                
                let commentModel:HDDY01CommentListModel = model.data!.commentList![0]
                comment?.text = String(format: "%@: %@",commentModel.userName!,commentModel.content!)
            }
            
            
            //评论数 字体颜色修改
            let str = String(format: "%d", (model.data?.commentCnt)!)
            let comentStr = String(format: "查看全部%d条评论", (model.data?.commentCnt)!)
            let attributed = NSMutableAttributedString(string: comentStr)
            attributed.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(15), range: NSMakeRange(0, str.characters.count))
            attributed.addAttribute(NSForegroundColorAttributeName, value: CoreUtils.HDColor(245, g: 161, b: 0, a: 1), range: NSMakeRange(4, str.characters.count))
            commentCnt?.attributedText =  attributed
            
        }else{
            
            commentView?.hidden = true
        }
        
        
        if model.userInfo?.vip == 1 {
            
            //是vip用户
            vip?.hidden = false
            vip?.image = UIImage(named: "VIcon")
            
        }else{
            
            vip?.hidden = true
        }
        
        //0:=女 1:男
        if model.userInfo?.gender == 0 {
            
            sex?.image = UIImage(named: "womanIcon")
        }else{
            
            sex?.image = UIImage(named: "manIcon")
        }
        
        if model.data?.hasVideo == 1 {
            
            //是视频
            playView?.hidden = false
        }else{
            
            //是图片
            playView?.hidden = true
        }
        
        content?.snp_updateConstraints(closure: { (make) -> Void in
            
            make.height.equalTo(model.contentHeight!)
        })
        
        imageView?.snp_updateConstraints(closure: { (make) -> Void in
            
            make.top.equalTo(content!.snp_bottom).offset(5)
            
        })
        
        time?.snp_updateConstraints(closure: { (make) -> Void in
            
            make.top.equalTo(imageView!.snp_bottom).offset(15)
            
        })
        
        commentView?.snp_updateConstraints(closure: { (make) -> Void in
            
            make.top.equalTo(time!.snp_bottom).offset(15)
            
        })
        
        commentView?.index = indexPath.row
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(HDDY01Controller.commentAction(_:)))
        commentView?.addGestureRecognizer(tapGes)
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        
        let model = dataArray[indexPath.row] as! HDDY01ListModel
        
        return model.rowHeight!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        HDLog.LogOut(indexPath.row);
        let model = dataArray[indexPath.row] as! HDDY01ListModel
        let hddy02VC = HDDY02Controller()
        hddy02VC.listModel = model
        self.hidesBottomBarWhenPushed = true;
        self.navigationController?.pushViewController(hddy02VC, animated: true)
        self.hidesBottomBarWhenPushed = false;
        
    }
    
}