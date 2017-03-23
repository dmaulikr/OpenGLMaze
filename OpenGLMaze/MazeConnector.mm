//
//  MazeConnector.m
//  Assignment2
//
//  Created by Hank Lo on 2017-03-06.
//  Copyright © 2017 Einr. All rights reserved.
//

#import "MazeConnector.h"
#include "maze.h"

struct CPMaze {
    Maze *maze;
};

@interface mcmaze()
    -(MazeCell) GetCell :(int)r :(int)c;

@end

@implementation mcmaze

- (id)init {
    self = [super init];
    

    
    if (self) {
        cpm = new CPMaze;
        cpm->maze = new Maze(4, 4);
    }
    return self;
}

- (void) CreateMaze {
    cpm->maze->Create();
    
    // Dump the 2D view of the maze using ASCII text...
    
    int i, j;
    
    printf("2D overhead view of 3D maze:\n");
    
    for (i=4-1; i>=0; i--) {
        
        for (j=4-1; j>=0; j--) { // top
            
            printf(" %c ", cpm->maze->GetCell(i, j).southWallPresent ? '-' : ' ');
            
        }
        
        printf("\n");
        
        for (j=4-1; j>=0; j--) { // left/right
            
            printf("%c", cpm->maze->GetCell(i, j).eastWallPresent ? '|' : ' ');
            
            printf("%c", ((i+j) < 1) ? '*' : ' ');
            
            printf("%c", cpm->maze->GetCell(i, j).westWallPresent ? '|' : ' ');
            
        }
        
        printf("\n");
        
        for (j=4-1; j>=0; j--) { // bottom
            
            printf(" %c ", cpm->maze->GetCell(i, j).northWallPresent ? '-' : ' ');
            
        }
        
        printf("\n");
        
    }
}

-(BOOL) GetCellN :(int)r :(int)c {
    return cpm->maze->GetCell(r, c).northWallPresent;
}
-(BOOL) GetCellS :(int)r :(int)c {
    return cpm->maze->GetCell(r, c).southWallPresent;
}
-(BOOL) GetCellE :(int)r :(int)c {
    return cpm->maze->GetCell(r, c).eastWallPresent;
}
-(BOOL) GetCellW :(int)r :(int)c {
    return cpm->maze->GetCell(r, c).westWallPresent;
}


@end
