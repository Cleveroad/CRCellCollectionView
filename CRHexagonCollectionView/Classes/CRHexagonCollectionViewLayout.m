//
//  CRHexagonCollectionViewLayout.m
//  Pods
//
//  Created by Sergey Chuchukalo on 10/5/16.
//
//  Copyright © 2016 Cleveroad Inc. All rights reserved.

#import "CRHexagonCollectionViewLayout.h"

@interface CRHexagonCollectionViewLayout()

@property (assign, nonatomic) NSInteger itemsPerRow;
@property (assign, nonatomic) NSInteger itemsInlargeLine;
@property (assign, nonatomic) NSInteger verticalSpacing;
@property (assign, nonatomic) NSInteger cleanSizeForLargeLine;
@property (assign, nonatomic) NSInteger cleanSizeForShortLine;
@property (assign, nonatomic) NSInteger numberOfItems;
@property (assign, nonatomic) CGSize contentSize;
@property (assign, nonatomic) CGFloat lagreLineHoriConstOffset;
@property (assign, nonatomic) CGFloat smallLineHoriConstOffset;

@end

@implementation CRHexagonCollectionViewLayout
- (void)prepareLayout {
    [super prepareLayout];
    
    CGFloat itemWidth = self.itemSize.width;
    CGFloat itemHeight = self.itemSize.height;
    CGFloat horizontalSpacing = self.minimumInteritemSpacing;
    CGFloat collectionWidth = self.collectionView.frame.size.width;
    CGFloat collectionHeight = self.collectionView.frame.size.height;
    CGFloat itemWidthWithSpacing = self.scrollDirection == UICollectionViewScrollDirectionVertical ? self.itemSize.width + self.minimumInteritemSpacing: self.itemSize.height + self.minimumLineSpacing;
    self.itemsPerRow = self.scrollDirection == UICollectionViewScrollDirectionVertical ? (collectionWidth * 2 - itemWidth) / (itemWidthWithSpacing): (collectionHeight * 2 - itemHeight) / (itemWidthWithSpacing);
    self.itemsPerRow -= (self.itemsPerRow % 2 == 0 ) ? 1 : 0;
    self.itemsInlargeLine = self.itemsPerRow / 2 + 1;
    self.verticalSpacing = self.scrollDirection == UICollectionViewScrollDirectionVertical ? sqrt(pow(self.minimumLineSpacing + itemHeight,2) - pow(horizontalSpacing / 2 + itemHeight/2,2)) : sqrt(pow(self.minimumInteritemSpacing + itemWidth,2) - pow(self.minimumLineSpacing / 2 + itemWidth/2,2));
    self.cleanSizeForLargeLine = self.scrollDirection == UICollectionViewScrollDirectionVertical ? collectionWidth - itemWidthWithSpacing * (self.itemsInlargeLine - 1) : collectionHeight - itemWidthWithSpacing * (self.itemsInlargeLine - 1);
    
    self.cleanSizeForShortLine = self.scrollDirection == UICollectionViewScrollDirectionVertical ? collectionWidth - itemWidthWithSpacing * (self.itemsInlargeLine - 2) : collectionHeight - itemWidthWithSpacing * (self.itemsInlargeLine - 2);
    NSInteger numberOfSections = self.collectionView.numberOfSections;
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:numberOfSections - 1];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numberOfItems - 1 inSection:numberOfSections - 1];
    
    CGFloat contentHeight = self.scrollDirection == UICollectionViewScrollDirectionVertical ? [self centerForItemAtIndexPath:indexPath].y + ceil(itemHeight / 2) : [self centerForItemAtIndexPath:indexPath].x + ceil(itemWidth / 2);
    
    contentHeight += self.scrollDirection == UICollectionViewScrollDirectionVertical ? [self footerReferenceSizeInSection:self.collectionView.numberOfSections - 1].height :  [self footerReferenceSizeInSection:self.collectionView.numberOfSections - 1].width;
    
    self.contentSize = self.scrollDirection == UICollectionViewScrollDirectionVertical ? CGSizeMake(self.collectionView.bounds.size.width, contentHeight) : CGSizeMake( contentHeight, self.collectionView.bounds.size.height - 20);
    self.lagreLineHoriConstOffset = self.scrollDirection == UICollectionViewScrollDirectionVertical ? (self.cleanSizeForLargeLine + horizontalSpacing) / 2 : (self.cleanSizeForLargeLine + self.minimumLineSpacing) / 2;
    self.smallLineHoriConstOffset = self.scrollDirection == UICollectionViewScrollDirectionVertical ? (self.cleanSizeForShortLine + horizontalSpacing) / 2 : (self.cleanSizeForShortLine + self.minimumLineSpacing) / 2;
    self.numberOfItems = 0;
    for (int i = 0; i < self.collectionView.numberOfSections; i ++ ) {
        self.numberOfItems += [self.collectionView numberOfItemsInSection:i];
    }
}

