//
//  HDHM01ViewController.swift
//  HDCP
//
//  Created by 徐琰璋 on 16/1/4.
//  Copyright © 2016年 batonsoft. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import SnapKit

private let HeadViewHeight:CGFloat = 200.0

private let TagHeight:Int = 40

/**
*  resource/数据源
*/
private let resourceArray = [["title":"排行榜","image":"HPHBIcon"],
    ["title":"营养餐桌","image":"HYYCZIcon"],
    ["title":"热门分类","image":"HFBCPIcon"],
    ["title":"晒一晒","image":"HSYSIcon"]]

class HDHM01Controller: BaseViewController,UIScrollViewDelegate {
    
    private enum HDHM01MenuTag: Int {
        case PHB = 0, YYCZ, FBCP, SYS
    }
    
    var baseView:UIScrollView!
    
    /**
     
     *  数据请求结果集
     */
    var hdHM01Response:HDHM01Response?
    
    /**
     *  头部滚动视图
     */
    var headView:UIView!
    var headerSView:UIScrollView!
    
    /**
     *  分页栏
     */
    var pageControl:UIPageControl!
    var headerTitle:UILabel!
    
    /**
     *  标签栏
     */
    var menuView:UIView!
    
    var tagListView:UIView!
    
    /**
     *  菜谱专辑
     */
    var collectListView:UIView!
    
    /**
     *  厨房宝典
     */
    var wikiListView:UIView!
    
    
    /**
     *   UIImageView重用
     */
    var index:Int?
    var centerImageView:UIImageView?
    var leftImageView:UIImageView?
    var rightImageView:UIImageView?
   
   /**
    * 网络变化
    */
   var netStatusView:UILabel?
   
