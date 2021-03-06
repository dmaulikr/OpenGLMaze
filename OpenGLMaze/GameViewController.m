//
//  GameViewController.m
//  Assignment2
//
//  Created by Hank Lo on 2017-03-06.
//  Copyright © 2017 Einr. All rights reserved.
//

#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>
#import "MazeConnector.h"
#import "ObjParser.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_MODELVIEW_MATRIX,
    /* more uniforms needed here... */
    UNIFORM_TEXTURE,
    UNIFORM_FLASHLIGHT_POSITION,
    UNIFORM_DIFFUSE_LIGHT_POSITION,
    UNIFORM_SHININESS,
    UNIFORM_AMBIENT_COMPONENT,
    UNIFORM_DIFFUSE_COMPONENT,
    UNIFORM_SPECULAR_COMPONENT,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

@interface tile : NSObject {
@public int c;
@public int r;
@public BOOL nwe;
@public BOOL swe;
@public BOOL ewe;
@public BOOL wwe;
}
@end

@implementation tile @end

GLfloat gCubeVertexData[216] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};

@interface GameViewController () {
    GLuint _program;
    // Shader uniforms
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix4 _modelViewMatrix;
    GLKMatrix3 _normalMatrix;
    
    // Lighting parameters
    /* specify lighting parameters here...e.g., GLKVector3 flashlightPosition; */
    GLKVector3 flashlightPosition;
    GLKVector3 diffuseLightPosition;
    GLKVector4 diffuseComponent;
    float shininess;
    GLKVector4 specularComponent;
    GLKVector4 ambientComponent;
    
    // Transformation parameters
    float _rotation;
    float xRot, yRot;
    CGPoint dragStart;
    CGPoint posPoint;
    
    // Shape vertices, etc. and textures
    GLfloat *vertices, *normals, *texCoords;
    GLuint numIndices, *indices;
    GLfloat *mvertices, *mnormals, *mtextures;
    GLuint *mvcount, *mncount, *mtcount, *micount, *mindices;
    /* texture parameters ??? */
    GLuint crateTexture;
    GLuint CT1;
    GLuint CT2;
    GLuint CT3;
    GLuint CT4;
    GLuint CT5;
    GLuint cubeTex;
    
    // GLES buffer IDs
    GLuint _vertexArray;
    GLuint _vertexBuffers[3];
    GLuint _indexBuffer;
    GLuint _mvertexArray;
    GLuint _mvertexBuffers[3];
    GLuint _mindexBuffer;

    __weak IBOutlet UILabel *daynight;
    __weak IBOutlet UILabel *flashlight;
    __weak IBOutlet UILabel *fog;
        __weak IBOutlet UILabel *fogamt;
    __weak IBOutlet UISlider *fogamnt;
    __weak IBOutlet UISwitch *fogswitch;
    
    __weak IBOutlet UISwitch *flashlightswitch;
    __weak IBOutlet UISwitch *daynightswitch;
    mcmaze *lemaze;
    
    float moveZ;
    float moveX;
    
    float fogalpha;
    
    NSMutableArray *tilearray;
    GLKMatrix4 projectionMatrix;
    GLKMatrix4 baseModelViewMatrix;
    
    float monkeyXPos;
    float monkeyYPos; // note: this is a misnomer and actually is the z value
    float monkeyXPosUser;
    float monkeyYPosUser;
    float monkeyZPosUser;
    float monkeyRotateValue;
    float scalevalue;
    BOOL moving;
    BOOL canmove;
    float moved;
    int movingdir;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    lemaze = [[mcmaze alloc] init];
    [lemaze CreateMaze];
    
    fogalpha = 1;
    scalevalue = 1;
    
    tilearray = [[NSMutableArray alloc] initWithCapacity:16];
    
    daynight.textColor = [UIColor redColor];
    fog.textColor = [UIColor redColor];
    fogamt.textColor = [UIColor redColor];
    flashlight.textColor = [UIColor redColor];

