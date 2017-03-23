//
//  ObjParser.m
//  OpenGLMaze
//
//  Created by Spencer Pollock on 2017-03-19.
//  Copyright © 2017 Einr. All rights reserved.
//

#import "ObjParser.h"

@implementation ObjParser
- (void)parseFile: (NSString *)_path _vertices:(GLfloat **)_vertices _normals:(GLfloat **)_normals _textures:(GLfloat **)_textures _indices:(GLuint **)_indices _vcount:(GLuint **)_vcount _ncount:(GLuint **)_ncount _tcount:(GLuint **)_tcount _count:(GLuint **)_count
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
               **_vcount = **_vcount + 3;
           }
           if ([line hasPrefix:@"vn "]) {
               lineArray = [line componentsSeparatedByString:@" "];
               [n addObject:lineArray[1]];
               [n addObject:lineArray[2]];
               [n addObject:lineArray[3]];
               **_ncount = **_ncount + 3;
           }
           if ([line hasPrefix:@"vt "]) {
               lineArray = [line componentsSeparatedByString:@" "];
               [t addObject:lineArray[1]];
               [t addObject:lineArray[2]];
               **_tcount = **_tcount + 2;
           }
           if ([line hasPrefix:@"f "]) {
               lineArray = [line componentsSeparatedByString:@" "];
               for (int ff = 1; ff < lineArray.count; ff++) {
                   NSArray *temp = [lineArray[ff] componentsSeparatedByString:@"/"];
                   [i addObject:temp[0]];
                   [i addObject:temp[1]];
                   [i addObject:temp[2]];
                   **_count = **_count + 3;
               }
           }
       }
       [self convertArraytoGLuint:i];
       [self copyGLuint:&glu to:_indices count:**_count];
       [self convertArraytoGLfloat:v]; // sets glf
       GLfloat *tempv = malloc(sizeof(GLfloat) * (**_count));
       for(int ii = 0; ii < **_count; ii+=3) { // i < 108
           tempv[ii] = glf[(glu[ii] - 1) * 3];
           tempv[ii+1] = glf[(glu[ii] - 1) * 3 +1];
           tempv[ii+2] = glf[(glu[ii] - 1) * 3 +2];
       }
       **_vcount = **_count;
       [self copyGLfloat:&tempv to:_vertices count:**_vcount];
       [self convertArraytoGLfloat:t];
       GLfloat *tempt = malloc(sizeof(GLfloat) * (**_count));
       for(int ii = 1; ii < (**_count / 3) * 2; ii+=3) { // i < 108
           tempt[ii] = glf[(glu[ii] - 1) * 3];
           tempt[ii+1] = glf[(glu[ii] - 1) * 3 +1];
       }
       **_tcount = (**_count / 3) * 2;
       [self copyGLfloat:&tempt to:_textures count:**_tcount];
       [self convertArraytoGLfloat:n];
       GLfloat *tempn = malloc(sizeof(GLfloat) * (**_count));
       for(int ii = 2; ii < **_count; ii+=3) { // i < 108
           tempn[ii] = glf[(glu[ii] - 1) * 3];
           tempn[ii+1] = glf[(glu[ii] - 1) * 3 +1];
           tempn[ii+2] = glf[(glu[ii] - 1) * 3 +2];
       }
       **_ncount = **_count;
       [self copyGLfloat:&tempn to:_normals count:**_ncount];
   }
- (void)copyGLfloat: (GLfloat **)from to:(GLfloat **)to count:(GLuint)count {
    *to = (GLfloat*)malloc(sizeof(GLfloat) * count);
    memcpy(*to, *from, (sizeof(GLfloat) * count));
}
- (void)copyGLuint: (GLuint **)from to:(GLuint **)to count:(GLuint)count {
    *to = (GLuint*)malloc(sizeof(GLuint) * count);
    memcpy(*to, *from, (sizeof(GLuint) * count));
}
- (void)convertArraytoGLfloat:(NSMutableArray *)ns {
    glf = realloc(glf, sizeof(GLfloat) * [ns count]);
    if (glf != NULL) {
        for (int i = 0; i < [ns count]; i++) {
            glf[i] = [[ns objectAtIndex:i] floatValue];
        }
    }
}
- (void)convertArraytoGLuint:(NSMutableArray *)ns {
    glu = realloc(glu, sizeof(GLuint) * [ns count]);
    if (glu != NULL) {
        for (int i = 0; i < [ns count]; i++) {
            int t = ([[ns objectAtIndex:i] intValue]);
            glu[i] = (GLuint) t;
        }
    }
}
- (void)reorder:(GLuint **)_count _i:(GLuint **)_i _v:(GLfloat **)_v _t:(GLfloat **)_t _n:(GLfloat **)_n {
    GLfloat *tempv = malloc(sizeof(GLfloat) * (**_count));
    GLfloat *tempt = malloc(sizeof(GLfloat) * (**_count));
    GLfloat *tempn = malloc(sizeof(GLfloat) * (**_count));
    
    // Reorder based on faces:
        // f 1/1/1 2/2/2/ 3/3/3 needs v 1 2 3 t 1 2 3 n 1 2 3 in order
    // for (int i = 0, j = 0; i < **_count / 3; i++, j+=3) {
    //     tempv[i] = *_v[_i[j] - 1];
    //     tempt[i] = *_t[_i[j+1] - 1];
    //     tempn[i] = *_n[_i[j+2] - 1];
    // }
    
    
    // for (i = 0, j = 0; i < (**_count / 2); i++, j+=) {
        
    // }
    
    [self copyGLfloat:&tempv to:_v count:(**_count / 3)];
    [self copyGLfloat:&tempt to:_t count:(**_count / 3)];
    [self copyGLfloat:&tempn to:_n count:(**_count / 3)];
}
@end
