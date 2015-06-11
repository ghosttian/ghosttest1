//
//  GinPublishTagCell.m
//  GinCore
//
//  Created by leizhu on 15/1/16.
//  Copyright (c) 2015年 leizhu. All rights reserved.
//

#import "GinPublishTagCell.h"
#import "UIColor+Utils.h"
#import "UIImage+Plus.h"

#define kIconSize 30.0

@interface GinPublishTagCell ()

@property(nonatomic,strong) UILabel *tagLabel;
@property(nonatomic,strong) UILabel *topicLabel;

@property(nonatomic,strong) CALayer *topLine;
@property(nonatomic,strong) CALayer *bottomLine;

@end

@implementation GinPublishTagCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor colorWithRGBHex:0xfff3f3f3];
        
        self.imageView.frame = CGRectMake(10, 7, kIconSize, kIconSize);
        self.imageView.image = [UIImage extensionImageNamed:@"video_write_icon_tag"];
        
        UILabel *tagLabel = [[UILabel alloc] init];
        tagLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        tagLabel.frame = CGRectMake(55, 0, self.frame.size.width-55-44, self.frame.size.height);
        tagLabel.font = [UIFont systemFontOfSize:16.0];
        tagLabel.textColor = [UIColor colorWithRGBHex:0xff22cccc];
        tagLabel.backgroundColor = [UIColor clearColor];
        self.tagLabel = tagLabel;
        [self.contentView addSubview:self.tagLabel];
        
        UILabel *topicLabel = [[UILabel alloc] init];
        topicLabel.font = [UIFont systemFontOfSize:16.0];
        topicLabel.textColor = [UIColor colorWithRGBHex:0xff55aaee];
        topicLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        topicLabel.backgroundColor = [UIColor clearColor];
        self.topicLabel = topicLabel;
        [self.contentView addSubview:self.topicLabel];
        
        UIImage *closeIcon = [UIImage extensionImageNamed:@"home_tl_ic_tips_close_nor"];
        UIButton *tagCloseButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-44, 0, 44, 44)];
        [tagCloseButton setImage:closeIcon forState:UIControlStateNormal];
        [self.contentView addSubview:tagCloseButton];
        self.closeButton = tagCloseButton;
        self.closeButton.hidden = YES;
        
        CALayer *topLine = [CALayer layer];
        topLine.frame = CGRectMake(0, 0, self.frame.size.width, 1);
        topLine.backgroundColor = [UIColor colorWithRGBHex:0xffe0e0df].CGColor;
        [self.layer addSublayer:topLine];
        self.topLine = topLine;
        
        CALayer *line = [CALayer layer];
        line.frame = CGRectMake(0, 44 - 1, self.frame.size.width, 1);
        line.backgroundColor = [UIColor colorWithRGBHex:0xffe0e0df].CGColor;
        [self.layer addSublayer:line];
        self.bottomLine = line;
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.tagLabel.text = nil;
    self.topicLabel.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.topLine.frame = CGRectMake(0, 0, self.frame.size.width, 1);
    self.bottomLine.frame = CGRectMake(0, 44 - 1, self.frame.size.width, 1);
    
    self.imageView.frame = CGRectMake(10, 7, kIconSize, kIconSize);
    self.closeButton.hidden = NO;
    self.closeButton.frame = CGRectMake(self.frame.size.width-44, 0, 44, 44);
    self.tagLabel.textColor = [UIColor colorWithRGBHex:0xff22cccc];
    
    CGFloat textLeft = 55.0;
    CGFloat maxWidth = self.frame.size.width - textLeft - 44 - 10;
    if (self.currentTag.length > 0 && self.currentTopic.length > 0) {
        self.tagLabel.text = self.currentTag;
        self.topicLabel.text = self.currentTopic;
        
        //layout labe
        
        CGSize tagSize = [self.currentTag sizeWithFont:self.tagLabel.font];
        CGSize topicSize = [self.currentTopic sizeWithFont:self.topicLabel.font];
        
        if ((tagSize.width + topicSize.width <= maxWidth) || tagSize.width <= maxWidth/2.0) {
            self.tagLabel.frame = CGRectMake(textLeft, 0, tagSize.width, self.frame.size.height);
            self.topicLabel.frame = CGRectMake(textLeft+tagSize.width+10, 0, maxWidth - tagSize.width, self.frame.size.height);
        } else {
            self.tagLabel.frame = CGRectMake(textLeft, 0, maxWidth/2.0, self.frame.size.height);
            self.topicLabel.frame = CGRectMake(textLeft + maxWidth/2.0 + 10, 0, maxWidth/2.0, self.frame.size.height);
        }
        
    } else {
        NSString *tagString = nil;
        if (self.currentTag.length > 0) {
            tagString = self.currentTag;
        } else if (self.currentTopic.length > 0) {
            tagString = self.currentTopic;
        } else {
            tagString = @"添加标签";
            self.closeButton.hidden = YES;
            self.tagLabel.textColor = [UIColor colorWithRGBHex:0xff323232];
        }
        self.tagLabel.text = tagString;
        
        self.tagLabel.frame = CGRectMake(textLeft, 0, maxWidth, self.frame.size.height);
    }

}

@end
