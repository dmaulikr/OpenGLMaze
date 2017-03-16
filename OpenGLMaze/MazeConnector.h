//
//  MazeConnector.h
//  Assignment2
//
//  Created by Hank Lo on 2017-03-06.
//  Copyright © 2017 Einr. All rights reserved.
//

#ifndef MazeConnector_h
#define MazeConnector_h



#import <Foundation/Foundation.h>

struct CPMaze;


@interface mcmaze : NSObject {
    struct CPMaze *cpm;
}
-(void) CreateMaze;
-(BOOL) GetCellN :(int)r :(int)c;
-(BOOL) GetCellS :(int)r :(int)c;
-(BOOL) GetCellE :(int)r :(int)c;
-(BOOL) GetCellW :(int)r :(int)c;

@end

#endif /* MazeConnector_h */