    [self setupGL];
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    // Load shaders
    [self loadShaders];

    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_MODELVIEW_MATRIX] = glGetUniformLocation(_program, "modelViewMatrix");
    /* more needed here... */
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_program, "texture");
    uniforms[UNIFORM_FLASHLIGHT_POSITION] = glGetUniformLocation(_program, "flashlightPosition");
    uniforms[UNIFORM_DIFFUSE_LIGHT_POSITION] = glGetUniformLocation(_program, "diffuseLightPosition");
    uniforms[UNIFORM_SHININESS] = glGetUniformLocation(_program, "shininess");
    uniforms[UNIFORM_AMBIENT_COMPONENT] = glGetUniformLocation(_program, "ambientComponent");
    uniforms[UNIFORM_DIFFUSE_COMPONENT] = glGetUniformLocation(_program, "diffuseComponent");
    uniforms[UNIFORM_SPECULAR_COMPONENT] = glGetUniformLocation(_program, "specularComponent");
    
    // Set up lighting parameters
    /* set values, e.g., flashlightPosition = GLKVector3Make(0.0, 0.0, 1.0); */
    flashlightPosition = GLKVector3Make(0.0, 0.0, 0.0);
    diffuseLightPosition = GLKVector3Make(0.0, 1.0, 0.0);
    diffuseComponent = GLKVector4Make(0.8, 0.1, 0.1, 1.0);
    shininess = 100.0;
    specularComponent = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    ambientComponent = GLKVector4Make(0.9, 0.9, 0.9, 1.0);
    
    // Initialize GL and get buffers
    glEnable(GL_DEPTH_TEST);
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(3, _vertexBuffers);
    glGenBuffers(1, &_indexBuffer);
    
    // Generate vertices
    int numVerts;
    numIndices = generateCube(1.5, &vertices, &normals, &texCoords, &indices, &numVerts);
    
    // Set up GL buffers
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffers[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*numVerts, vertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffers[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*numVerts, normals, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffers[2]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*numVerts, texCoords, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 2*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int) * numIndices, indices, GL_STATIC_DRAW);
    
    // Load in and set texture
    /* use setupTexture to create crate texture */
    crateTexture = [self setupTexture:@"crate.jpg"];
    CT1 = [self setupTexture:@"c1.jpg"];
    CT2 = [self setupTexture:@"c2.jpg"];
    CT3 = [self setupTexture:@"c3.jpg"];
    CT4 = [self setupTexture:@"c4.jpg"];
    CT5 = [self setupTexture:@"c5.jpg"];
    cubeTex = [self setupTexture:@"cube2.png"];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, crateTexture);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);

#pragma mark Load .OBJ Model
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [mainBundle pathForResource:@"cube2" ofType:@"obj"];
    ObjParser *objParse = [[ObjParser alloc] init];
    [objParse parseFile:path _vertices:&mvertices _normals:&mnormals _textures:&mtextures _indices:&mindices _vcount:&mvcount _ncount:&mncount _tcount:&mtcount _count:&micount];
    
    glGenVertexArraysOES(1, &_mvertexArray); // number of objects to generate, pointer to arrays
    glBindVertexArrayOES(_mvertexArray);
    
    glGenBuffers(3, _mvertexBuffers);
    glGenBuffers(1, &_mindexBuffer);
    
    // Set up GL buffers - Monkey
    glBindBuffer(GL_ARRAY_BUFFER, _mvertexBuffers[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * (*mvcount), mvertices, GL_STATIC_DRAW);
//    for(int i = 0; i < *mvcount; i+=3) NSLog(@"%f %f %f", mvertices[i], mvertices[i+1], mvertices[i+2]);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 3*sizeof(GLfloat), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ARRAY_BUFFER, _mvertexBuffers[2]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * (*mtcount), mtextures, GL_STATIC_DRAW);
//    for(int i = 0; i < *mtcount; i+=2) NSLog(@"%f %f", mtextures[i], mtextures[i+1]);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 2*sizeof(GLfloat), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ARRAY_BUFFER, _mvertexBuffers[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * (*mncount), mnormals, GL_STATIC_DRAW);
//    for(int i = 0; i < *mncount; i+=3) NSLog(@"%f %f %f", mnormals[i], mnormals[i+1], mnormals[i+2]);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 3*sizeof(GLfloat), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _mindexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLuint) * (*micount), mindices, GL_STATIC_DRAW);
//    for(int i = 0; i < *micount; i+=9) NSLog(@"%d/%d/%d, %d/%d/%d, %d/%d/%d", mindices[i], mindices[i+1], mindices[i+2], mindices[i+3], mindices[i+4], mindices[i+5], mindices[i+6], mindices[i+7], mindices[i+8]);
    
    glBindVertexArrayOES(0);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    // Delete GL buffers
    glDeleteBuffers(3, _vertexBuffers);
    glDeleteBuffers(1, &_indexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    // Delete vertices buffers
    if (vertices)
        free(vertices);
    if (indices)
        free(indices);
    if (normals)
        free(normals);
    if (texCoords)
        free(texCoords);
    
    // Delete shader program
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    _rotation += self.timeSinceLastUpdate * 0.5f;
    
    if (fogswitch.on) {
        
    }
    
    if (daynightswitch.on) {
        ambientComponent = GLKVector4Make(0.2, 0.2, 0.2, 1.0);
    } else {
        ambientComponent = GLKVector4Make(0.9, 0.9, 0.9, 1.0);
    }
    
    if (flashlightswitch.on) {
        specularComponent = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    } else {
        specularComponent = GLKVector4Make(0.0, 0.0, 0.0, 0.0);
    }
    
    [tilearray removeAllObjects];
    
    //set up tiles
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j< 4; j++) {
            tile *t = [[tile alloc] init];
            
            t->swe = [lemaze GetCellN:i :j];
            t->nwe = [lemaze GetCellS:i :j];
            t->ewe = [lemaze GetCellE:i :j];
            t->wwe = [lemaze GetCellW:i :j];
          
            t->c = j;
            t->r = i;
            
            
            [tilearray addObject:t];
            
        }
    }
    
