//
//  TopManager.m
//  Todo
//
//  Created by Appiaries Corporation on 12/8/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import "UserManager.h"
#import "TodoAPIClient.h"
#import "TodoUsers.h"


@interface UserManager ()
#pragma mark - Properties (Private)
@property (readwrite, nonatomic) TodoUsers *todoInfo;
@end


@implementation UserManager

#pragma mark - Initialization
APISSession *apisSession;
+ (UserManager *)sharedManager
{
    static UserManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UserManager alloc] initSharedInstance];
    });
    return sharedInstance;
}

- (id)initSharedInstance
{
    self = [super init];
    if (self) {
        // 初期化処理
        self.todoInfo = [[TodoUsers alloc] init];
    }
    return self;
}

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)initialize
{
    apisSession = [APISSession sharedSession];
    apisSession.datastoreId      = TODOAPISDatastoreId;
    apisSession.applicationId    = TODOAPISAppId;
    apisSession.applicationToken = TODOAPISAppToken;
}

#pragma mark - Public methods
- (void)doLogin:(TodoUsers *)userInfo WithCompletion:(void (^)(NSDictionary *))completeBlock failBlock:(void (^)(NSError *))block
{
    [self initialize];

    // 会員ログインAPIの実行
    APISAppUserAPIClient *api = [[APISSession sharedSession] createAppUserAPIClient];
    [api loginWithLoginId:userInfo.loginId
                 password:userInfo.password
                autoLogin:YES
                  success:^(APISResponseObject *response){
                      NSLog(@"会員のログイン成功 [ステータス:%ld, レスポンス:%@, ロケーション:%@]",
                            (long)response.statusCode, response.data, response.location);
                      if (completeBlock) completeBlock(response.data);
                  }
                  failure:^(NSError *error){
                      NSLog(@"会員のログイン失敗 [原因:%@]", [error localizedDescription]);
                      if (block) block(error);
                  }];
}

- (void)createUser:(TodoUsers *)userInfo withBlock:(void (^)(NSError *))block
{
    [self initialize];

    // 会員登録APIの実行
    NSMutableDictionary *attribute = [[NSMutableDictionary alloc] init];
    [attribute setValue:@"Default" forKey:@"nickname"];
    APISAppUserAPIClient *apiClient = [[APISSession sharedSession] createAppUserAPIClient];
    [apiClient createAppUserWithLoginId:userInfo.loginId
                               password:userInfo.password
                                  email:userInfo.email
                             attributes:attribute
                                success:^(APISResponseObject *response){
                                    NSLog(@"会員の登録成功 [ステータス:%ld, レスポンス:%@, ロケーション:%@]",
                                          (long)response.statusCode, response.data, response.location);
                                    block(nil);
                                }
                                failure:^(NSError *error){
                                    NSLog(@"会員の登録失敗 [原因:%@]", [error localizedDescription]);
                                    block(error);
                                }];
}

- (void)getUserWithCompletion:(void(^)(NSDictionary *))completeBlock failedBlock:(void (^)(NSError *))block
{
    APISAppUser *appUser = [APISSession sharedSession].appUser;
    
    [self initialize];
    
    // 会員取得APIの実行
    APISAppUserAPIClient *api = [[APISSession sharedSession] createAppUserAPIClient];
    [api retrieveAppUserWithId:appUser.id
                       success:^(APISResponseObject *response){
                           NSLog(@"会員の取得成功 [ステータス:%ld, レスポンス:%@]",
                                 (long)response.statusCode, response.data);
                           NSDictionary *playerInfo = response.data;
                           if (completeBlock) completeBlock(playerInfo);
                       }
                       failure:^(NSError *error){
                           NSLog(@"会員の取得失敗 [原因:%@]", [error localizedDescription]);
                           if (block) block(error);
                       }];
}

- (void)updateUser:(APISAppUser *)appUser withCompletion:(void(^)(NSDictionary *))completeBlock failedBlock:(void (^)(NSError *))block
{
    [self initialize];
    
    // 会員取得APIの実行
    APISAppUserAPIClient *api = [[APISSession sharedSession] createAppUserAPIClient];
    [api updateAppUser:appUser
               success:^(APISResponseObject *response){
                   NSLog(@"会員の取得成功 [ステータス:%ld, レスポンス:%@]",
                           (long)response.statusCode, response.data);
                   NSDictionary *playerInfo = response.data;
                   if (completeBlock) completeBlock(playerInfo);
               }
               failure:^(NSError *error){
                   NSLog(@"会員の取得失敗 [原因:%@]", [error localizedDescription]);
                   if (block) block(error);
               }];
}

@end
