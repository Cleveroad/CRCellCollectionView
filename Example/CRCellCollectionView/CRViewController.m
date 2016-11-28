//
//  CRViewController.m
//  CRCellCollectionView
//
//  Created by Sergey Chuchukalo on 10/05/2016.
//
//  Copyright © 2016 Cleveroad Inc. All rights reserved.

#import "CRViewController.h"
#import "CRCollectionViewCell.h"
#include <stdlib.h>

@interface CRViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@property (strong, nonatomic) IBOutletCollection(UICollectionView) NSArray *collectionViewArray;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonArray;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *markView;
@property (assign, nonatomic) NSInteger numberOfSelectedCollectionView;

@end

@implementation CRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    self.numberOfSelectedCollectionView = 0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    for (int i = 1; i < self.collectionViewArray.count; i++) {
        UICollectionView *collectionView = self.collectionViewArray[i];
        [self hideItemInCollectionView:collectionView];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([collectionView isEqual:self.collectionViewArray[0]]) {
        return 50;
    }
    if ([collectionView isEqual:self.collectionViewArray[1]]) {
        return 20;
    }
    if ([collectionView isEqual:self.collectionViewArray[2]]) {
        return 6;
    }
    return 18;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CRCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Abstract%i",arc4random_uniform(30)]];
    cell.layer.cornerRadius = cell.frame.size.height/2;
    if (![collectionView isEqual:self.collectionViewArray[self.numberOfSelectedCollectionView]]) {
        cell.alpha = 0;
    }
    return cell;
}

- (IBAction)changeSelectedCollectionView:(UIButton *)sender {
    NSInteger selectedButton = 0;
    for (int i = 0; i < self.buttonArray.count; i++) {
        if ([self.buttonArray[i] isEqual:sender]) {
            selectedButton = i;
            [self showItemInCollectionView:self.collectionViewArray[i]];
        } else {
            [self hideItemInCollectionView:self.collectionViewArray[i]];
        }
    }
    if (self.numberOfSelectedCollectionView != selectedButton) {
        if (selectedButton > self.numberOfSelectedCollectionView) {
            for (NSInteger i = self.numberOfSelectedCollectionView; i <=selectedButton; i++ ) {
                if (i != self.numberOfSelectedCollectionView) {
                    [self moveUpCollectionView:self.collectionViewArray[i - 1]];
                    UICollectionView *collection = self.collectionViewArray[i];
                    [self moveUpButton:self.buttonArray[i] toDistance:collection.frame.size.height];
                    UIButton *button = self.buttonArray[i];
                    CGFloat distatce = collection.frame.size.height - button.frame.size.height;
                    [self moveUpMark:self.markView[i-1] toDistance:distatce];
                }
            }
        } else {
            for (NSInteger i = selectedButton; i <=self.numberOfSelectedCollectionView; i++ ) {
                if (i != selectedButton) {
                    [self moveDownCollectionView:self.collectionViewArray[i - 1]];
                    UICollectionView *collection = self.collectionViewArray[i];
                    [self moveDownButton:self.buttonArray[i] toDistance:collection.frame.size.height];
                    UIButton *button = self.buttonArray[i];
                    CGFloat distatce = collection.frame.size.height - button.frame.size.height;
                    [self moveDownMark:self.markView[i-1] toDistance:distatce];
                }
            }
        }
        self.numberOfSelectedCollectionView = selectedButton;
    }
}

- (void)moveUpMark:(UIView *)mark toDistance: (NSInteger)distance {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frameMark = mark.frame;
        frameMark.origin.y -= distance ;
        mark.frame = frameMark;
    }];
}

- (void)moveDownMark:(UIView *)mark toDistance: (NSInteger)distance {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frameMark = mark.frame;
        frameMark.origin.y += distance;
        mark.frame = frameMark;
    }];
}

- (void)moveUpButton:(UIButton*)button toDistance: (NSInteger)distance {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frameButton = button.frame;
        frameButton.origin.y -= distance - frameButton.size.height;
        button.frame = frameButton;
    }];
}

- (void)moveDownButton:(UIButton*)button toDistance: (NSInteger)distance {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frameButton = button.frame;
        frameButton.origin.y += distance - frameButton.size.height;
        button.frame = frameButton;
    }];
}

- (void)moveUpCollectionView:(UICollectionView*)collectionView {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frameCollectionView = collectionView.frame;
        frameCollectionView.origin.y -= frameCollectionView.size.height - 75;
        collectionView.frame = frameCollectionView;
    }];
}

- (void)moveDownCollectionView:(UICollectionView*)collectionView {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frameCollectionView = collectionView.frame;
        frameCollectionView.origin.y += frameCollectionView.size.height - 75;
        collectionView.frame = frameCollectionView;
    }];
}

- (void)hideItemInCollectionView:(UICollectionView *)collectionView {
    for (UIView *temp in collectionView.subviews) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            temp.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
            temp.alpha = 0;
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)showItemInCollectionView:(UICollectionView *)collectionView {
    for (UIView *temp in collectionView.subviews) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            temp.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
            temp.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }
}

@end
