//
//  ALAssetsLibrary category to handle a custom photo album
//
//  Created by aidenluo on 07/31/13.
//  Copyright (c) 2013 aidenluo. All rights reserved.
//

#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@implementation ALAssetsLibrary(CustomPhotoAlbum)

-(void)saveImage:(UIImage*)image toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock
{
    //write the image data to the assets library (camera roll)
    [self writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation
                       completionBlock:^(NSURL* assetURL, NSError* error) {
                           
                           //error handling
                           if (error!=nil) {
                               completionBlock(error);
                               return;
                           }
                           
                           //add the asset to the custom photo album
                           [self addAssetURL: assetURL
                                     toAlbum:albumName
                         withCompletionBlock:completionBlock];
                           
                       }];
}

- (void)saveVideo:(NSURL*)videoURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock
{
    [self writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:^(NSURL *assetURL, NSError *error) {
        //error handling
        if (error != nil)
        {
            completionBlock(error);
            return;
        }
        //add the asset to the custom photo album
        [self addAssetURL:assetURL toAlbum:albumName withCompletionBlock:completionBlock];
        
    }];
}

-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock
{
    __block BOOL albumWasFound = NO;
    __block ALAssetsGroup *tmpGroup;
    
    //search all photo albums in the library
    [self enumerateGroupsWithTypes:ALAssetsGroupAll
                        usingBlock:^(ALAssetsGroup *group, BOOL *stop) {

                            if (group)
                            {
                                tmpGroup = group;
                            }
                            //compare the names of the albums
                            if (group && ([albumName compare: [group valueForProperty:ALAssetsGroupPropertyName]]==NSOrderedSame)) {
                                
                                //target album is found
                                albumWasFound = YES;
                                
                                //get a hold of the photo's asset instance
                                [self assetForURL: assetURL 
                                      resultBlock:^(ALAsset *asset) {
                                                  
                                          //add photo to the target album
                                          NSError* error = nil;
                                          if (![group addAsset: asset])
                                          {
                                              error = [NSError errorWithDomain:@"Asset" code:10001 userInfo:nil];
                                          }
                                          
                                          
                                          //run the completion block
                                          completionBlock(error);
                                          
                                      } failureBlock: completionBlock];

                                //album was found, bail out of the method
                                return;
                            }
                            
                            if (group==nil && albumWasFound==NO) {
                                //photo albums are over, target album does not exist, thus create it
                                
                                __weak ALAssetsLibrary* weakSelf = self;

                                //create new assets album
                                [self addAssetsGroupAlbumWithName:albumName 
                                                      resultBlock:^(ALAssetsGroup *group) {
                                                                  
                                                          //get the photo's instance
                                                          [weakSelf assetForURL: assetURL 
                                                                        resultBlock:^(ALAsset *asset) {

                                                                            //add photo to the target album
                                                                            NSError* error = nil;
                                                                            if (![group addAsset: asset])
                                                                            {
                                                                                [tmpGroup addAsset:asset];
                                                                            }
                                                                            
                                                                            //run the completion block
                                                                            completionBlock(error);

                                                                        } failureBlock: completionBlock];
                                                          
                                                      } failureBlock: completionBlock];

                                //should be the last iteration anyway, but just in case
                                return;
                            }
                            
                        } failureBlock: completionBlock];
    
}

@end
