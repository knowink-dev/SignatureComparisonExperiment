//
//  MetalController.metal
//  MetalAndImages
//
//  Created by Paul Mayer on 5/10/21.
//

#include <metal_stdlib>
using namespace metal;


kernel void black (texture2d<float, access::write> outTexture [[texture(0)]],
                   texture2d<float, access::read> inTexture [[texture(1)]],
                   device uint *resultArray [[buffer(2)]],
                   uint2 id [[thread_position_in_grid]]) {
    
    float4 val = inTexture.read(id).rgba;
    float gray = (val.r + val.g + val.b)/3.0;
    //        out = float4(gray, gray, gray, 1.0);
    float4 out = float4();
    if (val.r < 1 && val.g < 1 && val.b < 1 && val.a > 0) {

//    } else {
//        out = float4(0, 0, 0, 1.0);
        if (id.x == 0 && id.y != 0){
//            resultArray[id.y] = 255;
        } else if (id.x != 0 && id.y == 0){
//            resultArray[id.x] = 255;
        } else if (id.x == 0 && id.y == 0){
//            resultArray[0] = 255;
        } else {
            resultArray[id.x * id.y] = id.y;
            out = float4(0, 0, 0, 1);
            
        }
        
    } else {
        out = float4(255.0, 255.0,255.0, 1);
    }
//    float4 out = float4(gray, gray, gray, 1.0);
    float4 white = float4(255.0, 255.0,255.0, 1);
    float4 black = float4(0, 0, 0, 1);
    
    outTexture.write(out.rgba, id);
//    outTexture.write(black, id);
//    outTexture.write(rgbFloat, id);
}