# pragma mark ObjectMovement
    // monkey movement
    if (canmove) { // By Default this is false, setup so that we double tap to stop moving
        // randomly move monkey in the maze
        // current position = monkeyXPos and monekyYPos
        
        // see what walls are around me
        for (tile *ct in tilearray) {
            if (!moving) {
                //NSLog(@"NOTMOVING");
                if ((ct->c == (int) monkeyXPos) && (ct->r == (int) monkeyYPos)) {
                    int rr = arc4random_uniform(4);
                       // NSLog(@"POS:%d, %d, %d, %d", ct->nwe, ct->ewe, ct->swe, ct->wwe);
                       // NSLog(@"PREPOS1:%f, %f, %d", monkeyXPos, monkeyYPos, rr);
                    
                        switch (rr) {
                            case 0:
                                if ((!ct->nwe) && (monkeyYPos + 1 <= 3)) {
                                    // move north, which is -z
                                    //monkeyYPos = monkeyYPos + 1;
                                    movingdir = 0;
                                    moving = true;
                                    break;
                                }
                            case 1:
                                if ((!ct->ewe) && (monkeyXPos +1 <=3 )) {
                                    // move right, which is +x
                                    //monkeyXPos = monkeyXPos + 1;
                                    movingdir = 1;
                                    moving = true;
                                    break;
                                }
                            
                            case 2:
                                if ((!ct->swe) && (monkeyYPos -1 >= 0)) {
                                    // move back, which is +z
                                    //monkeyYPos = monkeyYPos - 1;
                                    movingdir = 2;
                                    moving = true;
                                    break;
                                }
                            case 3:
                                if ((!ct->wwe) && (monkeyXPos -1 >= 0)) {
                                    // move left, which is -x
                                    //monkeyXPos = monkeyXPos - 1;
                                    movingdir = 3;
                                    moving = true;
                                }
                            break;
                        }
                    
                }

            }
        }
        if (moving) {
            if (moved >= 1) {
                moving = false;
                moved = 0;
                movingdir = 5;
                monkeyXPos = (int) roundf(monkeyXPos);
                monkeyYPos = (int) roundf(monkeyYPos);
            } else {
                switch (movingdir) {
                    case 0:
                        monkeyYPos = monkeyYPos + 0.05f;
                        moved += 0.05f;
                        break;
                    case 1:
                        monkeyXPos = monkeyXPos + 0.05f;
                        moved += 0.05f;
                        break;
                    case 2:
                        monkeyYPos = monkeyYPos - 0.05f;
                        moved += 0.05f;
                        break;
                    case 3:
                        monkeyXPos = monkeyXPos - 0.05f;
                        moved += 0.05f;
                        break;
                    default:
                        break;
                }
            }
        }
    }
    if (monkeyYPos <= 0) {
        monkeyYPos = 0;
    }
    
    if (abs((int) monkeyYPos) >= 3) {
        monkeyYPos = 3;
    }
    
    if (monkeyXPos <= 0) {
        monkeyXPos = 0;
    }
    
    if (abs((int) monkeyXPos) >= 3) {
        monkeyXPos = 3;
    }
}

