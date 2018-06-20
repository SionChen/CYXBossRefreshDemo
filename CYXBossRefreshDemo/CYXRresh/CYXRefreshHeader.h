//
//  CYXRefreshHeader.h
//  CYXBossRefreshDemo
//
//  Created by 超级腕电商 on 2018/6/20.
//  Copyright © 2018年 超级腕电商. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYXRefreshHeader : UIView
/*刷新block*/
@property (nonatomic,strong) void(^refresh)();
/*开始刷新*/
-(void)startRefresh;
/*结束刷新*/
-(void)endRefresh;
@end
