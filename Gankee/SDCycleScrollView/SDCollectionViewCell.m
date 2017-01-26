//
//  SDCollectionViewCell.m
//  SDCycleScrollView
//
//  Created by aier on 15-3-22.
//  Copyright (c) 2015年 GSD. All rights reserved.
//


/*
 
 *********************************************************************************
 *
 * 🌟🌟🌟 新建SDCycleScrollView交流QQ群：185534916 🌟🌟🌟
 *
 * 在您使用此自动轮播库的过程中如果出现bug请及时以以下任意一种方式联系我们，我们会及时修复bug并
 * 帮您解决问题。
 * 新浪微博:GSD_iOS
 * Email : gsdios@126.com
 * GitHub: https://github.com/gsdios
 *
 * 另（我的自动布局库SDAutoLayout）：
 *  一行代码搞定自动布局！支持Cell和Tableview高度自适应，Label和ScrollView内容自适应，致力于
 *  做最简单易用的AutoLayout库。
 * 视频教程：http://www.letv.com/ptv/vplay/24038772.html
 * 用法示例：https://github.com/gsdios/SDAutoLayout/blob/master/README.md
 * GitHub：https://github.com/gsdios/SDAutoLayout
 *********************************************************************************
 
 */


#import "SDCollectionViewCell.h"
#import "UIView+SDExtension.h"

@implementation SDCollectionViewCell
{
    __weak UILabel *_titleLabel;
    NSParagraphStyle *_paragraphStyle;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupImageView];
        [self setupTitleLabel];
        [self setupBottomLine];
        [self setupLabels];
    }
    
    return self;
}

- (void)setTitleLabelBackgroundColor:(UIColor *)titleLabelBackgroundColor
{
    _titleLabelBackgroundColor = titleLabelBackgroundColor;
    _titleLabel.backgroundColor = titleLabelBackgroundColor;
}

- (void)setTitleLabelTextColor:(UIColor *)titleLabelTextColor
{
    _titleLabelTextColor = titleLabelTextColor;
    _titleLabel.textColor = titleLabelTextColor;
}

- (void)setTitleLabelTextFont:(UIFont *)titleLabelTextFont
{
    _titleLabelTextFont = titleLabelTextFont;
    _titleLabel.font = titleLabelTextFont;
}

- (void)setupImageView
{
    UIImageView *imageView = [[UIImageView alloc] init];
    _imageView = imageView;
    [self.contentView addSubview:imageView];
}

- (void)setupBottomLine {
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.91 alpha:1];
    _bottomLine = bottomLine;
    [self.contentView addSubview:bottomLine];
}

- (void)setupLabels {
    UILabel *descLabel = [[UILabel alloc] init];
    UILabel *categoryLabel  = [[UILabel alloc] init];
    UILabel *dateLable = [[UILabel alloc] init];
    descLabel.numberOfLines = 1;
    categoryLabel.numberOfLines = 1;
    dateLable.numberOfLines = 1;
    _descLabel = descLabel;
    _categoryLabel = categoryLabel;
    _dateLabel = dateLable;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 1.2;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _paragraphStyle = [paragraphStyle copy];
    
    [self.contentView addSubview:descLabel];
    [self.contentView addSubview:categoryLabel];
    [self.contentView addSubview:dateLable];
}

- (void)setDesc:(NSString *)desc {
    NSAttributedString *attributedDesc = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@  ", desc] attributes: @{
                               NSFontAttributeName: [UIFont systemFontOfSize:16 weight:UIFontWeightMedium],
                               NSParagraphStyleAttributeName: _paragraphStyle,
                               NSBaselineOffsetAttributeName: @(5),
                               NSForegroundColorAttributeName: [UIColor whiteColor],
                               NSBackgroundColorAttributeName: [UIColor colorWithRed:0.08 green:0.58 blue:0.53 alpha:1]}];
    _descLabel.attributedText = attributedDesc;
}

- (void)setCategory:(NSString *)category {
    NSAttributedString *attributedCategory = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@  ", category] attributes: @{
                                       NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightLight],
                                       NSParagraphStyleAttributeName: _paragraphStyle,
                                       NSBaselineOffsetAttributeName: @(1),
                                       NSForegroundColorAttributeName: [UIColor whiteColor],
                                       NSBackgroundColorAttributeName: [UIColor colorWithRed:0.08 green:0.58 blue:0.53 alpha:1]}];
    _categoryLabel.attributedText = attributedCategory;
}

- (void)setDate:(NSString *)date {
    NSAttributedString *attributedDate = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@  ", date] attributes: @{
                               NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightLight],
                               NSParagraphStyleAttributeName: _paragraphStyle,
                               NSBaselineOffsetAttributeName: @(1),
                               NSForegroundColorAttributeName: [UIColor whiteColor],
                               NSBackgroundColorAttributeName: [UIColor colorWithRed:0.08 green:0.58 blue:0.53 alpha:1]}];
    _dateLabel.attributedText = attributedDate;
}

- (void)setupTitleLabel
{
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    _titleLabel.hidden = YES;
    [self.contentView addSubview:titleLabel];
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];
    _titleLabel.text = [NSString stringWithFormat:@"   %@", title];
    if (_titleLabel.hidden) {
        _titleLabel.hidden = NO;
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.onlyDisplayText) {
        _titleLabel.frame = self.bounds;
    } else {
        _imageView.frame = self.bounds;
        _bottomLine.frame = CGRectMake(0, self.bounds.size.height - 0.4, self.bounds.size.width, 0.4);
        CGFloat titleLabelW = self.sd_width;
        CGFloat titleLabelH = _titleLabelHeight;
        CGFloat titleLabelX = 0;
        CGFloat titleLabelY = self.sd_height - titleLabelH;
        _titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
        _descLabel.frame = CGRectMake(16, self.bounds.size.height - 95, self.bounds.size.width - 30, 30);
        _categoryLabel.frame = CGRectMake(16, self.bounds.size.height - 65, self.bounds.size.width - 30, 20);
        _dateLabel.frame = CGRectMake(16, self.bounds.size.height - 40, self.bounds.size.width - 30, 20);
    }
}

@end