- (IBAction)panning:(UIPanGestureRecognizer *)sender {
    
    if ((sender.state == UIGestureRecognizerStateBegan)
        || (sender.state == UIGestureRecognizerStateChanged)) {
        CGPoint x = [sender velocityInView:self.view];
        
        posPoint.x += x.x/1000;
        posPoint.y += x.y/1000;
        }
}
- (IBAction)reset:(UITapGestureRecognizer *)sender {
    posPoint.x = 0;
    posPoint.y = 0;
}

- (IBAction)canMonkeyMove:(UITapGestureRecognizer *)sender {
    
    if (canmove) {
        canmove = false;
    } else {
        canmove = true;
        monkeyYPosUser = 0;
        monkeyXPosUser = 0;
        monkeyZPosUser = 0;
        scalevalue = 1;
        monkeyRotateValue = 0;
    }
}

- (IBAction)panMonkey:(UIPanGestureRecognizer *)sender {
    if (!canmove) {
        if ((sender.state == UIGestureRecognizerStateBegan)
            || (sender.state == UIGestureRecognizerStateChanged)) {
            CGPoint x = [sender velocityInView:self.view];
            
            monkeyXPosUser += x.x/1000;
            monkeyZPosUser += x.y/1000;
            
            NSLog(@"MXY: %f, %f", monkeyXPosUser, monkeyZPosUser);
        }
    }
}
// unused
- (IBAction)panMonkeyZ:(UIPanGestureRecognizer *)sender {
}
- (IBAction)scaleMonkey:(UIPinchGestureRecognizer *)sender {
    if (!canmove) {
        scalevalue = sender.scale;
    }
}
- (IBAction)rotateMonkey:(UIRotationGestureRecognizer *)sender {
    
    if (!canmove) {
        if ((sender.state == UIGestureRecognizerStateBegan)
            || (sender.state == UIGestureRecognizerStateChanged)) {
         
//            CGAffineTransform t = CGAffineTransformMakeRotation([sender rotation]);
            
            monkeyRotateValue = [sender rotation];
            
            
        }
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // Clear window
    glClearColor(0.7f, 0.7f, 0.7f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Select VAO and shaders
    glBindVertexArrayOES(_vertexArray);
    glUseProgram(_program);
    
    // Set up base model view matrix (place camera)
    baseModelViewMatrix = GLKMatrix4MakeTranslation(posPoint.x, -1, posPoint.y -6.0f);
    baseModelViewMatrix = GLKMatrix4RotateX(baseModelViewMatrix, 1.5);
    
    // Set up model view matrix (place model in world)
    _modelViewMatrix = baseModelViewMatrix;
    _modelViewMatrix = GLKMatrix4Translate(_modelViewMatrix, 0, -.5, 1);
    _modelViewMatrix = GLKMatrix4Rotate(_modelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
    _modelViewMatrix = GLKMatrix4Scale(_modelViewMatrix, .5,.5,.5);
    
    // Calculate normal matrix
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(_modelViewMatrix), NULL);
    
    // Calculate projection matrix
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, _modelViewMatrix);

    
    // Set up uniforms
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, 0, _modelViewMatrix.m);
    /* set lighting parameters... */
    glUniform3fv(uniforms[UNIFORM_FLASHLIGHT_POSITION], 1, flashlightPosition.v);
    glUniform3fv(uniforms[UNIFORM_DIFFUSE_LIGHT_POSITION], 1, diffuseLightPosition.v);
    glUniform4fv(uniforms[UNIFORM_DIFFUSE_COMPONENT], 1, diffuseComponent.v);
    glUniform1f(uniforms[UNIFORM_SHININESS], shininess);
    glUniform4fv(uniforms[UNIFORM_SPECULAR_COMPONENT], 1, specularComponent.v);
    glUniform4fv(uniforms[UNIFORM_AMBIENT_COMPONENT], 1, ambientComponent.v);
    
    glBindTexture(GL_TEXTURE_2D, crateTexture);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    
    // Select VBO and draw
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glDrawElements(GL_TRIANGLES, numIndices, GL_UNSIGNED_INT, 0);

    // mazegeneration
    for (tile *t in tilearray) {
        // draw floor
        GLKMatrix4 tempModelView = baseModelViewMatrix;
        tempModelView = GLKMatrix4Translate(tempModelView, t->c*1.5, -.7, -1*(t->r)*1.5);
        tempModelView = GLKMatrix4Scale(tempModelView, 1, .05, 1);
        GLKMatrix4 tempNormal = GLKMatrix4InvertAndTranspose(tempModelView, NULL);

        GLKMatrix4 tempModelProj = GLKMatrix4Multiply(projectionMatrix, tempModelView);
        
        
        glBindTexture(GL_TEXTURE_2D, CT4);
        glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
        
        // Set up uniforms
        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, tempModelProj.m);
        glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, tempNormal.m);
        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, 0, tempModelView.m);
        /* set lighting parameters... */
        glUniform3fv(uniforms[UNIFORM_FLASHLIGHT_POSITION], 1, flashlightPosition.v);
        glUniform3fv(uniforms[UNIFORM_DIFFUSE_LIGHT_POSITION], 1, diffuseLightPosition.v);
        glUniform4fv(uniforms[UNIFORM_DIFFUSE_COMPONENT], 1, diffuseComponent.v);
        glUniform1f(uniforms[UNIFORM_SHININESS], shininess);
        glUniform4fv(uniforms[UNIFORM_SPECULAR_COMPONENT], 1, specularComponent.v);
        glUniform4fv(uniforms[UNIFORM_AMBIENT_COMPONENT], 1, ambientComponent.v);
        
        // Select VBO and draw
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
        glDrawElements(GL_TRIANGLES, numIndices, GL_UNSIGNED_INT, 0);
        
        // draw walls
        if (t->nwe) {
            GLKMatrix4 tempModelViewt = baseModelViewMatrix;
            tempModelViewt = GLKMatrix4Translate(tempModelViewt, t->c*1.5, 0, -1*(t->r)*1.5 - .7);
            tempModelViewt = GLKMatrix4Scale(tempModelViewt, 1, 1, .05);
            GLKMatrix4 tempNormalt = GLKMatrix4InvertAndTranspose(tempModelViewt, NULL);
            
            GLKMatrix4 tempModelProjt = GLKMatrix4Multiply(projectionMatrix, tempModelViewt);
            
            if ((t->ewe) || (t->wwe)) {
                if ((t->wwe) && (t->ewe)) {
                    // two walls
                    glBindTexture(GL_TEXTURE_2D, CT5);
                    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
                } else if (t->ewe) {
                    // right wall
                    glBindTexture(GL_TEXTURE_2D, CT3);
                    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
                } else {
                    // left wall
                    glBindTexture(GL_TEXTURE_2D, CT2);
                    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
                }
            } else {
                // no walls
                glBindTexture(GL_TEXTURE_2D, CT1);
                glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
            }
            
            // Set up uniforms
            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, tempModelProjt.m);
            glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, tempNormalt.m);
            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, 0, tempModelViewt.m);
            /* set lighting parameters... */
            glUniform3fv(uniforms[UNIFORM_FLASHLIGHT_POSITION], 1, flashlightPosition.v);
            glUniform3fv(uniforms[UNIFORM_DIFFUSE_LIGHT_POSITION], 1, diffuseLightPosition.v);
            glUniform4fv(uniforms[UNIFORM_DIFFUSE_COMPONENT], 1, diffuseComponent.v);
            glUniform1f(uniforms[UNIFORM_SHININESS], shininess);
            glUniform4fv(uniforms[UNIFORM_SPECULAR_COMPONENT], 1, specularComponent.v);
            glUniform4fv(uniforms[UNIFORM_AMBIENT_COMPONENT], 1, ambientComponent.v);
            
            // Select VBO and draw
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
            glDrawElements(GL_TRIANGLES, numIndices, GL_UNSIGNED_INT, 0);

        }
        
        if (t->swe) {
            GLKMatrix4 tempModelViewt = baseModelViewMatrix;
            tempModelViewt = GLKMatrix4Translate(tempModelViewt, t->c*1.5, 0, -1*(t->r)*1.5 + .7);
            tempModelViewt = GLKMatrix4Scale(tempModelViewt, 1, 1, .05);
            GLKMatrix4 tempNormalt = GLKMatrix4InvertAndTranspose(tempModelViewt, NULL);
            
            GLKMatrix4 tempModelProjt = GLKMatrix4Multiply(projectionMatrix, tempModelViewt);
            
            if ((t->ewe) || (t->wwe)) {
                if ((t->wwe) && (t->ewe)) {
                    // two walls
                    glBindTexture(GL_TEXTURE_2D, CT5);
                    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
                } else if (t->wwe) {
                    // right wall
                    glBindTexture(GL_TEXTURE_2D, CT3);
                    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
                } else {
                    // left wall
                    glBindTexture(GL_TEXTURE_2D, CT2);
                    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
                }
            } else {
                // no walls
                glBindTexture(GL_TEXTURE_2D, CT1);
                glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
            }
            
            
            // Set up uniforms
            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, tempModelProjt.m);
            glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, tempNormalt.m);
            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, 0, tempModelViewt.m);
            /* set lighting parameters... */
            glUniform3fv(uniforms[UNIFORM_FLASHLIGHT_POSITION], 1, flashlightPosition.v);
            glUniform3fv(uniforms[UNIFORM_DIFFUSE_LIGHT_POSITION], 1, diffuseLightPosition.v);
            glUniform4fv(uniforms[UNIFORM_DIFFUSE_COMPONENT], 1, diffuseComponent.v);
            glUniform1f(uniforms[UNIFORM_SHININESS], shininess);
            glUniform4fv(uniforms[UNIFORM_SPECULAR_COMPONENT], 1, specularComponent.v);
            glUniform4fv(uniforms[UNIFORM_AMBIENT_COMPONENT], 1, ambientComponent.v);
            
            // Select VBO and draw
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
            glDrawElements(GL_TRIANGLES, numIndices, GL_UNSIGNED_INT, 0);

        }
        
        if (t->ewe) {
            GLKMatrix4 tempModelViewt = baseModelViewMatrix;
            tempModelViewt = GLKMatrix4Translate(tempModelViewt, t->c*1.5+.7, 0, -1*(t->r)*1.5);
            tempModelViewt = GLKMatrix4Scale(tempModelViewt, .05, 1, 1);
            GLKMatrix4 tempNormalt = GLKMatrix4InvertAndTranspose(tempModelViewt, NULL);
            
            GLKMatrix4 tempModelProjt = GLKMatrix4Multiply(projectionMatrix, tempModelViewt);
            
            if ((t->nwe) || (t->swe)) {
                if ((t->nwe) && (t->swe)) {
                    // two walls
                    glBindTexture(GL_TEXTURE_2D, CT5);
                    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
                } else if (t->nwe) {
                    // right wall
                    glBindTexture(GL_TEXTURE_2D, CT3);
                    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
                } else {
                    // left wall
                    glBindTexture(GL_TEXTURE_2D, CT2);
                    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
                }
            } else {
                // no walls
                glBindTexture(GL_TEXTURE_2D, CT1);
                glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
            }
            
            // Set up uniforms
            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, tempModelProjt.m);
            glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, tempNormalt.m);
            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, 0, tempModelViewt.m);
            /* set lighting parameters... */
            glUniform3fv(uniforms[UNIFORM_FLASHLIGHT_POSITION], 1, flashlightPosition.v);
            glUniform3fv(uniforms[UNIFORM_DIFFUSE_LIGHT_POSITION], 1, diffuseLightPosition.v);
            glUniform4fv(uniforms[UNIFORM_DIFFUSE_COMPONENT], 1, diffuseComponent.v);
            glUniform1f(uniforms[UNIFORM_SHININESS], shininess);
            glUniform4fv(uniforms[UNIFORM_SPECULAR_COMPONENT], 1, specularComponent.v);
            glUniform4fv(uniforms[UNIFORM_AMBIENT_COMPONENT], 1, ambientComponent.v);
            
            // Select VBO and draw
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
            glDrawElements(GL_TRIANGLES, numIndices, GL_UNSIGNED_INT, 0);
        }
        
        if (t->wwe) {
            GLKMatrix4 tempModelViewt = baseModelViewMatrix;
            tempModelViewt = GLKMatrix4Translate(tempModelViewt, t->c*1.5-.7, 0, -1*(t->r)*1.5);
            tempModelViewt = GLKMatrix4Scale(tempModelViewt, .05, 1, 1);
            GLKMatrix4 tempNormalt = GLKMatrix4InvertAndTranspose(tempModelViewt, NULL);
            
            GLKMatrix4 tempModelProjt = GLKMatrix4Multiply(projectionMatrix, tempModelViewt);
            
            if ((t->nwe) || (t->swe)) {
                if ((t->nwe) && (t->swe)) {
                    // two walls
                    glBindTexture(GL_TEXTURE_2D, CT5);
                    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
                } else if (t->swe) {
                    // right wall
                    glBindTexture(GL_TEXTURE_2D, CT3);
                    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
                } else {
                    // left wall
                    glBindTexture(GL_TEXTURE_2D, CT2);
                    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
                }
            } else {
                // no walls
                glBindTexture(GL_TEXTURE_2D, CT1);
                glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
            }
            
            // Set up uniforms
            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, tempModelProjt.m);
            glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, tempNormalt.m);
            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, 0, tempModelViewt.m);
            /* set lighting parameters... */
            glUniform3fv(uniforms[UNIFORM_FLASHLIGHT_POSITION], 1, flashlightPosition.v);
            glUniform3fv(uniforms[UNIFORM_DIFFUSE_LIGHT_POSITION], 1, diffuseLightPosition.v);
            glUniform4fv(uniforms[UNIFORM_DIFFUSE_COMPONENT], 1, diffuseComponent.v);
            glUniform1f(uniforms[UNIFORM_SHININESS], shininess);
            glUniform4fv(uniforms[UNIFORM_SPECULAR_COMPONENT], 1, specularComponent.v);
            glUniform4fv(uniforms[UNIFORM_AMBIENT_COMPONENT], 1, ambientComponent.v);
            
            // Select VBO and draw
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
            glDrawElements(GL_TRIANGLES, numIndices, GL_UNSIGNED_INT, 0);
        }
    }
    
    // DRAW MONKEY
    GLKMatrix4 monkeytempModelView = baseModelViewMatrix;
    
    // monkey moving
    monkeytempModelView = GLKMatrix4Translate(monkeytempModelView, monkeyXPos*1.5 + monkeyXPosUser, .5 + monkeyYPosUser, monkeyYPos*-1.5 + monkeyZPosUser);
    // monkey scaling
    monkeytempModelView = GLKMatrix4Scale(monkeytempModelView, .6 * scalevalue, .6 * scalevalue, .6 * scalevalue);
    GLKMatrix4 monkeytempNormal = GLKMatrix4InvertAndTranspose(monkeytempModelView, NULL);
    
    // monkey rotation
    monkeytempModelView = GLKMatrix4RotateY(monkeytempModelView, monkeyRotateValue * -1);
    
    GLKMatrix4 monkeytempModelProj = GLKMatrix4Multiply(projectionMatrix, monkeytempModelView);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    
    // Set up uniforms
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, monkeytempModelProj.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, monkeytempNormal.m);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, 0, monkeytempModelView.m);
    /* set lighting parameters... */
    glUniform3fv(uniforms[UNIFORM_FLASHLIGHT_POSITION], 1, flashlightPosition.v);
    glUniform3fv(uniforms[UNIFORM_DIFFUSE_LIGHT_POSITION], 1, diffuseLightPosition.v);
    glUniform4fv(uniforms[UNIFORM_DIFFUSE_COMPONENT], 1, diffuseComponent.v);
    glUniform1f(uniforms[UNIFORM_SHININESS], shininess);
    glUniform4fv(uniforms[UNIFORM_SPECULAR_COMPONENT], 1, specularComponent.v);
    glUniform4fv(uniforms[UNIFORM_AMBIENT_COMPONENT], 1, ambientComponent.v);
    
    // Select VBO and draw
    
    glBindTexture(GL_TEXTURE_2D, cubeTex);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _mindexBuffer);