    override func viewDidLoad() {
      
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge.None;
        self.navigationController?.navigationBar.translucent = false
      
        //双击TabItem通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(hm01Notification(_:)), name: Constants.HDREFRESHHDHM01, object: nil)
        
        if HDHM01Service().isExistEntity() {
        
            /**
            *  读取本地数据
            */
            self.hdHM01Response = HDHM01Service().getAllResponseEntity()
            setupUI()
            doGetRequestData()
            
        }else{
        
            if CoreUtils.networkIsReachable() {
                
                showHud()
                doGetRequestData()
                
            }
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        hidenHud()
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        if self.hdHM01Response?.result?.tagList?.count>0 {
            let height:Int = (self.hdHM01Response?.result?.tagList?.count)!/4*TagHeight
            baseView.contentSize = CGSizeMake(Constants.HDSCREENWITH, HeadViewHeight+Constants.HDSCREENWITH/4+5+CGFloat(height)+300+300+CGFloat(Constants.HDSpace*4))
        }
        
    }
   
   deinit{
   
      baseView.delegate = nil
      HDLog.LogClassDestory("HDHM01Controller")
   }
    
    // MARK: - 创建UI视图
    
    func setupUI(){
        
        createBaseView()
        
        createHeaderView()
        
        createMenuView()
        
        createTagListView()
        
        createCollectListView()
        
        createWikiListView()
      
        createNetStatusView()
      
    }
   
   func createNetStatusView() {
      
      if netStatusView == nil {
         
         netStatusView = UILabel()
         netStatusView?.backgroundColor = UIColor(red: 0.88, green: 0.27, blue: 0.28, alpha: 0.8)
         netStatusView?.textColor = UIColor.whiteColor()
         netStatusView?.text = "当前网络不可以，请检查网络设置"
         netStatusView?.font = UIFont.systemFontOfSize(15)
         netStatusView?.textAlignment = NSTextAlignment.Center
         netStatusView?.hidden = true
         self.view.addSubview(netStatusView!)
         
         netStatusView?.snp_makeConstraints(closure: { (make) in
            
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
            make.height.equalTo(40);
            
         })
         
      }
      
   }
    
    /**
     *  创建滚动容器
     */
    func createBaseView(){
    
        unowned let WS = self;
      
        if baseView == nil {
            
            baseView = UIScrollView()
            
            self.view.addSubview(baseView)
            
            baseView.snp_makeConstraints { (make) -> Void in
                
                make.top.equalTo(WS.view).offset(0)
                make.left.equalTo(WS.view).offset(0)
                make.width.equalTo(Constants.HDSCREENWITH)
                make.bottom.equalTo(WS.view).offset(0)
            }
            
            /**
            *  添加下拉刷新
            */
         
            baseView.mj_header = HDRefreshGifHeader(refreshingBlock: { () -> Void in
                
                WS.doGetRequestData()
                
                
            })
            
        }
        
    }
    
    /**
     *  创建头部滚动视图
     */
    func createHeaderView(){
        
        
        /**
        *  创建容器
        */
        
        if headView == nil {
            
            headView = UIView()
            baseView.addSubview(headView)
            
            headView.snp_makeConstraints(closure: { (make) -> Void in
                
                make.top.equalTo(baseView).offset(0)
                make.left.equalTo(baseView).offset(0)
                make.width.equalTo(Constants.HDSCREENWITH)
                make.height.equalTo(HeadViewHeight)
                
            })
            
        }
        

        if self.hdHM01Response?.result?.recipeList?.count > 0 {
            
            if headerSView == nil {
                
                headerSView = UIScrollView()
                headerSView.pagingEnabled = true
                headerSView.userInteractionEnabled = true;
                headerSView.delegate = self;
                headerSView.bounces = false
                headerSView.showsVerticalScrollIndicator = false;
                headerSView.showsHorizontalScrollIndicator = false;
                headView.addSubview(headerSView)
                
                headerSView.snp_makeConstraints(closure: { (make) -> Void in
                    
                    make.top.equalTo(headView).offset(0)
                    make.left.equalTo(headView).offset(0)
                    make.width.equalTo(Constants.HDSCREENWITH)
                    make.height.equalTo(HeadViewHeight)
                    
                    
                })
            }
            
            headerSView?.contentSize = CGSizeMake(CGFloat(3)*Constants.HDSCREENWITH, HeadViewHeight)
            headerSView!.contentOffset = CGPointMake(Constants.HDSCREENWITH,0)
            
            
            centerImageView = UIImageView(frame: CGRectMake(Constants.HDSCREENWITH,0,Constants.HDSCREENWITH,HeadViewHeight))
            centerImageView!.contentMode = UIViewContentMode.ScaleToFill;
            centerImageView?.userInteractionEnabled = true
            headerSView?.addSubview(centerImageView!)
            let ctapGes:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headGesAction(_:)))
            centerImageView?.addGestureRecognizer(ctapGes)
            
            
            leftImageView = UIImageView(frame: CGRectMake(0,0,Constants.HDSCREENWITH,HeadViewHeight))
            leftImageView!.contentMode = UIViewContentMode.ScaleToFill;
            leftImageView?.userInteractionEnabled = true
            headerSView?.addSubview(leftImageView!)
            let ltapGes:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headGesAction(_:)))
            centerImageView?.addGestureRecognizer(ltapGes)
            
            rightImageView = UIImageView(frame: CGRectMake(Constants.HDSCREENWITH*2,0,Constants.HDSCREENWITH,HeadViewHeight))
            rightImageView!.contentMode = UIViewContentMode.ScaleToFill;
            rightImageView?.userInteractionEnabled = true
            headerSView?.addSubview(rightImageView!)
            let rtapGes:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headGesAction(_:)))
            centerImageView?.addGestureRecognizer(rtapGes)
            
            
            /**
            *  分页栏
            */
            
            if pageControl == nil {
                
                pageControl = UIPageControl()
                pageControl?.addTarget(self, action: #selector(pageAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                pageControl?.numberOfPages = 3;
                pageControl?.currentPage = 0;
                pageControl?.pageIndicatorTintColor = Constants.HDMainColor
                headView.addSubview(pageControl!)
                
                pageControl.snp_makeConstraints(closure: { (make) -> Void in
                    
                    make.bottom.equalTo(0)
                    make.right.equalTo(0)
                    make.width.equalTo(100)
                    make.height.equalTo(40)
                    
                })
                
            }
            
            
            
            /**
            *  菜粕名称
            */
            
            if headerTitle == nil {
                
                headerTitle = UILabel()
                headerTitle.font = UIFont.systemFontOfSize(18)
                headerTitle.textColor = Constants.HDMainColor
                headView.addSubview(headerTitle)
                
                headerTitle.snp_makeConstraints(closure: { (make) -> Void in
                    
                    make.bottom.equalTo(0)
                    make.left.equalTo(20)
                    make.width.equalTo(Constants.HDSCREENWITH-150)
                    make.height.equalTo(40)
                    
                })
                
                
            }
            
            
            index = 0;
            setInfoByCurrentImageIndex(index!)
            
        }
        
    }
    
    /**
     *  标签
     */
    func createMenuView(){
        
        
        if menuView == nil {
            
            menuView = UIView()
            menuView.backgroundColor = UIColor.whiteColor()
            baseView.addSubview(menuView)
            
            menuView.snp_makeConstraints { (make) -> Void in
                
                make.top.equalTo(headView.snp_bottom).offset(0)
                make.left.equalTo(baseView).offset(0)
                make.width.equalTo(Constants.HDSCREENWITH)
                make.height.equalTo(Constants.HDSCREENWITH/4+5)
                
            }
            
        }
        
        
        for  i in 0 ..< resourceArray.count {
            
            var btn:HDHM01Button?
            
            btn = menuView.viewWithTag(i+300) as? HDHM01Button
            
            if btn == nil {
                
                btn = HDHM01Button()
                btn!.tag = i+300
                btn!.setImage(UIImage(named: resourceArray[i]["image"]!), forState: UIControlState.Normal)
                btn!.setTitle(resourceArray[i]["title"]!, forState: UIControlState.Normal)
                btn!.titleLabel?.font = UIFont.systemFontOfSize(15)
                btn!.titleLabel?.textAlignment = NSTextAlignment.Center
                btn!.setTitleColor(Constants.HDMainTextColor, forState: UIControlState.Normal)
                btn!.addTarget(self, action: #selector(menuBtnOnclick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                menuView.addSubview(btn!)
                
                btn!.snp_makeConstraints { (make) -> Void in
                    
                    make.left.equalTo(menuView).offset(CGFloat(i)*Constants.HDSCREENWITH/4)
                    make.top.equalTo(menuView).offset(0)
                    make.width.equalTo(Constants.HDSCREENWITH/4)
                    make.height.equalTo(Constants.HDSCREENWITH/4)
                    
                }
                
            }
            
        }
        
    }
    
    
    /**
     *  按钮
     */
    func createTagListView(){
        
        if tagListView == nil {
            
            tagListView = UIView()
            tagListView.backgroundColor = UIColor.whiteColor()
            baseView.addSubview(tagListView)
            
            tagListView.snp_makeConstraints { (make) -> Void in
                
                make.top.equalTo(menuView.snp_bottom).offset(Constants.HDSpace)
                make.left.equalTo(baseView).offset(0)
                make.width.equalTo(Constants.HDSCREENWITH)
                make.height.equalTo((self.hdHM01Response?.result?.tagList?.count)!/4*TagHeight)
                
            }
            
        }
        
        /**
         *  几行4列
         */
        
        var index = 0
        for i in 0 ..< (self.hdHM01Response?.result?.tagList?.count)!/4 {
            
            for j in 0 ..< 4 {
                
                let model:TagListModel = (self.hdHM01Response?.result?.tagList![index])!
               
                var btn:UIButton?
                
                btn = tagListView.viewWithTag(index) as? UIButton
                
                if btn == nil {
                    
                    btn = UIButton()
                    btn!.backgroundColor = UIColor.whiteColor()
                    btn!.setTitleColor(Constants.HDMainTextColor, forState: UIControlState.Normal)
                    btn!.tag = index+1000;
                    btn!.titleLabel?.font = UIFont.systemFontOfSize(15)
                    btn!.setTitle(model.name, forState: UIControlState.Normal)
                    btn!.layer.borderWidth = 0.5
                    btn!.layer.borderColor = Constants.HDBGViewColor.CGColor
                    btn!.addTarget(self, action: #selector(tagBtnOnclick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                    tagListView.addSubview(btn!)
                    
                    btn!.snp_makeConstraints(closure: { (make) -> Void in
                        
                        make.width.equalTo(Constants.HDSCREENWITH/4)
                        make.height.equalTo(TagHeight)
                        make.left.equalTo(CGFloat(j)*Constants.HDSCREENWITH/4)
                        make.top.equalTo(i*TagHeight)
                        
                    })
                    
                }
                
                index += 1;
            }
            
        }
        
    }
    
    /**
     *  菜谱专辑
     */
    func createCollectListView(){
        
        
        if  collectListView == nil {
            
            collectListView = UIView()
            collectListView.backgroundColor = UIColor.whiteColor()
            baseView.addSubview(collectListView)
            
            collectListView.snp_makeConstraints { (make) -> Void in
                
                make.top.equalTo(tagListView.snp_bottom).offset(Constants.HDSpace)
                make.left.equalTo(baseView).offset(0)
                make.width.equalTo(Constants.HDSCREENWITH)
                make.height.equalTo(300)
                
            }
            
            let title = UILabel()
            title.backgroundColor = UIColor.clearColor()
            title.textColor = Constants.HDMainColor
            title.text = "菜谱专辑"
            collectListView.addSubview(title)
            
            title.snp_makeConstraints { (make) -> Void in
                
                make.left.equalTo(collectListView).offset(16)
                make.top.equalTo(collectListView).offset(0)
                make.width.equalTo(Constants.HDSCREENWITH-16)
                make.height.equalTo(40)
                
            }
            
            
            let line = UILabel()
            line.backgroundColor = Constants.HDBGViewColor
            collectListView.addSubview(line)
            
            line.snp_makeConstraints { (make) -> Void in
                
                
                make.left.equalTo(collectListView).offset(16)
                make.top.equalTo(collectListView).offset(260)
                make.width.equalTo(Constants.HDSCREENWITH-16)
                make.height.equalTo(1)
                
            }
            
            let collectmore = UILabel()
            collectmore.backgroundColor = UIColor.clearColor()
            collectmore.textColor = Constants.HDMainTextColor
            collectmore.font = UIFont.systemFontOfSize(16)
            collectmore.text = "查看全部菜谱"
            collectListView.addSubview(collectmore)
            
            collectmore.snp_makeConstraints { (make) -> Void in
                
                make.left.equalTo(collectListView).offset(16)
                make.top.equalTo(line).offset(0)
                make.width.equalTo(Constants.HDSCREENWITH-16)
                make.height.equalTo(40)
                
            }
            
            let moreArrow = UIImageView()
            moreArrow.image = UIImage(named: "moreArrowIcon")
            collectListView.addSubview(moreArrow)
            moreArrow.snp_makeConstraints(closure: { (make) -> Void in
                
                make.right.equalTo(collectListView).offset(-16)
                make.top.equalTo(line).offset(10)
                make.width.equalTo(20)
                make.height.equalTo(20)
                
            })
            
            //添加点击Button
            let onclickBtn = UIButton()
            onclickBtn.tag = 10000
            onclickBtn.backgroundColor = UIColor.clearColor()
            collectListView.addSubview(onclickBtn)
            onclickBtn.addTarget(self, action: #selector(moreAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            onclickBtn.snp_makeConstraints(closure: { (make) -> Void in
                
                make.left.equalTo(collectListView).offset(0)
                make.top.equalTo(line).offset(0)
                make.width.equalTo(Constants.HDSCREENWITH)
                make.height.equalTo(40)
                
            })
            
            
        }
        
        for i in 0 ..< (self.hdHM01Response?.result?.collectList?.count)! {
            
            let model = self.hdHM01Response?.result?.collectList?[i]
            
            var rowView:HDHM01RowView?
            rowView = collectListView.viewWithTag(i+100) as? HDHM01RowView
            
            if  rowView == nil {
               
                rowView = HDHM01RowView()
                rowView!.tag = i+100;
                collectListView.addSubview(rowView!)
                
                let collectGes =  UITapGestureRecognizer(target: self, action: #selector(collectGesAction(_:)))
                rowView!.addGestureRecognizer(collectGes)
                
                rowView!.title.text = model?.title
                rowView?.title.textColor = Constants.HDMainTextColor
                rowView!.userName.text = String(format: "by %@",(model?.userName)!)
                rowView!.detail.text = model?.content
                
                rowView!.snp_makeConstraints { (make) -> Void in
                    
                    make.left.equalTo(collectListView).offset(16)
                    make.top.equalTo(collectListView).offset(i*110+40)
                    make.width.equalTo(Constants.HDSCREENWITH-36)
                    make.height.equalTo(100)
                }
                
                
            }
         
            let image:UIImage? = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(model!.cover!)
            if let _ = image {
               rowView!.imageView.image = image
            }else{
               rowView!.imageView.sd_setImageWithURL(NSURL(string: model!.cover!), placeholderImage: UIImage(named: "noDataDefaultIcon"), completed: { (image, error, type, url) -> Void in
                  //保存图片，并保存到物理存储上
                  SDImageCache.sharedImageCache().storeImage(image, forKey: model!.cover!, toDisk: true)
               })
            }
         
        }
        
    }
    
    /**
     *  厨房宝典
     */
    func createWikiListView(){
        
        if wikiListView == nil {
            
            wikiListView = UIView()
            wikiListView.backgroundColor = UIColor.whiteColor()
            baseView.addSubview(wikiListView)
            
            wikiListView.snp_makeConstraints { (make) -> Void in
                
                make.top.equalTo(collectListView.snp_bottom).offset(Constants.HDSpace)
                make.left.equalTo(baseView).offset(0)
                make.width.equalTo(Constants.HDSCREENWITH)
                make.height.equalTo(300)
                
            }
            
            let title = UILabel()
            title.backgroundColor = UIColor.clearColor()
            title.textColor = Constants.HDMainColor
            title.text = "厨房宝典"
            wikiListView.addSubview(title)
            
            title.snp_makeConstraints { (make) -> Void in
                
                make.left.equalTo(wikiListView).offset(16)
                make.top.equalTo(wikiListView).offset(0)
                make.width.equalTo(Constants.HDSCREENWITH-16)
                make.height.equalTo(40)
                
            }
            
            let line = UILabel()
            line.backgroundColor = Constants.HDBGViewColor
            wikiListView.addSubview(line)
            
            line.snp_makeConstraints { (make) -> Void in
                
                
                make.left.equalTo(wikiListView).offset(16)
                make.top.equalTo(wikiListView).offset(260)
                make.width.equalTo(Constants.HDSCREENWITH-16)
                make.height.equalTo(1)
                
            }
            
            
            let wikimore = UILabel()
            wikimore.backgroundColor = UIColor.clearColor()
            wikimore.textColor = Constants.HDMainTextColor
            wikimore.font = UIFont.systemFontOfSize(16)
            wikimore.text = "查看全部宝典"
            wikiListView.addSubview(wikimore)
            
            wikimore.snp_makeConstraints { (make) -> Void in
                
                make.left.equalTo(wikiListView).offset(16)
                make.top.equalTo(line).offset(0)
                make.width.equalTo(Constants.HDSCREENWITH-16)
                make.height.equalTo(40)
                
            }
            
            let moreArrow = UIImageView()
            moreArrow.image = UIImage(named: "moreArrowIcon")
            wikiListView.addSubview(moreArrow)
            moreArrow.snp_makeConstraints(closure: { (make) -> Void in
                
                make.right.equalTo(collectListView).offset(-16)
                make.top.equalTo(line).offset(10)
                make.width.equalTo(20)
                make.height.equalTo(20)
                
            })
            
            //添加点击Button
            let onclickBtn = UIButton()
            onclickBtn.tag = 20000
            onclickBtn.backgroundColor = UIColor.clearColor()
            wikiListView.addSubview(onclickBtn)
            onclickBtn.addTarget(self, action: #selector(moreAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            onclickBtn.snp_makeConstraints(closure: { (make) -> Void in
                
                make.left.equalTo(collectListView).offset(0)
                make.top.equalTo(line).offset(0)
                make.width.equalTo(Constants.HDSCREENWITH)
                make.height.equalTo(40)
                
            })
            
        }
        
        
        for i in 0 ..< (self.hdHM01Response?.result?.wikiList?.count)! {
            
            let model = self.hdHM01Response?.result?.wikiList?[i]
         
            var rowView:HDHM01RowView?
            rowView = wikiListView.viewWithTag(i+100) as? HDHM01RowView
            
            if  rowView == nil {
                
                rowView = HDHM01RowView()
                rowView!.tag = i+100;
                wikiListView.addSubview(rowView!)
                
                let wikiGes =  UITapGestureRecognizer(target: self, action: #selector(wikiGesAction(_:)))
                rowView!.addGestureRecognizer(wikiGes)
                
                rowView!.title.text = model?.title
                rowView!.title.textColor = Constants.HDMainTextColor

               if model?.userName != nil {
                  rowView!.userName.text = String(format: "by %@",(model?.userName)!)
               }
               
                rowView!.detail.text = model?.content
                
                rowView!.snp_makeConstraints { (make) -> Void in
                    
                    make.left.equalTo(wikiListView).offset(16)
                    make.top.equalTo(wikiListView).offset(i*110+40)
                    make.width.equalTo(Constants.HDSCREENWITH-36)
                    make.height.equalTo(100)
                }
                
                
            }
         
            let image:UIImage? = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(model!.cover!)
            if let _ = image {
               rowView!.imageView.image = image
            }else{
               rowView!.imageView.sd_setImageWithURL(NSURL(string: model!.cover!), placeholderImage: UIImage(named: "noDataDefaultIcon"), completed: { (image, error, type, url) -> Void in
                  //保存图片，并保存到物理存储上
                  SDImageCache.sharedImageCache().storeImage(image, forKey: model!.cover!, toDisk: true)
               })
            }
            
        }
        
        
    }
    // MARK: - 通知事件
   
   func hm01Notification(noti:NSNotification){
   
      let flag = noti.userInfo!["FLAG"] as? String
      
      if flag == Constants.HDREFRESHHDHM01 {
      
         /**
         *  开始刷新 获取最新数据
         */
         self.baseView.mj_header.beginRefreshing()
         
      }
      
      if flag == "NETCHANGE" {
         
         self.showNetView()
         
         self.performSelector(#selector(hideNetView), withObject: self, afterDelay: 2.5)
         
      }
      
   }
    
    // MARK: - 图片循环滚动
    func loadImage(){
        
        
        if headerSView!.contentOffset.x>Constants.HDSCREENWITH {
            
            //向左滑动
            index = (index!+1+(self.hdHM01Response?.result?.recipeList?.count)!)%(self.hdHM01Response?.result?.recipeList?.count)!
            
        }else if headerSView!.contentOffset.x<Constants.HDSCREENWITH{
            
            //向右滑动
            index = (index!-1+(self.hdHM01Response?.result?.recipeList?.count)!)%(self.hdHM01Response?.result?.recipeList?.count)!
        }
        
        setInfoByCurrentImageIndex(index!)
        
        
    }
    
    func setInfoByCurrentImageIndex(index:Int){
        
        let cmodel = self.hdHM01Response?.result?.recipeList?[index]
        
        /// 文本信息
        pageControl?.currentPage = index
        /**
        *  更新菜谱名称
        */
        headerTitle.text = cmodel!.title
      
        let Cimage:UIImage? = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(cmodel?.cover!)
        if let _ = Cimage {
            centerImageView!.image = Cimage
        }else{
            centerImageView!.sd_setImageWithURL(NSURL(string: (cmodel?.cover!)!), placeholderImage: UIImage(named: "noDataDefaultIcon"), completed: { (image, error, type, url) -> Void in
               //保存图片，并保存到物理存储上
               SDImageCache.sharedImageCache().storeImage(image, forKey: cmodel!.cover!, toDisk: true)
            })
        }
      
        let lmodel = self.hdHM01Response?.result?.recipeList![((index-1)+(self.hdHM01Response?.result?.recipeList?.count)!)%(self.hdHM01Response?.result?.recipeList?.count)!]
      
        let Limage:UIImage? = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(lmodel?.cover!)
        if let _ = Limage {
            leftImageView!.image = Limage
        }else{
            leftImageView!.sd_setImageWithURL(NSURL(string: (lmodel?.cover!)!), placeholderImage: UIImage(named: "noDataDefaultIcon"), completed: { (image, error, type, url) -> Void in
               //保存图片，并保存到物理存储上
               SDImageCache.sharedImageCache().storeImage(image, forKey: lmodel!.cover!, toDisk: true)
            })
        }
      
        let rmodel = self.hdHM01Response?.result?.recipeList![((index+1)+(self.hdHM01Response?.result?.recipeList?.count)!)%(self.hdHM01Response?.result?.recipeList?.count)!]
      
        let Rimage:UIImage? = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(rmodel?.cover!)
        if let _ = Rimage {
            rightImageView!.image = Rimage
        }else{
            rightImageView!.sd_setImageWithURL(NSURL(string: (rmodel?.cover!)!), placeholderImage: UIImage(named: "noDataDefaultIcon"), completed: { (image, error, type, url) -> Void in
               //保存图片，并保存到物理存储上
               SDImageCache.sharedImageCache().storeImage(image, forKey: rmodel!.cover!, toDisk: true)
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
   
    func showNetView() {
      
       netStatusView?.hidden = false
      
    }
    func hideNetView() {
      
       netStatusView?.hidden = true
    }
    
    // MARK: - 数据加载
    
    func doGetRequestData(){
      
         unowned let WS = self;
         HDHM01Service().doGetRequest_HDHM01_URL({ (hdResponse) -> Void in
            
            WS.hidenHud()
            
            WS.hdHM01Response = hdResponse
            
            /**
            *  刷新UI
            */
            WS.setupUI()
            
            /**
            *  结束刷新
            */
            WS.baseView.mj_header.endRefreshing()
            
            }) { (error) -> Void in
                
                /**
                *  结束刷新
                */
                if  (WS.baseView != nil) {
                    
                    WS.baseView.mj_header.endRefreshing()
                    
                }
                
                
                CoreUtils.showWarningHUD(WS.view, title: Constants.HD_NO_NET_MSG)
        }
        
        
    }
    
    // MARK: - events
    
    /**
    *   菜谱列表
    */
    func collectGesAction(ges:UITapGestureRecognizer){
        
        let view = ges.view as! HDHM01RowView
        let model = self.hdHM01Response?.result?.collectList?[view.tag-100]
        
        let hdhm05VC = HDHM05Controller()
        hdhm05VC.name = model?.title
        hdhm05VC.cid = model?.cid
        self.hidesBottomBarWhenPushed = true;
        self.navigationController?.pushViewController(hdhm05VC, animated: true)
        self.hidesBottomBarWhenPushed = false;
        
    }
    
    
    /**
     *   厨房宝典详情
     */
    func wikiGesAction(ges:UITapGestureRecognizer){
        
        let view = ges.view as! HDHM01RowView
        let model = self.hdHM01Response?.result?.wikiList?[view.tag-100]
        
        let hdWebVC = HDWebController()
        self.hidesBottomBarWhenPushed = true;
        hdWebVC.name = model!.title
        hdWebVC.url = model!.url
        self.navigationController?.pushViewController(hdWebVC, animated: true)
        self.hidesBottomBarWhenPushed = false;
        
    }
    
    /**
     *   菜谱详情
     */
    func headGesAction(ges:UITapGestureRecognizer){
        
        let recopeMddel:RecipeListModel = (self.hdHM01Response?.result?.recipeList![index!])!
        let hdHM08VC = HDHM08Controller()
        hdHM08VC.rid = recopeMddel.rid
        hdHM08VC.name = recopeMddel.title
        self.hidesBottomBarWhenPushed = true;
        self.navigationController?.pushViewController(hdHM08VC, animated: true)
        self.hidesBottomBarWhenPushed = false;
        
    }
    
    func menuBtnOnclick(btn:UIButton){
        
        let tag:Int = btn.tag - 300
        switch tag {
            
        case 0:
            /**
            *   排行榜
            */
            
            let hdHM02VC = HDHM02Controller()
            self.hidesBottomBarWhenPushed = true;
            self.navigationController?.pushViewController(hdHM02VC, animated: true)
            self.hidesBottomBarWhenPushed = false;
            HDLog.LogOut("排行榜")
            break
        case 1:
            /**
            *   营养餐桌
            */
            
            let hdHM03VC = HDHM03Controller()
            self.hidesBottomBarWhenPushed = true;
            self.navigationController?.pushViewController(hdHM03VC, animated: true)
            self.hidesBottomBarWhenPushed = false;
            HDLog.LogOut("营养餐桌")
            break
            
        case 2:
            /**
            *  热门分类
            */
            
            let hdcg02VC = HDCG02Controller()
            hdcg02VC.name = "热门分类"
            self.hidesBottomBarWhenPushed = true;
            self.navigationController?.pushViewController(hdcg02VC, animated: true)
            self.hidesBottomBarWhenPushed = false;
            HDLog.LogOut("热门分类")
            break
            
        case 3:
            /**
            *   晒一晒
            */
            HDLog.LogOut("晒一晒")
            break
        default:
            "default"
        }
        
        
    }
    
    //更多
    
    func moreAction(btn:UIButton){
        
        switch(btn.tag){
            
        case 10000:
            
            let hdHM06VC = HDHM06Controller()
            self.hidesBottomBarWhenPushed = true;
            self.navigationController?.pushViewController(hdHM06VC, animated: true)
            self.hidesBottomBarWhenPushed = false;
            HDLog.LogOut("全部菜谱")
            break
        case 20000:
            
            let hdHM07VC = HDHM07Controller()
            self.hidesBottomBarWhenPushed = true;
            self.navigationController?.pushViewController(hdHM07VC, animated: true)
            self.hidesBottomBarWhenPushed = false;
            HDLog.LogOut("全部宝典")
            break
        default:
            "default"
        }
        
    }
    
    //分类
    func tagBtnOnclick(btn:UIButton){
        
        let model:TagListModel = (self.hdHM01Response?.result?.tagList![btn.tag-1000])!
        let hdHM04VC = HDHM04Controller()
        hdHM04VC.tagModel = model;
        self.hidesBottomBarWhenPushed = true;
        self.navigationController?.pushViewController(hdHM04VC, animated: true)
        self.hidesBottomBarWhenPushed = false;
        
    }
    
    func pageAction(sender:AnyObject){
        
        
        headerSView!.contentOffset = CGPointMake(Constants.HDSCREENWITH,0)
        index = pageControl?.currentPage
        loadImage()
    }
    
    // MARK: - UIScrollView delegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        loadImage()
        headerSView!.contentOffset = CGPointMake(Constants.HDSCREENWITH,0)
        
        //        pageControl?.currentPage = index
    }
    
}
