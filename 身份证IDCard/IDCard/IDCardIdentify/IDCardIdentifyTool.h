//
//  IDCardIdentifyTool.h
//  IDCard
//
//  Created by lihongwen-pc on 2017/1/5.
//  Copyright © 2017年 Univalsoft. All rights reserved.

/*
 
    阿里云返回的身份证数据格式
 
    {
         outputs =     (
         {
         outputLabel = "ocr_id";
         outputMulti =             {
         };
         outputValue =             {
         dataType = 50;
         dataValue = "{\"address\":\"寿光",\"birth\":\"1111111\",\"config_str\":\"{\\\"side\\\":\\\"face\\\"}\",\"name\":\"某某某",\"nationality\":\"\U6c49\",\"num\":\"1111111111111111\",\"request_id\":\"11111111111\",\"sex\":\"人妖",\"success\":true}\n";
         };
         }
         );
    }
 */

#import <UIKit/UIKit.h>

@class IDCardInfo;
@class IDCardDetailInfo;
@class IDCardDetailInfo;

///==============================================  调起相机拍身份证识别 ============================================
@interface IDCardIdentifyTool : NSObject

// 工具的单例
+ (instancetype)IDCardIdentify;

// 打开相机
- (void)openCameraWithVC:(UIViewController *)vc completion:(void(^)(UIImage *image))completion;

// 开始验证身份证
- (void)startIndentifyUserIDCard:(UIImage *)image completion:(void(^)(IDCardDetailInfo *model))completion;

@end


///==============================================  阿里云HTTP通讯请求 =============================================

@interface HttpTools : NSObject

+ (instancetype)instance;

- (void)sendHttpPostWithIDCard_base64String:(NSString *)idcardStr completion:(void(^)(BOOL isSuccess, id response))completion;

@end

///==============================================  模型数据 ======================================================

/**
 *   身份证全部数据模型
 */
@interface IDCardsOutputs : NSObject

    @property (nonatomic, strong) IDCardInfo *outputValue;
    @property (nonatomic, strong) NSString *outputLabel;

+ (instancetype)IDCardsOutputsWithDic:(NSDictionary *)dic;

@end

/**
 *   身份证信息数据模型
 */
@interface IDCardInfo : NSObject

    @property (nonatomic, strong) NSString *dataValue;
    @property (nonatomic, assign) NSInteger dataType;

+ (instancetype)IDCardInfoWithDic:(NSDictionary *)dic;
@end

/**
 *   身份证详细
 */
@interface IDCardDetailInfo : NSObject

        @property (nonatomic, strong) NSString *address;
        @property (nonatomic, strong) NSString *name;
        @property (nonatomic, strong) NSString *birth;
        @property (nonatomic, strong) NSString *config_str;
        @property (nonatomic, strong) NSString *num;
        @property (nonatomic, strong) NSString *request_id;
        @property (nonatomic, strong) NSString *sex;
        @property (nonatomic, strong) NSString *success;
        @property (nonatomic, strong) NSString *nationality;

+ (instancetype)IDCardDetailInfoWithDic:(NSDictionary *)dic;

@end