//    glDrawElements(GL_TRIANGLES, *micount, GL_UNSIGNED_INT, 0);
    glBindVertexArrayOES(_mvertexArray);
    glDrawArrays(GL_TRIANGLES, 0, *mvcount + *mtcount + *mncount);
    glBindVertexArrayOES(0); // reset buffer
}


#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord0, "texCoordIn");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

// Load in and set up texture image (adapted from Ray Wenderlich)
- (GLuint)setupTexture:(NSString *)fileName
{
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte *spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
    return texName;
}

// Generate vertices, normals, texture coordinates and indices for cube
//      Adapted from Dan Ginsburg, Budirijanto Purnomo from the book
//      OpenGL(R) ES 2.0 Programming Guide
int generateCube(float scale, GLfloat **vertices, GLfloat **normals,
                 GLfloat **texCoords, GLuint **indices, int *numVerts)
{
    int i;
    int numVertices = 24;
    int numIndices = 36;
    
    GLfloat cubeVerts[] =
    {
        -0.5f, -0.5f, -0.5f,
        -0.5f, -0.5f,  0.5f,
        0.5f, -0.5f,  0.5f,
        0.5f, -0.5f, -0.5f,
        -0.5f,  0.5f, -0.5f,
        -0.5f,  0.5f,  0.5f,
        0.5f,  0.5f,  0.5f,
        0.5f,  0.5f, -0.5f,
        -0.5f, -0.5f, -0.5f,
        -0.5f,  0.5f, -0.5f,
        0.5f,  0.5f, -0.5f,
        0.5f, -0.5f, -0.5f,
        -0.5f, -0.5f, 0.5f,
        -0.5f,  0.5f, 0.5f,
        0.5f,  0.5f, 0.5f,
        0.5f, -0.5f, 0.5f,
        -0.5f, -0.5f, -0.5f,
        -0.5f, -0.5f,  0.5f,
        -0.5f,  0.5f,  0.5f,
        -0.5f,  0.5f, -0.5f,
        0.5f, -0.5f, -0.5f,
        0.5f, -0.5f,  0.5f,
        0.5f,  0.5f,  0.5f,
        0.5f,  0.5f, -0.5f,
    };
    
    GLfloat cubeNormals[] =
    {
        0.0f, -1.0f, 0.0f,
        0.0f, -1.0f, 0.0f,
        0.0f, -1.0f, 0.0f,
        0.0f, -1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
    };
    
    GLfloat cubeTex[] =
    {
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        1.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
    };
    
    // Allocate memory for buffers
    if ( vertices != NULL )
    {
        *vertices = malloc ( sizeof ( GLfloat ) * 3 * numVertices );
        memcpy ( *vertices, cubeVerts, sizeof ( cubeVerts ) );
        
        for ( i = 0; i < numVertices * 3; i++ )
        {
            ( *vertices ) [i] *= scale;
        }
    }
    
    if ( normals != NULL )
    {
        *normals = malloc ( sizeof ( GLfloat ) * 3 * numVertices );
        memcpy ( *normals, cubeNormals, sizeof ( cubeNormals ) );
    }
    
    if ( texCoords != NULL )
    {
        *texCoords = malloc ( sizeof ( GLfloat ) * 2 * numVertices );
        memcpy ( *texCoords, cubeTex, sizeof ( cubeTex ) ) ;
    }
    
    
    // Generate the indices
    if ( indices != NULL )
    {
        GLuint cubeIndices[] =
        {
            0, 2, 1,
            0, 3, 2,
            4, 5, 6,
            4, 6, 7,
            8, 9, 10,
            8, 10, 11,
            12, 15, 14,
            12, 14, 13,
            16, 17, 18,
            16, 18, 19,
            20, 23, 22,
            20, 22, 21
        };
        
        *indices = malloc ( sizeof ( GLuint ) * numIndices );
        memcpy ( *indices, cubeIndices, sizeof ( cubeIndices ) );
    }
    
    if (numVerts != NULL)
        *numVerts = numVertices;
    return numIndices;
}


@end
