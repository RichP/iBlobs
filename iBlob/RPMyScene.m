//
//  RPMyScene.m
//  iBlob
//
//  Created by Richard Pickup on 17/05/2014.
//  Copyright (c) 2014 Richard Pickup. All rights reserved.
//

#import "RPMyScene.h"

@implementation RPMyScene {
    NSMutableArray* _blobs;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0];
        
        SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        self.physicsBody = borderBody;
        
        _blobs = [NSMutableArray array];
        
    }
    return self;
}

- (void) drawBlob {
    //remove the old ball from the scene
    [self enumerateChildNodesWithName:@"blobline" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    
    
    int pattern = 0;
    for(NSArray* bodies in _blobs) {
        // draw the new ball
        SKShapeNode* blobLine = [SKShapeNode node];
        SKSpriteNode *point = [bodies objectAtIndex:0];
        
        // create a path between the outer circles
        CGMutablePathRef pathToDraw = CGPathCreateMutable();
        CGPathMoveToPoint(pathToDraw, NULL, point.position.x, point.position.y);
        
        for(int loop = 1; loop < [bodies count]; loop++)
        {
            
            point = [bodies objectAtIndex:loop];
            CGPathAddLineToPoint(pathToDraw, NULL, point.position.x, point.position.y);
            
        }
        
        // close the final gap between the last point and first point
        point = [bodies objectAtIndex:0];
        CGPathAddLineToPoint(pathToDraw, NULL, point.position.x, point.position.y);
        
        //draw the line
        blobLine.path = pathToDraw;
        [blobLine setStrokeColor:[SKColor blackColor]];
        blobLine.lineWidth = 9;
        [blobLine setGlowWidth:1];
        [blobLine setFillColor:[SKColor whiteColor]];
        blobLine.name = @"blobline";
        
        switch (pattern % 3) {
            case 0:
                blobLine.fillTexture = [SKTexture textureWithImageNamed:@"leopard"];
                break;
            case 1:
                blobLine.fillTexture = [SKTexture textureWithImageNamed:@"bubble"];
                break;
                
            default:
                blobLine.fillTexture = [SKTexture textureWithImageNamed:@"stripe"];
                break;
        }
        
        ++pattern;
        [self addChild:blobLine];
        CGPathRelease(pathToDraw);
    }
 
}

- (void) creareBlobAt:(CGPoint)pos {
    
    int numPoints = 32;
    float radius = 60;
    
    SKSpriteNode* mainCircle = [SKSpriteNode spriteNodeWithImageNamed:@"cartoon-eyes"];
    mainCircle.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius * 0.25];
    mainCircle.physicsBody.dynamic = YES;
    mainCircle.physicsBody.affectedByGravity = NO;
    mainCircle.physicsBody.density = 1;
    mainCircle.physicsBody.restitution = 0.4f;
    mainCircle.physicsBody.friction = 0.5f;
    mainCircle.physicsBody.mass = 4.0f;;
    mainCircle.position = pos;
    mainCircle.zPosition = 5;
    mainCircle.xScale = 0.25;
    mainCircle.yScale = 0.25;
    mainCircle.name = @"player";
    [self addChild:mainCircle];
    
    NSMutableArray* bodies = [NSMutableArray arrayWithCapacity:numPoints];
    for (int i =0; i < numPoints; ++i) {
        float angle = ((M_PI * 2) / numPoints) * i;
        float x_offset = cosf(angle);
        float y_offset = sinf(angle);
        
        x_offset *= radius;
        y_offset *= radius;
        
        SKSpriteNode *point = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(12, 12)];
        point.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:6];
        point.physicsBody.dynamic = YES;
        point.physicsBody.affectedByGravity = YES;
        point.physicsBody.density = 1;
        point.physicsBody.restitution = 0.4f;
        point.physicsBody.friction = 0.5f;
        point.physicsBody.mass = 2 / numPoints;
        point.position = CGPointMake(mainCircle.position.x + x_offset, mainCircle.position.y + y_offset);
        point.name = @"smallcircle";
        [self addChild:point];
        
        // attach each out circle to the main circle by using a joint
        [self AttachPoint:mainCircle secondPoint:point];
        [bodies addObject:point];
    }
    
    for(int i = 1; i < bodies.count; ++i) {
        [self AttachPoint:[bodies objectAtIndex:i]  secondPoint:[bodies objectAtIndex:(i-1)]] ;
    }
    
    [self AttachPoint:[bodies objectAtIndex:([bodies count]-1)] secondPoint:[bodies objectAtIndex:1]];
    
    [_blobs addObject:bodies];
    
}

-(void)AttachPoint:(SKSpriteNode *)point1 secondPoint:(SKSpriteNode *)point2 {
    
    // create a joint between two bodies
    SKPhysicsJointSpring *joint = [SKPhysicsJointSpring jointWithBodyA:point1.physicsBody bodyB:point2.physicsBody anchorA:point1.position anchorB:point2.position  ];
    
    joint.damping = 2;
    joint.frequency = 9;
    
    [self.physicsWorld addJoint:joint];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        
        [self creareBlobAt:location];
    }
}



-(void)update:(CFTimeInterval)currentTime {
    //rotate gravity with the device
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortrait:
            self.physicsWorld.gravity = CGVectorMake(0, -9.8);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            self.physicsWorld.gravity = CGVectorMake(0, 9.8);
            break;
        case UIDeviceOrientationLandscapeLeft:
            self.physicsWorld.gravity = CGVectorMake(-9.8, 0);
            break;
        case UIDeviceOrientationLandscapeRight:
            self.physicsWorld.gravity = CGVectorMake(9.8, 0);
            break;
            
        default:
            break;
    }
    
    [self drawBlob];
    
}



@end
