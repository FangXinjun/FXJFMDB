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
//@property (nonatomic, strong) FMDatabase        *db;
@property (nonatomic, strong) FMDatabaseQueue *queue;
@property (nonatomic, strong) NSString *dbPath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self createDB];
    [self openDb];


}

- (void)openDb{
    
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    _dbPath = [docPath stringByAppendingPathComponent:@"MyDatabase.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:_dbPath];
    _queue = [FMDatabaseQueue databaseQueueWithPath:_dbPath];
    if ([db open]) {
        NSLog(@"打开成功"); //blob 二进制
        [_queue inDatabase:^(FMDatabase *db) {
            if ([db open]) {
                BOOL issucess = [db executeUpdate:@"CREATE TABLE FXJList (id integer primary key autoincrement not null,Name text, Age integer, Sex integer, Phone text, Address text, Photo blob)"];
                if (issucess) {
                    NSLog(@"创建成功1");
                }
                
                //            BOOL issucess2 = [db executeUpdate:@"CREATE TABLE FXJ2List (id integer primary key autoincrement not null,Name text, Age integer, Sex integer, Phone text, Address text, Photo blob)"];
                //            if (issucess2) {
                //                NSLog(@"创建成功2");
                //            }
            }
            [db close];
        }];
        [_queue close];

    }else{
        NSLog(@"打开失败");
    }
    
}

//- (void)createDB{
//    [self openDb];
//    [_queue inDatabase:^(FMDatabase *db) {
//        if ([db open]) {
//            BOOL issucess = [db executeUpdate:@"CREATE TABLE FXJList (id integer primary key autoincrement not null,Name text, Age integer, Sex integer, Phone text, Address text, Photo blob)"];
//            if (issucess) {
//                NSLog(@"创建成功1");
//            }
//            
////            BOOL issucess2 = [db executeUpdate:@"CREATE TABLE FXJ2List (id integer primary key autoincrement not null,Name text, Age integer, Sex integer, Phone text, Address text, Photo blob)"];
////            if (issucess2) {
////                NSLog(@"创建成功2");
////            }
//        }
//        [db close];
//    }];
//    [_queue close];
//}

- (IBAction)insertData {
    
    [self.queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            for (int i = 0; i < 100; i++) {
                NSString *name = [NSString stringWithFormat:@"fxj-%d", i];
                int age = arc4random_uniform(100);
                
                //SQLite中的text对应到的是NSString，integer对应NSNumber，blob则是NSData
                NSString *filepath = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"mydata.jpg"];
                BOOL issucess = [db executeUpdate:@"INSERT INTO FXJList (Name, Age, Sex, Phone, Address, Photo) VALUES (?,?,?,?,?,?)",name, @(age), @(0), @"12091234567", @"骚子营", [NSData dataWithContentsOfFile:filepath]];
                if (issucess) {
                    NSLog(@"插入成功");
                }
            }
        }
        [db close];
    }];
    [_queue close];
}

- (IBAction)deleteData {
    
    [self.queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            BOOL issucess =  [db executeUpdate:@"delete from FXJList WHERE Age < ?",[NSNumber numberWithInt:50]];
            if (issucess) {
                NSLog(@"删除成功");
            }
        }
        [db close];
    }];
    [_queue close];
}
- (IBAction)updata {
//    
//    [self.queue inDatabase:^(FMDatabase *db) {
//        if ([db open]) {
//            BOOL issucess =  [db executeUpdate:@"update FXJList SET Age = ? WHERE Name = ?",[NSNumber numberWithInt:30],@"fxj-3"];
//            if (issucess) {
//                NSLog(@"更新成功");
//            }
//        }
//        [db close];
//    }];
//    [_queue close];
//
    
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
    __block BOOL whoopsSomethingWrongHappened = true;
    [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                
            whoopsSomethingWrongHappened &=  [db executeUpdate:@"update FXJList SET Age = ? WHERE Name = ?", @(34),@"fxj-3"];
            
            whoopsSomethingWrongHappened &=  [db executeUpdate:@"update FXJList SET Age = ? WHERE Name = ?", @(34),@"fxj-4"];
            
            whoopsSomethingWrongHappened &=  [db executeUpdate:@"update FXJList SET Age = ? WHERE Name = ?", @(34),@"fxj-5"];
            
            if (!whoopsSomethingWrongHappened) {
                
                *rollback = YES;
                
                return;
            }else{
                NSLog(@"事务修改成功");
            
            }
    }];
    [_queue close];
    
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
    [self.queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            // 1.查询
            NSString *address = [db stringForQuery:@"SELECT Address FROM FXJList WHERE Name = ?",@"fxj-99"];
            int age = [db intForQuery:@"SELECT Age FROM FXJList WHERE Name = ?",@"fxj-6"];
            NSLog(@"1age = %d address = %@",age,address);
            
                     
//            FMResultSet *set = [db  executeQuery:@"SELECT * FROM FXJList"];
//            // 2.取出数据
//            while ([set next]) {
//                
//                NSString *name = [set stringForColumn:@"Name"];
//                int age = [set intForColumn:@"Age"];
//                NSLog(@"name = %@, age = %d", name, age);
//            }
        }
        [db close];
    }];
    [_queue close];
}



- (IBAction)dropTable {

    [self.queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
           
            //如果表格存在 则销毁
            BOOL issucess = [db executeUpdate:@"drop table if exists FXJList;"];
            if (issucess) {
                NSLog(@"销毁成功");
            }
            
            BOOL issucess1 = [db executeUpdate:@"drop table if exists FXJ2List;"];
            if (issucess1) {
                NSLog(@"销毁成功1");
            }

        }
        [db close];
    }];
    [_queue close];
 
}

//模糊查询
- (IBAction)blurSselect{
    
    [self.queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM FXJList WHERE Name like '%%%@%%' ORDER BY Age ASC;",@"9"];//模糊查询，查询Name中包含 @"9" 的内容  用年龄顺序排序
            FMResultSet *setmohu = [db executeQuery:sql];
            while ([setmohu next]) {
                
                NSString *name = [setmohu stringForColumn:@"Name"];
                int age = [setmohu intForColumn:@"Age"];
                NSLog(@"name = %@, age = %d", name, age);
            }
        
        }
        [db close];
    }];
    [_queue close];


}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)refreshQueue {
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    _dbPath = [docPath stringByAppendingPathComponent:@"MyDatabase.db"];
    _queue = [FMDatabaseQueue databaseQueueWithPath:_dbPath];
    
}

@end
