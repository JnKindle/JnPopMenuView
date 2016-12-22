//
//  ViewController.m
//  JnPopMenuView
//
//  Created by Jn_Kindle on 2016/12/21.
//  Copyright © 2016年 JnKindle. All rights reserved.
//

#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width

#import "ViewController.h"

#import "JnPopMenuView.h"
#import "popMenvTopView.h"

@interface ViewController ()<JnPopMenuViewDelegate>

@property (nonatomic, strong) JnPopMenuView *shareMenu;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createShareMenu];
    
    
    UIButton *showMenuBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, kScreenWidth, 50)];
    showMenuBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    showMenuBtn.backgroundColor = [UIColor blackColor];
    [showMenuBtn setTitle:@"showMenu" forState:UIControlStateNormal];
    [showMenuBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [showMenuBtn addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showMenuBtn];
    
    
    
    
}


- (void)createShareMenu
{
    
     _shareMenu = [JnPopMenuView sharedPopMenuManager];
    PopMenuModel* model = [PopMenuModel
                           allocPopMenuModelWithImageNameString:@"invite-weibo"
                           AtTitleString:@"新浪"
                           AtTextColor:[UIColor grayColor]
                           AtTransitionType:PopMenuTransitionTypeCustomizeApi
                           AtTransitionRenderingColor:nil];
    
    PopMenuModel* model1 = [PopMenuModel
                            allocPopMenuModelWithImageNameString:@"invite-wechart"
                            AtTitleString:@"微信"
                            AtTextColor:[UIColor grayColor]
                            AtTransitionType:PopMenuTransitionTypeSystemApi
                            AtTransitionRenderingColor:nil];
    
    PopMenuModel* model2 = [PopMenuModel
                            allocPopMenuModelWithImageNameString:@"invite-friend"
                            AtTitleString:@"朋友圈"
                            AtTextColor:[UIColor grayColor]
                            AtTransitionType:PopMenuTransitionTypeCustomizeApi
                            AtTransitionRenderingColor:nil];
    
    PopMenuModel* model3 = [PopMenuModel
                            allocPopMenuModelWithImageNameString:@"invite-qq"
                            AtTitleString:@"QQ"
                            AtTextColor:[UIColor grayColor]
                            AtTransitionType:PopMenuTransitionTypeSystemApi
                            AtTransitionRenderingColor:nil];
    
    PopMenuModel* model4 = [PopMenuModel
                            allocPopMenuModelWithImageNameString:@"invite-qzone"
                            AtTitleString:@"QQzone"
                            AtTextColor:[UIColor grayColor]
                            AtTransitionType:PopMenuTransitionTypeCustomizeApi
                            AtTransitionRenderingColor:nil];
    
    PopMenuModel* model5 = [PopMenuModel
                            allocPopMenuModelWithImageNameString:@"invite-more"
                            AtTitleString:@"更多"
                            AtTextColor:[UIColor grayColor]
                            AtTransitionType:PopMenuTransitionTypeSystemApi
                            AtTransitionRenderingColor:nil];
     
     _shareMenu.dataSource = @[ model, model1, model2, model3, model4, model5 ];
     _shareMenu.delegate = self;
     _shareMenu.popMenuSpeed = 12.0f;
     _shareMenu.automaticIdentificationColor = false;
     _shareMenu.animationType = JnPopMenuViewAnimationTypeViscous;
    
    popMenvTopView* topView = [popMenvTopView popMenvTopView];
    topView.frame = CGRectMake(0, 44, CGRectGetWidth(self.view.frame), 92);
    _shareMenu.topView = topView;
    
}


- (void)showMenu
{
    _shareMenu.backgroundType = JnPopMenuViewBackgroundTypeLightBlur;
    [_shareMenu openMenu];
}

- (void)popMenuView:(JnPopMenuView*)popMenuView didSelectItemAtIndex:(NSUInteger)index
{
    
    NSLog(@"点击了%lu",(unsigned long)index);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
}


@end
