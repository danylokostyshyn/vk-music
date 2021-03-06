//
//  Audio.swift
//  vk-music
//
//  Created by Danylo Kostyshyn on 9/22/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

import UIKit
import AVFoundation

class Audio: NSObject {
    
    override var description: String { return fileName! }
    
    var fileURL: NSURL?
    var remoteURL: NSURL?
    var fileName: String?

    var title: String?
    var artist: String?
    var albumArt: UIImage?

    var size: Int = 0       // bytes
    var duration: Int = 0   // seconds
    var bitrate: Int {      // kbps
        if size > 0 && duration > 0 {
            return size * 8 / 1000 / duration
        }
        return 0
    }
    
    var downloadOperation: DownloadOperation?
    
    var vkDictionary: NSDictionary?
    
    init(fileURL: NSURL) {
        self.fileURL = fileURL
        self.fileName = fileURL.lastPathComponent
        
        let filePath = fileURL.path
        var fileAttributes: NSDictionary?
        do {
            fileAttributes = try NSFileManager.defaultManager().attributesOfItemAtPath(filePath!)
        } catch {
            super.init()
            return
        }

        self.size = fileAttributes!.objectForKey(NSFileSize) as! Int
        
        super.init()
        
        self.loadMetadata(self.fileURL!)
    }

    init(vkDictionary: NSDictionary) {
        self.vkDictionary = vkDictionary

        self.artist = vkDictionary.objectForKey("artist") as? String
        if let range = self.artist?.rangeOfCharacterFromSet(NSCharacterSet.newlineCharacterSet()) {
            self.artist = self.artist?.substringToIndex(range.startIndex)
        }

        self.title = vkDictionary.objectForKey("title") as? String
        if let range = self.title?.rangeOfCharacterFromSet(NSCharacterSet.newlineCharacterSet()) {
            self.title = self.title?.substringToIndex(range.startIndex)
        }

        self.duration = vkDictionary.objectForKey("duration") as! Int
        
        if let URLString = vkDictionary.objectForKey("url") as? String {
            self.remoteURL = NSURL(string: URLString)
        }
        
        super.init()
    }
    
    func loadMetadata(fileURL: NSURL) {
        let asset = AVURLAsset(URL: fileURL, options: nil)
        duration = Int(CMTimeGetSeconds(asset.duration))
        
        if let value = (AVMetadataItem.metadataItemsFromArray(asset.commonMetadata, withKey: AVMetadataCommonKeyArtist, keySpace: AVMetadataKeySpaceCommon).first as? AVMutableMetadataItem)?.value { artist = value as? String }

        if let value = (AVMetadataItem.metadataItemsFromArray(asset.commonMetadata, withKey: AVMetadataCommonKeyTitle, keySpace: AVMetadataKeySpaceCommon).first as? AVMutableMetadataItem)?.value { title = value as? String }

        if let value = (AVMetadataItem.metadataItemsFromArray(asset.commonMetadata, withKey: AVMetadataCommonKeyArtwork, keySpace: AVMetadataKeySpaceCommon).first as? AVMutableMetadataItem)?.value { albumArt = UIImage(data: value as! NSData) }
    }
    
//    func writeMetadata(title: String, artist: String) {
//        var error: NSError?
//        var assetWriter = AVAssetWriter(URL: self.fileURL, fileType: AVFileTypeMPEGLayer3, error: &error)
//        
//        var titleMetadataItem = AVMutableMetadataItem()
//        titleMetadataItem.key = AVMetadataCommonKeyTitle
//        titleMetadataItem.keySpace = AVMetadataKeySpaceCommon
//        titleMetadataItem.value = title
//        
//        var artistMetadataItem = AVMutableMetadataItem()
//        artistMetadataItem.key = AVMetadataCommonKeyArtist
//        artistMetadataItem.keySpace = AVMetadataKeySpaceCommon
//        artistMetadataItem.value = artist
//        
//        assetWriter.metadata = [titleMetadataItem, artistMetadataItem]
//        assetWriter.startWriting()
//        assetWriter.startSessionAtSourceTime(kCMTimeZero)
//    }

}