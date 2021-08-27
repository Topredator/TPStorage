//
//  TPViewController.m
//  TPStorage
//
//  Created by 周晓路 on 08/27/2021.
//  Copyright (c) 2021 周晓路. All rights reserved.
//

#import "TPViewController.h"
#import "TPSchool.h"
#import "TPStudent.h"
#import <Masonry/Masonry.h>
@interface TPViewController ()

@end

@implementation TPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self setupSubviews];
}

- (void)setupSubviews {
    UIButton *addSchoolBtn = [self createBtnWithTitle:@"创建学校" action:@selector(addSchool)];
    [addSchoolBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 30));
        make.left.mas_equalTo(30);
        make.top.mas_equalTo(100);
    }];
    UIButton *addStudentBtn = [self createBtnWithTitle:@"添加学生" action:@selector(addStudent)];
    [addStudentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 30));
        make.left.mas_equalTo(30);
        make.top.equalTo(addSchoolBtn.mas_bottom).offset(30);
    }];
    UIButton *deleteAllSchoolBtn = [self createBtnWithTitle:@"删除所有学校" action:@selector(removeAllSchool)];
    [deleteAllSchoolBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 30));
        make.left.mas_equalTo(30);
        make.top.equalTo(addStudentBtn.mas_bottom).offset(30);
    }];
    UIButton *deleteAllStudentBtn = [self createBtnWithTitle:@"删除所有学生信息" action:@selector(removeAllStudent)];
    [deleteAllStudentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 30));
        make.left.mas_equalTo(30);
        make.top.equalTo(deleteAllSchoolBtn.mas_bottom).offset(30);
    }];
    UIButton *updateStudentBtn = [self createBtnWithTitle:@"更改学生姓名" action:@selector(updateAllStudentsName)];
    [updateStudentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 30));
        make.left.mas_equalTo(30);
        make.top.equalTo(deleteAllStudentBtn.mas_bottom).offset(30);
    }];
    
    UIButton *allSchoolBtn = [self createBtnWithTitle:@"查询所有学校" action:@selector(allSchools)];
    [allSchoolBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 30));
        make.left.mas_equalTo(30);
        make.top.equalTo(updateStudentBtn.mas_bottom).offset(30);
    }];
    UIButton *allStudentBtn = [self createBtnWithTitle:@"查询所有学生" action:@selector(allStudents)];
    [allStudentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 30));
        make.left.mas_equalTo(30);
        make.top.equalTo(allSchoolBtn.mas_bottom).offset(30);
    }];
}

- (void)addSchool {
    NSLog(@"创建学校");
    [TPStorageEngine.storageEngine syncSaveModel:[self createSchool]];
}
- (void)addStudent {
    NSLog(@"插入学生数据");
    TPStudent *student = [self createStudent];
    TPStudent *student1 = [self createStudent];
    [TPStorageEngine.storageEngine syncSaveModels:@[student, student1]];
}

- (void)removeAllSchool {
    NSLog(@"删除所有学校");
//    [TPStorageEngine.storageEngine syncDeleteAllModels:TPSchool.class];
    [TPStorageEngine.storageEngine asyncDeleteAllModels:TPSchool.class callback:^(BOOL result, NSString * _Nonnull msg) {
        NSLog(@"结果: %@", msg);
    }];
}
- (void)removeAllStudent {
    NSLog(@"删除所有学生信息");
    [TPStorageEngine.storageEngine syncDeleteAllModels:TPStudent.class];
}
- (void)allSchools {
    NSLog(@"查询所有学校");
    NSArray *schools = [TPStorageEngine.storageEngine syncQueryModelsWithClass:TPSchool.class];
    for (TPSchool *school in schools) {
        NSLog(@"学校 %@", school.debugDescription);
    }
}
- (void)allStudents {
    NSLog(@"查询所有学生");
    NSArray *students = [TPStorageEngine.storageEngine syncQueryModelsWithClass:TPStudent.class];
    for (TPStudent *student in students) {
        NSLog(@"学生 %@", student.debugDescription);
    }
}
- (void)updateAllStudentsName {
    NSLog(@"更改所有学生姓名");
    [TPStorageEngine.storageEngine syncUpdateWithSQL:@"update TPStudent Set name = '学生123'"];
}

- (UIButton *)createBtnWithTitle:(NSString *)title action:(SEL)action {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    btn.backgroundColor = UIColor.purpleColor;
    [self.view addSubview:btn];
    return btn;
}
- (TPSchool *)createSchool {
    TPSchool *school = [TPSchool new];
    school.schoolName = @"学校";
    school.schoolId = [NSString stringWithFormat:@"%u", arc4random() % 100 + 1];
    school.address = @"学校地址是个谜";
    NSInteger number = arc4random() % 2;
    school.termBegins = number;
    return school;
}
- (TPStudent *)createStudent  {
    TPStudent *student = [TPStudent new];
    student.schoolId = [NSString stringWithFormat:@"%u", arc4random() % 100 + 1];
    NSString *number = [NSString stringWithFormat:@"%u", arc4random() % 50 + 1];
    student.studentId = number;
    student.name = [NSString stringWithFormat:@"学生%@", number];
    student.age = arc4random() % 20 + 6;
    return student;
}
@end