- (CGSize)headerReferenceSizeInSection:(NSUInteger)section {
    if ([(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
        return [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:section];
    }
    return self.headerReferenceSize;
}

- (CGSize)footerReferenceSizeInSection:(NSUInteger)section {
    if ([(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
        return [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:section];
    }
    return self.footerReferenceSize;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
        return YES;
    }
    return NO;
}

- (CGSize)collectionViewContentSize {
    return self.contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.size = self.itemSize;
    attributes.center = [self centerForItemAtIndexPath:indexPath];
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributes = [NSMutableArray new];
    CGFloat collectionHeight = self.contentSize.height;
    CGFloat collectionWidth = self.contentSize.width;
    CGFloat countItemOnScreen = self.scrollDirection == UICollectionViewScrollDirectionVertical ? (self.numberOfItems / collectionHeight) * rect.size.height : (self.numberOfItems / collectionWidth) * rect.size.width;
    CGFloat rectPerItem = self.scrollDirection == UICollectionViewScrollDirectionVertical ? rect.size.height / countItemOnScreen:rect.size.width / countItemOnScreen ;
    CGFloat allHeaderAndFotterHeight = 0;
    
    for (int i = 0; i < self.collectionView.numberOfSections; i++) {
        allHeaderAndFotterHeight += self.scrollDirection == UICollectionViewScrollDirectionVertical ? [self headerReferenceSizeInSection:i].height + [self footerReferenceSizeInSection:i].height : [self headerReferenceSizeInSection:i].width + [self footerReferenceSizeInSection:i].width;
    }
    NSInteger firstShowihgItem = self.scrollDirection == UICollectionViewScrollDirectionVertical ? rect.origin.y / rectPerItem - self.itemsInlargeLine - allHeaderAndFotterHeight : rect.origin.x / rectPerItem - self.itemsInlargeLine - allHeaderAndFotterHeight;
    
    NSInteger lastShowihgItem = self.scrollDirection == UICollectionViewScrollDirectionVertical ? rect.origin.y / rectPerItem + countItemOnScreen + self.itemsInlargeLine + allHeaderAndFotterHeight : rect.origin.x / rectPerItem + countItemOnScreen + self.itemsInlargeLine + allHeaderAndFotterHeight;
    if (firstShowihgItem < 0) {
        firstShowihgItem = 0;
        lastShowihgItem = countItemOnScreen + self.itemsInlargeLine + self.itemsInlargeLine + allHeaderAndFotterHeight;
        if (lastShowihgItem > self.numberOfItems) {
            lastShowihgItem = self.numberOfItems;
        }
    }
    if (lastShowihgItem > self.numberOfItems) {
        lastShowihgItem = self.numberOfItems;
        firstShowihgItem = countItemOnScreen - self.itemsInlargeLine;
        if (firstShowihgItem < 0) {
            firstShowihgItem = 0;
        }
    }
    for (NSInteger i = firstShowihgItem; i < lastShowihgItem; i++) {
        NSInteger item = 0;
        NSInteger section = 0;
        NSInteger allItems = 0;
        for (int j = 0; j < self.collectionView.numberOfSections; j ++ ) {
            allItems += [self.collectionView numberOfItemsInSection:j];
            if (allItems > i) {
                section = j;
                item = i - allItems + [self.collectionView numberOfItemsInSection:j];
                break;
            }
        }

        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
        [layoutAttributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    for (NSUInteger idx = 0; idx <= self.collectionView.numberOfSections-1; ++idx) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
        CGPoint center = [self centerForItemAtIndexPath:indexPath];
        center.y -= self.scrollDirection == UICollectionViewScrollDirectionVertical ? (self.itemSize.height/2 + [self headerReferenceSizeInSection:idx].height): (self.itemSize.width/2 + [self headerReferenceSizeInSection:idx].width);
        UICollectionViewLayoutAttributes *layoutAttributess = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        layoutAttributess.frame = self.scrollDirection == UICollectionViewScrollDirectionVertical ?  CGRectMake(layoutAttributess.frame.origin.x, center.y, layoutAttributess.frame.size.width, layoutAttributess.frame.size.height) : CGRectMake(center.x, layoutAttributess.frame.origin.y, layoutAttributess.frame.size.width, layoutAttributess.frame.size.height);
        if (layoutAttributess) {
            if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                if ((rect.origin.y-10 <= layoutAttributess.frame.origin.y) && (rect.origin.y + 10 + rect.size.height >= layoutAttributess.frame.origin.y)) {
                    [layoutAttributes addObject:layoutAttributess];
                }
            } else {
                if ((rect.origin.x-10 <= layoutAttributess.frame.origin.x) && (rect.origin.x + 10 + rect.size.width >= layoutAttributess.frame.origin.x)) {
                    [layoutAttributes addObject:layoutAttributess];
                }
            }
        }
    }
    for (NSUInteger idx = 0; idx <= self.collectionView.numberOfSections - 1; ++idx) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:[self.collectionView numberOfItemsInSection:idx]-1 inSection:idx];
        CGPoint center = [self centerForItemAtIndexPath:indexPath];
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            center.y += self.itemSize.height/2;
        } else {
            center.x += self.itemSize.width/2;
        }
        UICollectionViewLayoutAttributes *layoutAttributess = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:indexPath];
        
        layoutAttributess.frame = self.scrollDirection == UICollectionViewScrollDirectionVertical ? CGRectMake(layoutAttributess.frame.origin.x, center.y, layoutAttributess.frame.size.width, layoutAttributess.frame.size.height):CGRectMake( center.x,layoutAttributess.frame.origin.y, layoutAttributess.frame.size.width, layoutAttributess.frame.size.height);
        if (layoutAttributess) {
            if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                if ((rect.origin.y-10 <= layoutAttributess.frame.origin.y) && (rect.origin.y + 10 + rect.size.height >= layoutAttributess.frame.origin.y)) {
                    [layoutAttributes addObject:layoutAttributess];
                }
            } else {
                if ((rect.origin.x-10 <= layoutAttributess.frame.origin.x) && (rect.origin.x + 10 + rect.size.width >= layoutAttributess.frame.origin.x)) {
                    [layoutAttributes addObject:layoutAttributess];
                }
            }
        }
    }
    return layoutAttributes;
}

