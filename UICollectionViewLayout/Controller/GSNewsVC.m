//
//  GSNewsVC.m
//  UICollectionViewLayout
//
//  Created by 管章鹏 on 2018/7/5.
//  Copyright © 2018年 管章鹏. All rights reserved.
//
#define MaxSectionNum (100)
#define ScreenWidth ([UIScreen mainScreen].bounds.size.width)

#import "GSNewsVC.h"
#import "GSNewsCell.h"
#import "GSNews.h"
#import "MJExtension.h"
#import "Masonry.h"

@interface GSNewsVC ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSArray *news;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation GSNewsVC

static NSString * const cellID = @"News";

#pragma mark 数据懒加载
-(NSArray *)news{
    if (!_news) {
        _news = [GSNews mj_objectArrayWithFilename:@"newses.plist"];
        self.pageControl.numberOfPages = _news.count;
    }
    return _news;
}
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(self.view.bounds.size.width, 300);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 300) collectionViewLayout:layout];
        _collectionView.pagingEnabled = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
         [_collectionView registerClass:[GSNewsCell class] forCellWithReuseIdentifier:cellID];
        _collectionView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}
-(UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        [self.view addSubview:_pageControl];
        
    }
    return _pageControl;
}
#pragma mark 系统回调方法
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"无限轮播";
    self.view.backgroundColor = [UIColor whiteColor];
    
    //默认显示最中间的那组数据
     [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:MaxSectionNum/2]  atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];

    
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.collectionView).with.offset(-15);
        make.width.mas_equalTo(150);
        make.bottom.equalTo(self.collectionView.mas_bottom);
        make.height.mas_equalTo(20);
    }];
    [self startTimer];
    
}
//开启定时器
- (void)startTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
- (void)stopTimer{
    [self.timer invalidate];
    self.timer = nil;
}
- (void)nextPage{
    //获取当前正在展示的位置
    NSIndexPath *currentIndexPath = [[self.collectionView indexPathsForVisibleItems] lastObject];
    
    //最中间的那组数据
    NSIndexPath *currentIndexPathReset = [NSIndexPath indexPathForRow:currentIndexPath.item inSection:MaxSectionNum/2];
    
    //马上显示最中间的那组数据上
    [self.collectionView scrollToItemAtIndexPath:currentIndexPathReset atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
    //计算下一组数据
    NSInteger nextItem = currentIndexPathReset.item + 1;
    NSInteger nextSection = currentIndexPathReset.section;
    if (nextItem == self.news.count) {
        nextItem = 0;
        nextSection ++;
    }

    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:nextItem inSection:nextSection];
    //滚动到下一组数据
    [self.collectionView scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

#pragma mark <UICollectionViewDataSource>
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return MaxSectionNum;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.news.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GSNewsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    cell.news = self.news[indexPath.item];
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self stopTimer];
  
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
     [self startTimer];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
      self.pageControl.currentPage = (NSInteger)(scrollView.contentOffset.x /self.collectionView.frame.size.width +0.5) % self.news.count;
}
@end
