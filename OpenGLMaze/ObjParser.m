//
//  ObjParser.m
//  OpenGLMaze
//
//  Created by Spencer Pollock on 2017-03-19.
//  Copyright © 2017 Einr. All rights reserved.
//

#import "ObjParser.h"

@implementation ObjParser
- (void)parseFile: (NSString *)_path _vertices:(GLfloat **)_vertices _normals:(GLfloat **)_normals _textures:(GLfloat **)_textures _indicies:(GLuint **)_indicies _vcount:(GLuint **)_vcount _ncount:(GLuint **)_ncount _tcount:(GLuint **)_tcount _count:(GLuint **)_count
   {
       NSArray *lineArray;
       NSMutableArray   *v = [[NSMutableArray alloc] init],
                        *n = [[NSMutableArray alloc] init],
                        *t = [[NSMutableArray alloc] init],
                        *i = [[NSMutableArray alloc] init];
       NSString *fileContents = [NSString stringWithContentsOfFile:_path encoding:NSUTF8StringEncoding error:NULL];
       *_vcount = malloc(sizeof(GLuint));
       *_ncount = malloc(sizeof(GLuint));
       *_tcount = malloc(sizeof(GLuint));
       *_count = malloc(sizeof(GLuint));
    //    [v addObject:@"0"];
    //    [n addObject:@"0"];
    //    [t addObject:@"0"];
    //    [i addObject:@"0"]; // Because drawing starts at index 1 this could cause an issue
       for (NSString *line in [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]) {
           if ([line hasPrefix:@"v "]) {
               lineArray = [line componentsSeparatedByString:@" "];
               [v addObject:lineArray[1]];
               [v addObject:lineArray[2]];
               [v addObject:lineArray[3]];
               **_vcount = **_vcount + 1;
           }
           if ([line hasPrefix:@"vn "]) {
               lineArray = [line componentsSeparatedByString:@" "];
               [n addObject:lineArray[1]];
               [n addObject:lineArray[2]];
               [n addObject:lineArray[3]];
               **_ncount = **_ncount + 1;
           }
           if ([line hasPrefix:@"vt "]) {
               lineArray = [line componentsSeparatedByString:@" "];
               [t addObject:lineArray[1]];
               [t addObject:lineArray[2]];
               **_tcount = **_tcount + 1;
           }
           if ([line hasPrefix:@"f "]) {
               lineArray = [line componentsSeparatedByString:@" "];
               for (int ff = 1; ff < lineArray.count; ff++) {
                   NSArray *temp = [lineArray[ff] componentsSeparatedByString:@"/"];
                   [i addObject:temp[0]];
                   [i addObject:temp[1]];
                   [i addObject:temp[2]];
                   **_count = **_count + 1;
               }
           }
       }
       [self convertArraytoGLfloat:v]; // sets glf
       [self copyGLfloat:&glf to:_vertices count:**_vcount];
       [self convertArraytoGLfloat:n];
       [self copyGLfloat:&glf to:_normals count:**_ncount];
       [self convertArraytoGLfloat:t];
       [self copyGLfloat:&glf to:_textures count:**_tcount];
       [self convertArraytoGLuint:i];
       [self copyGLuint:&glu to:_indicies count:**_count];
   }
- (void)copyGLfloat: (GLfloat **)from to:(GLfloat **)to count:(GLuint)count {
    *to = malloc(sizeof(GLfloat) * count);
    memcpy(*to, *from, (sizeof(GLfloat) * count));
}
- (void)copyGLuint: (GLuint **)from to:(GLuint **)to count:(GLuint)count {
    *to = malloc(sizeof(GLuint) * count);
    memcpy(*to, *from, (sizeof(GLuint) * count));
}
- (void)convertArraytoGLfloat:(NSMutableArray *)ns {
    glf = realloc(glf, sizeof([ns count]));
    if (glf != NULL) {
        for (int i = 0; i < [ns count]; i++) {
            glf[i] = (GLfloat) [[ns objectAtIndex:i] floatValue];
        }
    }
}
- (void)convertArraytoGLuint:(NSMutableArray *)ns {
    glu = realloc(glu, sizeof([ns count]));
    if (glu != NULL) {
        for (int i = 0; i < [ns count]; i++) {
            glu[i] = (GLuint) [[ns objectAtIndex:i] floatValue];
        }
    }
}
@end