- (CGPoint)centerForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row / self.itemsPerRow;
    NSInteger col = indexPath.row % self.itemsPerRow;
    CGFloat itemWidthWithSpacing = self.scrollDirection == UICollectionViewScrollDirectionVertical ? self.itemSize.width + self.minimumInteritemSpacing :self.itemSize.height + self.minimumLineSpacing;
    CGFloat halfHorizontalSpacing = self.scrollDirection == UICollectionViewScrollDirectionVertical ? self.minimumInteritemSpacing / 2 : self.minimumLineSpacing / 2;
    CGFloat horiOffset = 0;
    if (col < self.itemsInlargeLine) {
        horiOffset = itemWidthWithSpacing * col - halfHorizontalSpacing;
    } else {
        horiOffset = itemWidthWithSpacing * (col - self.itemsInlargeLine) - halfHorizontalSpacing;
    }
    NSInteger vertOffset = self.scrollDirection == UICollectionViewScrollDirectionVertical ? self.itemSize.height/2 - self.verticalSpacing + (indexPath.row / self.itemsPerRow) : self.itemSize.width/2 - self.verticalSpacing + (indexPath.row / self.itemsPerRow);
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:indexPath.section - 1];
    NSIndexPath *prewSectionIndexPath = [NSIndexPath indexPathForRow:numberOfItems - 1 inSection:indexPath.section - 1];
    if (prewSectionIndexPath.section >= 0 ) {
        vertOffset += self.scrollDirection == UICollectionViewScrollDirectionVertical ? [self centerForItemAtIndexPath:prewSectionIndexPath].y + ceil(self.itemSize.height / 2) : [self centerForItemAtIndexPath:prewSectionIndexPath].x + ceil(self.itemSize.width / 2);
    }
    vertOffset +=self.scrollDirection == UICollectionViewScrollDirectionVertical ?  [self headerReferenceSizeInSection:indexPath.section].height: [self headerReferenceSizeInSection:indexPath.section].width;
    if (indexPath.section != 0) {
        vertOffset += self.scrollDirection == UICollectionViewScrollDirectionVertical ? [self footerReferenceSizeInSection:indexPath.section - 1].height: [self footerReferenceSizeInSection:indexPath.section - 1].width;
    }
    if (self.itemsInlargeLine > col) {
        horiOffset += self.lagreLineHoriConstOffset;
    } else {
        horiOffset += self.smallLineHoriConstOffset;
        vertOffset += self.verticalSpacing;
    }
    CGFloat colPosition =  horiOffset;
    CGFloat rowPisition = (row + 0.5) * (self.verticalSpacing * 2) + vertOffset;
    if ( self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return CGPointMake(colPosition, rowPisition);
    } else {
        return CGPointMake(rowPisition, colPosition);
    }
}

@end
