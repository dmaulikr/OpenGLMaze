//
//  ObjParser.h
//  OpenGLMaze
//
//  Created by Spencer Pollock on 2017-03-19.
//  Copyright © 2017 Einr. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface ObjParser : NSObject
- (void)parseFile: (NSString *)_path _vertices:(GLfloat **)_vertices _normals:(GLfloat **)_normals _textures:(GLfloat **)_textures _indicies:(GLuint **)_indicies;
- (void)copyGLfloat: (GLfloat *)from to:(GLfloat **)to count:(int)count;
- (void)copyGLuint: (GLuint *)from to:(GLuint **)to count:(int)count;
- (GLfloat **)convertArraytoGLfloat:(NSMutableArray *)ns;
- (GLuint **)convertArraytoGLuint:(NSMutableArray *)ns;
@end
