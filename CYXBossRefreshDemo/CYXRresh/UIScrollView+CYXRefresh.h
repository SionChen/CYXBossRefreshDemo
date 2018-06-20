//
//  UIScrollView+CYXRefresh.h
//  CYXBossRefreshDemo
//
//  Created by 超级腕电商 on 2018/6/20.
//  Copyright © 2018年 超级腕电商. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CYXRefreshHeader;
@interface UIScrollView (CYXRefresh)

@property (nonatomic,readonly,weak) CYXRefreshHeader *refreshHeader;
/*设置刷新*/
-(void)setRefreshHeaderWithAction:(void(^)(void))action;

@end
