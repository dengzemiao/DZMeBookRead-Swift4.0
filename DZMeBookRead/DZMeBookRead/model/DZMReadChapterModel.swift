//
//  DZMReadChapterModel.swift
//  DZMeBookRead
//
//  Created by 邓泽淼 on 2017/5/12.
//  Copyright © 2017年 DZM. All rights reserved.
//

import UIKit

class DZMReadChapterModel: NSObject,NSCoding {
    
    /// 小说ID
    var bookID:String!
    
    /// 章节ID
    var id:String!
    
    /// 上一章 章节ID
    var lastChapterId:String?
    
    /// 下一章：章节ID
    var nextChapterId:String?
    
    /// 章节名称
    var name:String!
    
    /// 完整章节名称
    var fullName:String! { return DZMContentTitle(name) }
    
    /// 内容
    var content:String!
    
    /// 完整内容
    var fullContent:String! { return fullName + content }
    
    /// 优先级 (一般章节段落都带有排序的优先级 从 0 开始)
    var priority:NSNumber!
    
    /// 本章有多少页
    var pageCount:NSNumber = NSNumber(value: 0)
    
    /// 分页数据
    var pageModels:[DZMReadPageModel] = []
    
    
    // MARK: -- 更新字体
    
    /// 记录该章使用的字体属性
    private var readAttribute:[NSAttributedStringKey:Any] = [:]
    private var nameAttribute:[NSAttributedStringKey:Any] = [:]
    
    /// 更新字体
    func updateFont(isSave:Bool = false) {
        
        let nameAttribute = DZMReadConfigure.shared().readAttribute(isPaging: true, isTitle: true)
        
        let readAttribute = DZMReadConfigure.shared().readAttribute(isPaging: true, isTitle: false)
        
        if !NSDictionary(dictionary: self.readAttribute).isEqual(to: readAttribute) || !NSDictionary(dictionary: self.nameAttribute).isEqual(to: nameAttribute) {
            
            self.nameAttribute = nameAttribute
            
            self.readAttribute = readAttribute
            
            pageModels = DZMReadParser.ParserPageModels(attrString: fullContentAttrString(), rect: GetReadViewFrame())
            
            pageCount = NSNumber(value: pageModels.count)
            
            if isSave {save()}
        }
    }
    
    /// 完整内容排版
    func fullContentAttrString() ->NSMutableAttributedString {
        
        let nameAttribute = DZMReadConfigure.shared().readAttribute(isPaging: true, isTitle: true)
        
        let readAttribute = DZMReadConfigure.shared().readAttribute(isPaging: true, isTitle: false)
        
        let nameString = NSMutableAttributedString(string: fullName, attributes: nameAttribute)
        
        let attrString = NSMutableAttributedString(string: content, attributes: readAttribute)
        
        nameString.append(attrString)
        
        return nameString
    }
    
    // MARK: -- init
    
    override init() {
        
        super.init()
    }
    
    /// 通过书ID 章节ID 获得阅读章节 没有则创建传出
    class func readChapterModel(bookID:String, chapterID:String, isUpdateFont:Bool = false) ->DZMReadChapterModel {
        
        var readChapterModel:DZMReadChapterModel!
        
        if DZMReadChapterModel.IsExistReadChapterModel(bookID: bookID, chapterID: chapterID) { // 存在
            
            readChapterModel = ReadKeyedUnarchiver(folderName: bookID, fileName: chapterID) as? DZMReadChapterModel
            
            if isUpdateFont {readChapterModel.updateFont(isSave: true)}
            
        }else{ // 不存在
            
            readChapterModel = DZMReadChapterModel()
            
            readChapterModel.bookID = bookID
            
            readChapterModel.id = chapterID
        }
        
        return readChapterModel
    }
    
    // MARK: -- 操作
    
    /// 通过 Page 获得当页字符串
    func contentString(page:NSInteger) ->String {
        
        return fullContent.substring(pageModels[page].range)
    }
    
    /// 通过 Page 获得当页字符串
    func contentAttributedString(page:NSInteger) ->NSAttributedString {
        
        return pageModels[page].content
    }
    
    /// 通过 Page 获得 Location
    func location(page:NSInteger) ->NSInteger {
        
        return pageModels[page].range.location
    }
    
    /// 获取指定页码的末尾坐标
    func location_last(page:NSInteger) ->NSInteger {
        
        let range = pageModels[page].range!
        
        return range.location + range.length
    }
    
    /// 通过 Page 获得 CenterLocation
    func centerLocation(page:NSInteger) ->NSInteger {
        
        let range = pageModels[page].range!
        
        return range.location + (range.location + range.length) / 2
    }
    
    /// 通过 Location 获得 Page
    func page(location:NSInteger) ->NSInteger {
        
        let count = pageModels.count
        
        for i in 0..<count {
            
            let range = pageModels[i].range!
            
            if location < (range.location + range.length) {
                
                return i
            }
        }
        
        return 0
    }
    
    /// 保存
    func save() {
        
        ReadKeyedArchiver(folderName: bookID, fileName: id, object: self)
    }
    
    /// 是否存在章节内容模型
    class func IsExistReadChapterModel(bookID:String, chapterID:String) ->Bool {
        
        return ReadKeyedIsExistArchiver(folderName: bookID, fileName: chapterID)
    }
    
    // MARK: -- NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init()
        
        bookID = aDecoder.decodeObject(forKey: "bookID") as? String
        
        id = aDecoder.decodeObject(forKey: "id") as? String
        
        lastChapterId = aDecoder.decodeObject(forKey: "lastChapterId") as? String
        
        nextChapterId = aDecoder.decodeObject(forKey: "nextChapterId") as? String
        
        name = aDecoder.decodeObject(forKey: "name") as? String
        
        priority = aDecoder.decodeObject(forKey: "priority") as? NSNumber
        
        content = aDecoder.decodeObject(forKey: "content") as? String
        
        pageCount = aDecoder.decodeObject(forKey: "pageCount") as! NSNumber
        
        pageModels = aDecoder.decodeObject(forKey: "pageModels") as! [DZMReadPageModel]
        
        readAttribute = aDecoder.decodeObject(forKey: "readAttribute") as! [NSAttributedStringKey:Any]
        
        nameAttribute = aDecoder.decodeObject(forKey: "nameAttribute") as! [NSAttributedStringKey:Any]
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(bookID, forKey: "bookID")
        
        aCoder.encode(id, forKey: "id")
        
        aCoder.encode(lastChapterId, forKey: "lastChapterId")
        
        aCoder.encode(nextChapterId, forKey: "nextChapterId")
        
        aCoder.encode(name, forKey: "name")
        
        aCoder.encode(priority, forKey: "priority")
        
        aCoder.encode(content, forKey: "content")
        
        aCoder.encode(pageCount, forKey: "pageCount")
        
        aCoder.encode(pageModels, forKey: "pageModels")
        
        aCoder.encode(readAttribute, forKey: "readAttribute")
        
        aCoder.encode(nameAttribute, forKey: "nameAttribute")
    }
}
