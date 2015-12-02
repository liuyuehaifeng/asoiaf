//
//  SubCatesViewController.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/2.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CategoryMemberModel;

@interface SubCatesViewController : UITableViewController

@property (nonatomic, strong) CategoryMemberModel *parentCategory;
@property (nonatomic, strong) UIViewController *parentVC;

@end