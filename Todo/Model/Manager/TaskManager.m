//
//  TaskManager.m
//  Todo
//
//  Created by Appiaries Corporation on 12/10/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import "TaskManager.h"
#import "TodoTasks.h"
#import "TodoAPIClient.h"


@interface TaskManager ()
#pragma mark - Properties (Private)
@property (readwrite, nonatomic) TodoTasks *taskInfo;
@end


@implementation TaskManager

#pragma mark - Initialization
APISSession *apisSession;
+ (TaskManager *)sharedManager
{
    static TaskManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TaskManager alloc] initSharedInstance];
    });
    return sharedInstance;
}

- (id)initSharedInstance
{
    self = [super init];
    if (self) {
        // 初期化処理
        self.taskInfo = [[TodoTasks alloc] init];
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
- (void)addTaskInfoWithData:(NSDictionary *)data failBlock:(void(^)(NSError *))failBlock
{
    [self initialize];
    
    NSString *collectionId = @"Tasks";
    APISJsonAPIClient *api = [[APISSession sharedSession] createJsonAPIClientWithCollectionId:collectionId];
    
    [api createJsonObjectWithId:@"" data:data success:^(APISResponseObject *response){
        NSLog(@"JSONオブジェクトの登録成功 [ステータス:%ld, レスポンス:%@, ロケーション:%@]",
                (long)response.statusCode, response.data, response.location);
        failBlock(nil);
    } failure:^(NSError *error){
        NSLog(@"JSONオブジェクトの登録失敗 [原因:%@]", [error localizedDescription]);
        failBlock(error);
    }];
}

- (void)getTasksWithCompletion:(void(^)(NSDictionary *))completeBlock failedBlock:(void (^)(NSError *))block
{
    [self initialize];
    
    NSString *collectionId = @"Tasks"; // 検索対象のJSONオブジェクトが格納されているコレクションのIDを指定します
    APISQueryCondition *query = [[APISQueryCondition alloc] init];
    
    NSDictionary *userInfo = [[TodoAPIClient sharedClient]loadLogInInfo];
    [query setEqualValue:userInfo[@"user_id"] forKey:@"user_Id"];
    
    // JSONオブジェクト検索APIの実行
    APISJsonAPIClient *api = [[APISSession sharedSession] createJsonAPIClientWithCollectionId:collectionId];
    [api searchJsonObjectsWithQueryCondition:query success:^(APISResponseObject *response){
        NSLog(@"会員の取得成功 [ステータス:%ld, レスポンス:%@]", (long)response.statusCode, response.data);
        if (completeBlock) completeBlock(response.data);
    } failure:^(NSError *error){
        NSLog(@"会員の取得失敗 [原因:%@]", [error localizedDescription]);
        if (block) block(error);
    }];
}

- (void)updateTaskInfoWithTaskID:(NSString *)taskID imageData:(NSDictionary *)data failBlock:(void(^)(NSError *))failBlock
{
    [self initialize];
    
    NSString *collectionId = @"Tasks";
    
    // JSONオブジェクト更新APIの実行
    APISJsonAPIClient *api = [[APISSession sharedSession] createJsonAPIClientWithCollectionId:collectionId];
    [api updateJsonObjectWithId:taskID data:data success:^(APISResponseObject *response){
        NSLog(@"JSONオブジェクトの更新成功 [ステータス:%ld, レスポンス:%@, ロケーション:%@]",
                (long)response.statusCode, response.data, response.location);
        failBlock(nil);
    } failure:^(NSError *error){
        NSLog(@"JSONオブジェクトの更新失敗 [原因:%@]", [error localizedDescription]);
        failBlock(error);
    }];
}

- (void)deleteTaskWithTaskID:(NSString *)taskID failBlock:(void (^)(NSError *))failedBlock
{
    [self initialize];
    
    NSString *collectionId = @"Tasks"; // 削除対象のJSONオブジェクトが格納されているコレクションのIDを指定します
    // JSONオブジェクト削除APIの実行
    APISJsonAPIClient *api = [[APISSession sharedSession] createJsonAPIClientWithCollectionId:collectionId];
    [api deleteJsonObjectWithId:taskID success:^(APISResponseObject *response) {
        NSLog(@"JSONオブジェクトの一括削除成功 [ステータス:%ld, レスポンス:%@]",
              (long)response.statusCode, response.data);
        failedBlock(nil);
    } failure:^(NSError *error) {
        NSLog(@"JSONオブジェクトの一括削除失敗 [原因:%@]", [error localizedDescription]);
        failedBlock(error);
    }];
}

@end
