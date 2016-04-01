//
//  HDHM10Controller.swift
//  HDCP
//
//  Created by 徐琰璋 on 16/3/1.
//  Copyright © 2016年 batonsoft. All rights reserved.
//

import UIKit

class HDHM10Controller: UIViewController,UITableViewDataSource,UITableViewDelegate {

    var tableView:UITableView!
    var putView:UIView!
    var textView:UITextField!
    var commitBtn:UIButton!
    var commentArray = Array<HDHM10Comment>()
    var offset:Int!
    var rid:Int!
    
    //rid=%@&type=0&offset=0&limit=20
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        offset = 0
        
        setupUI()
        showHud()
        doGetRequestData(50,offset: self.offset)
    }
    
    // MARK: - 创建UI视图
    
    func setupUI(){
        
        unowned let WS = self
        
        tableView = UITableView()
        tableView?.delegate = self
        tableView?.dataSource = self
        self.view.addSubview(tableView!)
        
        tableView?.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "myCell")
        tableView.tableFooterView = UIView()
        tableView.frame = CoreUtils.HDFrame(0, y: 0, width: Constants.HDSCREENWITH, height: Constants.HDSCREENHEIGHT-64-50)
        
        tableView.userInteractionEnabled = true
        
        /**
        *   添加点击事件收齐键盘
        */
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        tableView.addGestureRecognizer(tapGes)

        
        putView = UIView()
        putView.backgroundColor = Constants.HDBGViewColor
        self.view.addSubview(putView)
        
        putView.frame = CoreUtils.HDFrame(0, y: Constants.HDSCREENHEIGHT-50-64, width: Constants.HDSCREENWITH, height: 50)
        
        
        /**
        *  分割线
        */
        
        let line = UIView()
        line.frame = CoreUtils.HDFrame(0, y: 0, width: Constants.HDSCREENWITH, height: 1)
        line.backgroundColor = CoreUtils.HDColor(227, g: 227, b: 229, a: 1)
        putView.addSubview(line)
        
        /**
        *  输入框
        */
        
        textView = UITextField()
        textView.placeholder = "说点什么..."
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = Constants.HDMainTextColor.CGColor
        textView.layer.cornerRadius = 5
        textView.backgroundColor = UIColor.whiteColor()
        textView.font = UIFont.systemFontOfSize(15)
        textView.layer.masksToBounds = true
        putView.addSubview(textView)
        
        textView.snp_makeConstraints { (make) -> Void in
            
            make.top.equalTo(WS.putView.snp_top).offset(5)
            make.left.equalTo(WS.putView).offset(15)
            make.width.equalTo(Constants.HDSCREENWITH-15-80)
            make.height.equalTo(40)
            
        }
        
        
        commitBtn = UIButton(type: UIButtonType.Custom)
        commitBtn.setTitle("发送", forState: UIControlState.Normal)
        commitBtn.titleLabel?.font = UIFont.systemFontOfSize(15)
        commitBtn.backgroundColor = Constants.HDMainColor
        commitBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        commitBtn.addTarget(self, action: #selector(sendComment), forControlEvents: UIControlEvents.TouchUpInside)
        commitBtn.layer.cornerRadius = 5
        commitBtn.layer.masksToBounds = true
        putView.addSubview(commitBtn)
        
        commitBtn.snp_makeConstraints { (make) -> Void in
            
            make.left.equalTo(WS.textView.snp_right).offset(10)
            make.top.equalTo(WS.putView.snp_top).offset(5)
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIKeyboardWillChangeFrameNotification , object: nil)
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationItem.leftBarButtonItem = CoreUtils.HDBackBarButtonItem(#selector(backAction), taget: self)
        
      
    }
    
    deinit{
    
        tableView.delegate = nil
        tableView.dataSource = nil
        
        /**
        *  移除通知
        */
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        HDLog.LogClassDestory("HDHM10Controller")
    }
    
    // MARK: - 键盘变化
    func keyboardWillShow(note:NSNotification){
    
        
       let rect =  note.userInfo![UIKeyboardFrameEndUserInfoKey]
        
        let height:CGFloat = (rect?.CGRectValue.height)!
        
        unowned let WS = self
        UIView.animateWithDuration(0.3) { () -> Void in
            
            WS.putView.frame = CoreUtils.HDFrame(0, y: self.view.frame.size.height-height-50, width: Constants.HDSCREENWITH, height: 50)
            WS.tableView.frame = CoreUtils.HDFrame(0, y: 0, width: Constants.HDSCREENWITH, height: Constants.HDSCREENHEIGHT-64-50-height)
            
            
            
            if WS.commentArray.count>0 {
                
                /// cell滚动到底部
                let indexPath = NSIndexPath(forRow: WS.commentArray.count-1, inSection: 0)
                WS.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
            }
            
        }
        
    }
    
    func keyboardWillHide(note:NSNotification){
        
        unowned let WS = self
        UIView.animateWithDuration(0.3) { () -> Void in
            
            WS.putView.frame = CoreUtils.HDFrame(0, y:Constants.HDSCREENHEIGHT-64-50, width: Constants.HDSCREENWITH, height: 50)
            WS.tableView.frame = CoreUtils.HDFrame(0, y: 0, width: Constants.HDSCREENWITH, height: Constants.HDSCREENHEIGHT-64-50)
            
            
            if WS.commentArray.count>0 {
                
                /// cell滚动到底部
                let indexPath = NSIndexPath(forRow: WS.commentArray.count-1, inSection: 0)
                WS.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
            }
            
        }
        
    }
    
    func keyboardWillChange(note:NSNotification){
        
       

        
    }
    
    // MARK: - 提示动画显示和隐藏
    func showHud(){
        
        CoreUtils.showProgressHUD(self.view)
        
    }
    
    func hidenHud(){
        
        CoreUtils.hidProgressHUD(self.view)
    }
    
    // MARK: - 计算文本高度
    
    func getContentHeight(){
    
        for i in 0 ..< commentArray.count {
        
            let rect = CoreUtils.getTextRectSize((commentArray[i].content)!, font: UIFont.systemFontOfSize(15), size: CGSizeMake(Constants.HDSCREENWITH-80, 999))
            commentArray[i].height = rect.height
            
        }
        
    }
    
    
    // MARK: - 数据加载
    func doGetRequestData(limit:Int,offset:Int){
        
        unowned let WS = self
        
        HDHM10Service().doGetRequest_HDHM10_URL(limit, offset: offset,rid: rid, successBlock: { (hm10Response) -> Void in
            
            WS.offset = WS.offset+10
            
            WS.hidenHud()
            
            if hm10Response.result?.list?.count > 0 {
            
                WS.commentArray = (hm10Response.result?.list)!
            }
            
            WS.getContentHeight()
            
            WS.title = String(format: "评论(%d)", WS.commentArray.count)
            
            WS.tableView.reloadData()
            
        }) { (error) -> Void in
            
            WS.tableView.mj_footer.endRefreshing()
            CoreUtils.showWarningHUD(WS.view, title: Constants.HD_NO_NET_MSG)
        }
        
    }

    // MARK: - events
    
    func backAction(){
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    /**
     * 隐藏键盘
     */
    func hideKeyBoard(){
    
        textView.resignFirstResponder()
        
        
    }
    
    /**
     *  发送评论
     */
    func sendComment(){
    
        if textView.text?.characters.count > 0 {
        
            let mutableArray = NSMutableArray(array: commentArray)
            let model = HDHM10Comment()
            model.avatar = ""
            model.content = textView.text
            model.createTime = "刚刚"
            model.userName = "小徐"
            let rect = CoreUtils.getTextRectSize(textView.text!, font: UIFont.systemFontOfSize(15), size: CGSizeMake(Constants.HDSCREENWITH-80, 999))
            model.height = rect.height
            mutableArray.addObject(model)
            commentArray = NSArray(array: mutableArray) as! Array<HDHM10Comment>
            
            tableView.reloadData()
            
            let indexPath = NSIndexPath(forRow: commentArray.count-1, inSection: 0)
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            
            textView.text = ""
            
            self.title = String(format: "评论(%d)", commentArray.count)
            
        }
        
        
    }
    
    // MARK: - UIScrollView delegate
    func tableView(tableView:UITableView, numberOfRowsInSection section: Int) ->Int
    {
        return commentArray.count
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) ->UITableViewCell
    {
        
        let cell = tableView .dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        /**
        *   头像
        */
        
        var icon = cell.contentView.viewWithTag(1000) as? UIImageView
        
        if icon == nil {
        
            icon = UIImageView()
            icon?.tag = 1000
            icon?.layer.cornerRadius = 20
            icon?.layer.masksToBounds = true
            cell.contentView.addSubview(icon!)
            
            icon?.snp_makeConstraints(closure: { (make) -> Void in
                
                make.top.equalTo(cell.contentView).offset(10)
                make.left.equalTo(cell.contentView).offset(15)
                make.width.equalTo(40)
                make.height.equalTo(40)
                
                
            })
            
        }
        
        /**
        *   昵称
        */
         
         var username = cell.contentView.viewWithTag(2000) as? UILabel
        
        if username == nil {
        
            username = UILabel()
            username?.tag = 2000
            username?.font = UIFont.systemFontOfSize(14)
            username?.textColor = Constants.HDMainTextColor
            cell.contentView.addSubview(username!)
            
            username?.snp_makeConstraints(closure: { (make) -> Void in
                
                make.top.equalTo(cell.contentView).offset(12)
                make.left.equalTo(icon!.snp_right).offset(5)
                make.width.equalTo(200)
                make.height.equalTo(20)
            })
            
        }
         
        
        /**
        *   发表时间
        */
         
        var createTime = cell.contentView.viewWithTag(3000) as? UILabel
        
        if createTime == nil {
            
            createTime = UILabel()
            createTime?.tag = 3000
            createTime?.font = UIFont.systemFontOfSize(12)
            createTime?.textColor = Constants.HDMainTextColor
            cell.contentView.addSubview(createTime!)
            
            createTime?.snp_makeConstraints(closure: { (make) -> Void in
                
                make.top.equalTo(username!.snp_bottom).offset(0)
                make.left.equalTo(icon!.snp_right).offset(5)
                make.width.equalTo(200)
                make.height.equalTo(20)
            })
            
        }

        
        /**
        *   内容
        */
        
        var content = cell.contentView.viewWithTag(4000) as? UILabel
        
        if content == nil {
            
            content = UILabel()
            content?.tag = 4000
            content?.font = UIFont.systemFontOfSize(15)
            content?.textColor = Constants.HDMainTextColor
            content?.numberOfLines = 0
            cell.contentView.addSubview(content!)
            
            content?.snp_makeConstraints(closure: { (make) -> Void in
                
                make.top.equalTo(icon!.snp_bottom).offset(5)
                make.left.equalTo(cell.contentView).offset(60)
                make.width.equalTo(Constants.HDSCREENWITH-80)
                make.height.equalTo(20)
            })
            
        }

        
        let model = commentArray[indexPath.row]
        
        icon?.sd_setImageWithURL(NSURL(string: (model.avatar)!), placeholderImage: UIImage(imageLiteral: "defaultIcon"))
        username?.text = model.userName
        createTime?.text = model.createTime
        content?.text = model.content
        
        content?.snp_updateConstraints(closure: { (make) -> Void in
            
            make.height.equalTo(model.height)
            
        })
        
        /**
        *  富文本 - 给名称添加颜色
        */
        if model.content.hasPrefix("@") {
        
            let str:String =  model.content.componentsSeparatedByString(":")[0]
            let attributed = NSMutableAttributedString(string: model.content)
            attributed.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(15), range: NSMakeRange(0, str.characters.count))
            attributed.addAttribute(NSForegroundColorAttributeName, value: CoreUtils.HDColor(245, g: 161, b: 0, a: 1), range: NSMakeRange(0, str.characters.count))
            content?.attributedText =  attributed
        }else{
        
            content?.textColor = Constants.HDMainTextColor
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
        
        let model = commentArray[indexPath.row]
        return 60 + model.height
    }
}
