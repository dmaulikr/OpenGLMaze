//
//  ObjParser.h
//  OpenGLMaze
//
//  Created by Spencer Pollock on 2017-03-19.
//  Copyright © 2017 Einr. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface ObjParser : NSObject
{
    GLfloat *glf;
    GLuint *glu;
}
- (void)parseFile: (NSString *)_path _vertices:(GLfloat **)_vertices _normals:(GLfloat **)_normals _textures:(GLfloat **)_textures _indices:(GLuint **)_indices _vcount:(GLuint **)_vcount _ncount:(GLuint **)_ncount _tcount:(GLuint **)_tcount _count:(GLuint **)_count;
- (void)copyGLfloat: (GLfloat **)from to:(GLfloat **)to count:(GLuint)count;
- (void)copyGLuint: (GLuint **)from to:(GLuint **)to count:(GLuint)count;
- (void)convertArraytoGLfloat:(NSMutableArray *)ns;
- (void)convertArraytoGLuint:(NSMutableArray *)ns;
- (void)reorder:(GLuint **)_count _i:(GLuint **)_i _v:(GLfloat **)_v _t:(GLfloat **)_t _n:(GLfloat **)_n;
@end
