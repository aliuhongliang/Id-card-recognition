//
//  IDCardIdentifyTool.m
//  IDCard
//
//  Created by lihongwen-pc on 2017/1/5.
//  Copyright © 2017年 Univalsoft. All rights reserved.
//

#import "IDCardIdentifyTool.h"
#import <CloudApiSdk/CloudApiSdk.h>
#import <CloudApiSdk/HttpConstant.h>
#import <SVProgressHUD.h>

///==============================================  调起相机拍身份证识别 ============================================
typedef void(^CallBack)();

@interface IDCardIdentifyTool ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) CallBack callback;
@end

@implementation IDCardIdentifyTool

// 工具的单例
+ (instancetype)IDCardIdentify
{
    static id _instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}


// 打开相机
- (void)openCameraWithVC:(UIViewController *)vc completion:(void(^)(UIImage *image))completion
{
    self.callback = completion;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
        
        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerController.showsCameraControls = YES;
        pickerController.delegate = self;
        
        [vc presentViewController:pickerController animated:YES completion:nil];
    }else{
        NSLog(@"设备不支持摄像");
    }
}

// 开始验证身份证
- (void)startIndentifyUserIDCard:(UIImage *)image completion:(void(^)(IDCardDetailInfo *model))completion
{
    [SVProgressHUD showWithStatus:@"正在识别..."];
    
    NSData *sendImageData = [self compressOriginalImage:image toMaxDataSizeKBytes:1.5*1024];
    
    NSString *imageStr = [sendImageData base64EncodedStringWithOptions:0];
    
    [[HttpTools instance] sendHttpPostWithIDCard_base64String:imageStr completion:^(BOOL isSuccess, id response) {
        
       [SVProgressHUD dismiss];
        
        if (isSuccess) {
            
            
            NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSLog(@"身份证识别成功 --- %@",dic);
            
            NSArray *IDCardArray = dic[@"outputs"];
            
            IDCardsOutputs *base = [IDCardsOutputs IDCardsOutputsWithDic:IDCardArray[0]];
            
            
            IDCardInfo *value = base.outputValue;
            
            NSData *datas = [value.dataValue dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *dics = [NSJSONSerialization JSONObjectWithData:datas options:NSJSONReadingMutableContainers error:nil];
            
            IDCardDetailInfo *model = [IDCardDetailInfo IDCardDetailInfoWithDic:dics];
            
            completion(model);
            
        }else{
            
            NSLog(@"身份证识别失败 --- %@",response);
            
        }
    }];
  
}


#pragma mark 图片压缩
- (NSData *)compressOriginalImage:(UIImage *)image toMaxDataSizeKBytes:(CGFloat)size{
    
    NSData * data = UIImageJPEGRepresentation(image, 1.0);
    CGFloat dataKBytes = data.length/1000.0;
    CGFloat maxQuality = 0.9f;
    CGFloat lastData = dataKBytes;
    while (dataKBytes > size && maxQuality > 0.01f) {
        
        maxQuality = maxQuality - 0.01f;
        
        data = UIImageJPEGRepresentation(image, maxQuality);
        
        dataKBytes = data.length / 1000.0;
        
        if (lastData == dataKBytes) {
            break;
        }else{
            lastData = dataKBytes;
        }
    }
    return data;
}

// 获取照相机拍的图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image;
    
    image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    UIImageOrientation orientation = [image imageOrientation];
    
    CGImageRef imRef = [image CGImage];
    int texWidth = (int)CGImageGetWidth(imRef);
    int texHeight = (int)CGImageGetHeight(imRef);
    
    float imageScale = 1.0;
    
    if(orientation == UIImageOrientationUp && texWidth < texHeight)
        image = [UIImage imageWithCGImage:imRef scale:imageScale orientation: UIImageOrientationLeft];
    else if((orientation == UIImageOrientationUp && texWidth > texHeight) || orientation == UIImageOrientationRight)
        image = [UIImage imageWithCGImage:imRef scale:imageScale orientation: UIImageOrientationUp];
    else if(orientation == UIImageOrientationDown)
        image = [UIImage imageWithCGImage:imRef scale:imageScale orientation: UIImageOrientationDown];
    else if(orientation == UIImageOrientationLeft)
        image = [UIImage imageWithCGImage:imRef scale:imageScale orientation: UIImageOrientationUp];
    
    NSLog(@"originalImage width = %f height = %f",image.size.width,image.size.height);
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        self.callback(image);
        
    }];
}
@end


///==============================================  阿里云HTTP通讯请求 =============================================

@implementation HttpTools

+ (instancetype)instance
{
    static id _instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[AppConfiguration instance] setAPP_KEY:@"23588658"];
        [[AppConfiguration instance] setAPP_SECRET:@"35783944bcec8e0d5ebfb9052222bb21"];
    }
    return self;
}


- (void)sendHttpPostWithIDCard_base64String:(NSString *)idcardStr completion:(void(^)(BOOL isSuccess, id response))completion
{
    NSString * postPath = @"/rest/160601/ocr/ocr_idcard.json";
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"inputs\":[{\"image\":{\"dataType\":50,\"dataValue\":\"%@\"},\"configure\":{\"dataType\":50,\"dataValue\":\"{\\\"side\\\":\\\"face\\\"}\"}}]}",idcardStr];
    
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    
    //定义PathParameter
    NSMutableDictionary *getPathParams = [[NSMutableDictionary alloc] init];
    
    //    //定义QueryParameter
    NSMutableDictionary *getQueryParams = [[NSMutableDictionary alloc] init];
    //
    //定义HeaderParameter
    NSMutableDictionary *getHeaderParams = [[NSMutableDictionary alloc] init];
    
    [getHeaderParams setValue:CLOUDAPI_CONTENT_TYPE_JSON forKey:CLOUDAPI_HTTP_HEADER_CONTENT_TYPE];
    
    [[CloudApiSdk instance] httpPost:CLOUDAPI_HTTPS host:@"dm-51.data.aliyun.com" path:postPath pathParams:getPathParams queryParams:getQueryParams body:data headerParams:getHeaderParams completionBlock:^(NSData *body, NSURLResponse *response, NSError *error) {
        
        NSLog(@"%@",body);
        NSLog(@"Response object: %@" , response);
        NSString *bodyString = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        if (httpResponse.statusCode == 200) {
            completion(YES,bodyString);
        }else{
            completion(NO,bodyString);
        }
    }];
}

@end

///==============================================  模型数据 ======================================================

/**
 *   身份证全部数据模型
 */
@implementation IDCardsOutputs


+ (instancetype)IDCardsOutputsWithDic:(NSDictionary *)dic
{
    IDCardsOutputs *output = [[IDCardsOutputs alloc] init];
    output.outputLabel = dic[@"outputLabel"];
    output.outputValue = [IDCardInfo IDCardInfoWithDic:dic[@"outputValue"]];
    return output;
}

@end

/**
 *   身份证信息数据模型
 */
@implementation IDCardInfo


+ (instancetype)IDCardInfoWithDic:(NSDictionary *)dic
{
    IDCardInfo *cardInfo = [[IDCardInfo alloc] init];
    cardInfo.dataType = [dic[@"dataType"] integerValue];
    cardInfo.dataValue = dic[@"dataValue"];
    return cardInfo;
}
@end

/**
 *   身份证详细
 */
@implementation IDCardDetailInfo


+ (instancetype)IDCardDetailInfoWithDic:(NSDictionary *)dic
{
    IDCardDetailInfo *info = [[IDCardDetailInfo alloc] init];
    [info setValuesForKeysWithDictionary:dic];
    return info;
}

@end
