//
//  PlaneDetector.h
//  ARuler
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@interface PlaneDetector : NSObject

+ (SCNVector4)detectPlaneWithPoints:(NSArray *)points;

@end
