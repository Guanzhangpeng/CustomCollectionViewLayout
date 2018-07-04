# CustomCollectionViewLayout
UICollectionView WaterFlowLayout 流水布局 自定义布局
# UICollectionView的使用
UICollectionView 和 UITableView非常的相似,但是使用起来却比UITableView 强大很多.

二者的使用比较:

**相同点**
   1. 都是通过`datasource`和`delegate`来驱动的，因此在使用的时候必须实现数据源与代理协议方法;
   2. 性能上都实现了循环利用的优化。
   
**不同点**
   1. UITableView的cell是系统自动布局好的，不需要我们布局。但UICollectionView的cell是需要我们自己布局的。所以我们在创建UICollectionView的时候必须传递一个布局参数，系统帮助我们提供并实现了一个流水布局`UICollectionViewFlowLayout`
   2. UITableView的滚动方式只能是垂直方向， 而UICollectionView既可以垂直滚动，也可以水平滚动；
   3. UICollectionView的cell只能通过注册来确定重用标识符。

### UICollectionView的基本使用
我们来看看如下代码:

```objc
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    GSCollectionVC *vc = [[GSCollectionVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}
```

运行起来之后点击View,此时系统给我们抛出如下错误:

```objc
*** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: 'UICollectionView must be initialized with a non-nil layout parameter'

```

上面我们说过CollectionView在初始化的时候必须传递一个布局参数,所以这里我们需要在`GSCollectionVC`中重写init方法,指定布局方式

```objc
- (instancetype)init{
    // 设置流水布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

    layout.itemSize = CGSizeMake(ScreenWidth/7, ScreenWidth/7);

    layout.minimumLineSpacing = 0;

    layout.minimumInteritemSpacing = 0;

    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    // 设置组头大小
    layout.headerReferenceSize = CGSizeMake(ScreenWidth, ScreenWidth/7);
 
    return [self initWithCollectionViewLayout:layout];
}
```
下面我们来看看 `UICollectionViewDataSource` `UICollectionViewDelegate` 和`UICollectionViewDelegateFlowLayout`中的常用方法:

```objc
- (void)viewDidLoad {
    
    [super viewDidLoad];
    _dayAry = [NSMutableArray array];
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([DateCell class]) bundle:nil] forCellWithReuseIdentifier:cellID];
    
    //注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致
    [self.collectionView registerNib:[UINib nibWithNibName:@"DateHeadView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"DateHeadView"];
    [self dataHandle:[[NSDate date] description]];
    
}
#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dayAry.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    DateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.textLabel.text = [_dayAry[indexPath.row] description];
    return cell;
}

//要想使该方法生效必须设置组头或者组尾部大小
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{

    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"DateHeadView" forIndexPath:indexPath];
        if(headView == nil)
        {
            headView = [[UICollectionReusableView alloc] init];
        }
        return headView;
    }
    return nil;
}

#pragma mark <UICollectionViewDelegate>
//点击item方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor greenColor];
}
//取消点击item方法
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}
#pragma mark <UICollectionViewDelegateFlowLayout>
/**
 * 除了在上面直接设置layout的一些属性来设置间距等,也可以使用该代理方法来指定布局方式,该优先级要高于上面直接指定的方式
 */
//设置itemSize
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(ScreenWidth/7, ScreenWidth/7);
}

//设置水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 0;
}

//设置垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}
//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

//设置headerView的尺寸大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(ScreenWidth, ScreenWidth/7);
}
@end
```

运行之后 效果图如下:
![](http://om62rgcp0.bkt.clouddn.com/15306884074526.jpg)

这里我贴一下日期计算的几个关键的代码:

```objc
/**
 * 根据所传递的日期计算当前月份的天数
 **/
+ (NSInteger)totalDaysInMonthFromDate:(NSDate*)date{
    NSRange dayRange = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return dayRange.length;
}
/**
 * 根据所传递的日期计算当前月份的第一天是星期几
 **/
+ (NSInteger)weekDayMonthOfFirstDayFromDate:(NSDate*)date{
    NSInteger firstDayOfMonthInt = [[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfMonth forDate:date];
    return firstDayOfMonthInt - 1;
}
```

```objc
- (void)dataHandle:(NSString*)dateStr{
    
    [_dayAry removeAllObjects];
    
    //计算当月第一天星期几
    NSInteger firstWeekDay = [EOCDateModel weekDayMonthOfFirstDayFromDate:[NSDate date]];
    
    //计算当月共有多少天
    NSInteger dayCount = [EOCDateModel totalDaysInMonthFromDate:[NSDate date]];
    
    
    // 补充当月星期几前面的空白
    for (int i = 0; i< firstWeekDay; i++) {
        [_dayAry addObject:@""];
    }
    for (int i = 0; i< dayCount; i++) {
        [_dayAry addObject:@(i+1)];
    }
    // 补后面余下的空白
    int leftDay = 0;
    if (_dayAry.count%7) {
        leftDay = 7 - _dayAry.count%7;
    }
    for (int i = 0; i< leftDay; i++) {
        [_dayAry addObject:@""];
    }
    [self.collectionView reloadData];
}
```

###瀑布流布局
瀑布流布局在很多应用中非常常见，效果图如下：
![](http://om62rgcp0.bkt.clouddn.com/15307047006168.jpg)

**实现思路**
（1）继承自`UICollectionViewLayout`；
（2）几个需要重载的方法：

```objc
/*
 * 初始化
 */
- (void)prepareLayout;
/*
 * 返回rect中的所有的元素的布局属性
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect;
/*
 * 返回对应于indexPath的位置的cell的布局属性
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath；
/*
 * 返回collectionView的内容的尺寸
 */
- (CGSize)collectionViewContentSize;

```

具体demo可以参考[GitHub链接](https://github.com/Guanzhangpeng/CustomCollectionViewLayout)

