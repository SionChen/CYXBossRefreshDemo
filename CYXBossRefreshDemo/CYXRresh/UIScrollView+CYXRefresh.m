//
//  UIScrollView+CYXRefresh.m
//  CYXBossRefreshDemo
//
//  Created by 超级腕电商 on 2018/6/20.
//  Copyright © 2018年 超级腕电商. All rights reserved.
//

#import "UIScrollView+CYXRefresh.h"
#import <objc/runtime.h>
#import "CYXRefreshHeader.h"

@implementation UIScrollView (CYXRefresh)
/*设置刷新*/
-(void)setRefreshHeaderWithAction:(void(^)(void))action{
    CYXRefreshHeader * header = [[CYXRefreshHeader alloc] init];
    header.refresh = action;
    self.refreshHeader = header;
    [self insertSubview:header atIndex:0];
}
-(void)setRefreshHeader:(CYXRefreshHeader *)refreshHeader{
    objc_setAssociatedObject(self, @selector(refreshHeader), refreshHeader, OBJC_ASSOCIATION_ASSIGN);
}
-(CYXRefreshHeader *)refreshHeader{
    return objc_getAssociatedObject(self, _cmd);
}
@end
