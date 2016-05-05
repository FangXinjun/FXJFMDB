//
//  ViewController.m
//  FMDB使用(1)
//
//  Created by myApplePro01 on 16/5/4.
//  Copyright © 2016年 LSH. All rights reserved.
//

#import "ViewController.h"
#import "FMDB.h"

@interface ViewController ()
@property (nonatomic, strong) FMDatabase        *db;
@property (nonatomic, strong) FMDatabaseQueue *queue;
@property (nonatomic, strong) NSString *dbPath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self createDB];

}

- (FMDatabase *)openDb{
    
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    _dbPath = [docPath stringByAppendingPathComponent:@"MyDatabase.db"];
    _db = [FMDatabase databaseWithPath:_dbPath];
    _queue=[FMDatabaseQueue databaseQueueWithPath:_dbPath];
    if ([_db open]) {
        NSLog(@"打开成功"); //blob 二进制
        
    }else{
        NSLog(@"打开失败");
    }
    return _db;
}

- (void)createDB{
    
    [self openDb];
    [_queue inDatabase:^(FMDatabase *db) {
        BOOL issucess = [_db executeUpdate:@"CREATE TABLE FXJList (id integer primary key autoincrement not null,Name text, Age integer, Sex integer, Phone text, Address text, Photo blob)"];
        if (issucess) {
            NSLog(@"创建成功");
        }
    }];

    
    [_queue close];
    [_db close];
}

- (IBAction)insertData {
    [self openDb];
    [self.queue inDatabase:^(FMDatabase *db) {
    for (int i = 0; i < 100; i++) {
        NSString *name = [NSString stringWithFormat:@"fxj-%d", i];
        int age = arc4random_uniform(100);
        
        //SQLite中的text对应到的是NSString，integer对应NSNumber，blob则是NSData
        NSString *filepath = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"mydata.jpg"];
        BOOL issucess = [_db executeUpdate:@"INSERT INTO FXJList (Name, Age, Sex, Phone, Address, Photo) VALUES (?,?,?,?,?,?)",name, @(age), @(0), @"12091234567", @"骚子营", [NSData dataWithContentsOfFile:filepath]];
        if (issucess) {
            NSLog(@"插入成功");
        }
     }
    }];
    [_queue close];
    [_db close];
}

- (IBAction)deleteData {
    
    [self openDb];
    [self.queue inDatabase:^(FMDatabase *db) {
    
        BOOL issucess =  [_db executeUpdate:@"delete from FXJList WHERE Age < ?",[NSNumber numberWithInt:50]];
        if (issucess) {
            NSLog(@"删除成功");
        }
    }];
    [_queue close];
    [_db close];
}
- (IBAction)updata {
    
    [self openDb];
    [self.queue inDatabase:^(FMDatabase *db) {
        
        BOOL issucess =  [_db executeUpdate:@"update FXJList SET Age = ? WHERE Name = ?",[NSNumber numberWithInt:30],@"fxj-3"];
        if (issucess) {
            NSLog(@"更新成功");
        }
    }];
    [_queue close];
    [_db close];
 
    
//    [self openDb];
//     [self.queue inDatabase:^(FMDatabase *db) {
//     [db beginTransaction]; // 开启事务
//   BOOL issucess1 = [db executeUpdate:@"update FXJList set Age = 111 where name = ?",@"fxj-2"];
//         NSLog(@"%d",issucess1);
//             [db rollback];// 主动回滚  issucess1修改成功但是回滚就是没有修改
//    BOOL issucess2 = [db executeUpdate:@"update FXJList set Age = 111 where name = ?",@"fxj-3"];
//     [db commit];// 提交事务
//         NSLog(@"%d",issucess2);
//     }];
//    [_queue close];
//    [_db close];
    
 
    // 如果要支持事务
    
//    [self openDb];
//    __block BOOL whoopsSomethingWrongHappened = true;
//    [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
//        
//      whoopsSomethingWrongHappened &=  [db executeUpdate:@"update FXJList SET Age = ? WHERE Name = ?", @(3),@"fxj-3"];
//        
//        whoopsSomethingWrongHappened &=  [db executeUpdate:@"update FXJList SET Age = ? WHERE Name = ?", @(3),@"fxj-4"];
//
//      whoopsSomethingWrongHappened &=  [db executeUpdate:@"update FXJList SET value = ? WHERE Name = ?", @(3),@"fxj-5"];
//        
//        
//        
//        if (!whoopsSomethingWrongHappened) {
//            
//            *rollback = YES;
//
//            return;
//            
//        }
//    }];
//   [_db close];
    
}
/*
 FMDB提供如下多个方法来获取不同类型的数据：
 intForColumn:
 
 longForColumn:
 
 longLongIntForColumn:
 
 boolForColumn:
 
 doubleForColumn:
 
 stringForColumn:
 
 dateForColumn:
 
 dataForColumn:
 
 dataNoCopyForColumn:
 
 UTF8StringForColumnIndex:
 
 objectForColumn:
 
 */
- (IBAction)queryData {
    [self openDb];
    [self.queue inDatabase:^(FMDatabase *db) {
        // 1.查询
        FMResultSet *set = [self.db  executeQuery:@"SELECT * FROM FXJList"];
        NSString *address = [_db stringForQuery:@"SELECT Address FROM FXJList WHERE Name = ?",@"fxj-99"];
        int age = [_db intForQuery:@"SELECT Age FROM FXJList WHERE Name = ?",@"fxj-6"];
        NSLog(@"1age = %d address = %@",age,address);
        // 2.取出数据
        while ([set next]) {
            
            NSString *name = [set stringForColumn:@"Name"];
            int age = [set intForColumn:@"Age"];
            NSLog(@"name = %@, age = %d", name, age);
        }
    }];
    [_queue close];
    [_db close];
}



- (IBAction)dropTable {
    [self openDb];
    //如果表格存在 则销毁
    BOOL issucess = [_db executeUpdate:@"drop table if exists FXJList;"];
    if (issucess) {
        NSLog(@"销毁成功");
    }
    [_db close];
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
