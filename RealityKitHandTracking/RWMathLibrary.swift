//
//  RWMathLibrary.swift
//  LBMetal
//
//  Created by Sebastian Buys on 7/29/19.
//  Copyright © 2019 Sebastian Buys. All rights reserved.
//

// From Ray Wenderlich

import simd

let π = Float.pi

func radians(fromDegrees degrees: Float) -> Float {
    return (degrees / 180) * π
}

func degrees(fromRadians radians: Float) -> Float {
    return (radians / π) * 180
}

struct CameraRectangle {
    var left: Float = 0
    var right: Float = 0
    var top: Float = 0
    var bottom: Float = 0
}

extension Float {
    var radiansToDegrees: Float {
        return (self / π) * 180
    }
    var degreesToRadians: Float {
        return (self / 180) * π
    }
}

extension float4x4 {
    init(translation: SIMD3<Float>) {
        self = matrix_identity_float4x4
        columns.3.x = translation.x
        columns.3.y = translation.y
        columns.3.z = translation.z
    }
  
    init(scaling: SIMD3<Float>) {
        self = matrix_identity_float4x4
        columns.0.x = scaling.x
        columns.1.y = scaling.y
        columns.2.z = scaling.z
    }
  
    init(scaling: Float) {
        self = matrix_identity_float4x4
        columns.3.w = 1 / scaling
    }
  
    init(rotationX angle: Float) {
        self = matrix_identity_float4x4
        columns.1.y = cos(angle)
        columns.1.z = sin(angle)
        columns.2.y = -sin(angle)
        columns.2.z = cos(angle)
    }
  
    init(rotationY angle: Float) {
        self = matrix_identity_float4x4
        columns.0.x = cos(angle)
        columns.0.z = -sin(angle)
        columns.2.x = sin(angle)
        columns.2.z = cos(angle)
    }
  
    init(rotationZ angle: Float) {
        self = matrix_identity_float4x4
        columns.0.x = cos(angle)
        columns.0.y = sin(angle)
        columns.1.x = -sin(angle)
        columns.1.y = cos(angle)
    }
  
    init(rotation angle: SIMD3<Float>) {
        let rotationX = float4x4(rotationX: angle.x)
        let rotationY = float4x4(rotationY: angle.y)
        let rotationZ = float4x4(rotationZ: angle.z)
        self = rotationX * rotationY * rotationZ
    }
  
    static func identity() -> float4x4 {
        let matrix:float4x4 = matrix_identity_float4x4
        return matrix
    }
  
    func upperLeft() -> float3x3 {
        let x = columns.0.xyz
        let y = columns.1.xyz
        let z = columns.2.xyz
        return float3x3(columns: (x, y, z))
    }
  
    init(projectionFov fov: Float, near: Float, far: Float, aspect: Float, lhs: Bool = true) {
        let y = 1 / tan(fov * 0.5)
        let x = y / aspect
        let z = lhs ? far / (far - near) : far / (near - far)
        let X = SIMD4<Float>( x,  0,  0,  0)
        let Y = SIMD4<Float>( 0,  y,  0,  0)
        let Z = lhs ? SIMD4<Float>( 0,  0,  z, 1) : SIMD4<Float>( 0,  0,  z, -1)
        let W = lhs ? SIMD4<Float>( 0,  0,  z * -near,  0) : SIMD4<Float>( 0,  0,  z * near,  0)
        self.init()
        columns = (X, Y, Z, W)
    }
  
  // left-handed LookAt
    init(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) {
        let z = normalize(eye - center)
        let x = normalize(cross(up, z))
        let y = cross(z, x)
        let w = SIMD3<Float>(dot(x, -eye), dot(y, -eye), dot(z, -eye))

        let X = SIMD4<Float>(x.x, y.x, z.x, 0)
        let Y = SIMD4<Float>(x.y, y.y, z.y, 0)
        let Z = SIMD4<Float>(x.z, y.z, z.z, 0)
        let W = SIMD4<Float>(w.x, w.y, x.z, 1)
        self.init()
        columns = (X, Y, Z, W)
    }
  
    init(orthographic rect: CameraRectangle, near: Float, far: Float) {
        let X = SIMD4<Float>(2 / (rect.right - rect.left), 0, 0, 0)
        let Y = SIMD4<Float>(0, 2 / (rect.top - rect.bottom), 0, 0)
        let Z = SIMD4<Float>(0, 0, 1 / (far - near), 0)
        let W = SIMD4<Float>((rect.left + rect.right) / (rect.left - rect.right),
                     (rect.top + rect.bottom) / (rect.bottom - rect.top),
                     near / (near - far),
                     1)
        self.init()
        columns = (X, Y, Z, W)
    }
}

extension float3x3 {
    init(normalFrom4x4 matrix: float4x4) {
        self.init()
        columns = matrix.upperLeft().inverse.transpose.columns
    }
}

//extension float4 {
//  var xyz: float3 {
//    get {
//      return float3(x, y, z)
//    }
//    set {
//      x = newValue.x
//      y = newValue.y
//      z = newValue.z
//    }
//  }
//}

extension SIMD4 where Scalar == Float {
    var xyz: SIMD3<Float> {
        get {
            return SIMD3<Float>(x, y, z)
        }
        set {
            x = newValue.x
            y = newValue.y
            z = newValue.z
        }
    }
}


