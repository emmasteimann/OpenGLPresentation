//
//  Matrix4f.h
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/31/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//
#define ToRadian(x) (float)(((x) * M_PI / 180.0f))
#define ToDegree(x) (float)(((x) * 180.0f / M_PI))

struct Quaternion
{
  float x, y, z, w;

  Quaternion(float _x, float _y, float _z, float _w);

  void Normalize();

  Quaternion Conjugate();
};

class Matrix4f
{
public:
  float m[4][4];

  Matrix4f()
  {
  }

  // constructor from Assimp matrix
  Matrix4f(const aiMatrix4x4& AssimpMatrix)
  {
    m[0][0] = AssimpMatrix.a1; m[0][1] = AssimpMatrix.a2; m[0][2] = AssimpMatrix.a3; m[0][3] = AssimpMatrix.a4;
    m[1][0] = AssimpMatrix.b1; m[1][1] = AssimpMatrix.b2; m[1][2] = AssimpMatrix.b3; m[1][3] = AssimpMatrix.b4;
    m[2][0] = AssimpMatrix.c1; m[2][1] = AssimpMatrix.c2; m[2][2] = AssimpMatrix.c3; m[2][3] = AssimpMatrix.c4;
    m[3][0] = AssimpMatrix.d1; m[3][1] = AssimpMatrix.d2; m[3][2] = AssimpMatrix.d3; m[3][3] = AssimpMatrix.d4;
  }

  inline void InitIdentity()
  {
    m[0][0] = 1.0f; m[0][1] = 0.0f; m[0][2] = 0.0f; m[0][3] = 0.0f;
    m[1][0] = 0.0f; m[1][1] = 1.0f; m[1][2] = 0.0f; m[1][3] = 0.0f;
    m[2][0] = 0.0f; m[2][1] = 0.0f; m[2][2] = 1.0f; m[2][3] = 0.0f;
    m[3][0] = 0.0f; m[3][1] = 0.0f; m[3][2] = 0.0f; m[3][3] = 1.0f;
  }

  inline Matrix4f operator*(const Matrix4f& Right) const
  {
    Matrix4f Ret;

    for (unsigned int i = 0 ; i < 4 ; i++) {
      for (unsigned int j = 0 ; j < 4 ; j++) {
        Ret.m[i][j] = m[i][0] * Right.m[0][j] +
        m[i][1] * Right.m[1][j] +
        m[i][2] * Right.m[2][j] +
        m[i][3] * Right.m[3][j];
      }
    }

    return Ret;
  }

  operator const float*() const
  {
    return &(m[0][0]);
  }

  void Print() const
  {
    for (int i = 0 ; i < 4 ; i++) {
      printf("%f %f %f %f\n", m[i][0], m[i][1], m[i][2], m[i][3]);
    }
  }
  
  void InitScaleTransform(float ScaleX, float ScaleY, float ScaleZ)
  {
    m[0][0] = ScaleX; m[0][1] = 0.0f;   m[0][2] = 0.0f;   m[0][3] = 0.0f;
    m[1][0] = 0.0f;   m[1][1] = ScaleY; m[1][2] = 0.0f;   m[1][3] = 0.0f;
    m[2][0] = 0.0f;   m[2][1] = 0.0f;   m[2][2] = ScaleZ; m[2][3] = 0.0f;
    m[3][0] = 0.0f;   m[3][1] = 0.0f;   m[3][2] = 0.0f;   m[3][3] = 1.0f;
  }

  void InitRotateTransform(float RotateX, float RotateY, float RotateZ)
  {
    Matrix4f rx, ry, rz;

    const float x = ToRadian(RotateX);
    const float y = ToRadian(RotateY);
    const float z = ToRadian(RotateZ);

    rx.m[0][0] = 1.0f; rx.m[0][1] = 0.0f   ; rx.m[0][2] = 0.0f    ; rx.m[0][3] = 0.0f;
    rx.m[1][0] = 0.0f; rx.m[1][1] = cosf(x); rx.m[1][2] = -sinf(x); rx.m[1][3] = 0.0f;
    rx.m[2][0] = 0.0f; rx.m[2][1] = sinf(x); rx.m[2][2] = cosf(x) ; rx.m[2][3] = 0.0f;
    rx.m[3][0] = 0.0f; rx.m[3][1] = 0.0f   ; rx.m[3][2] = 0.0f    ; rx.m[3][3] = 1.0f;

    ry.m[0][0] = cosf(y); ry.m[0][1] = 0.0f; ry.m[0][2] = -sinf(y); ry.m[0][3] = 0.0f;
    ry.m[1][0] = 0.0f   ; ry.m[1][1] = 1.0f; ry.m[1][2] = 0.0f    ; ry.m[1][3] = 0.0f;
    ry.m[2][0] = sinf(y); ry.m[2][1] = 0.0f; ry.m[2][2] = cosf(y) ; ry.m[2][3] = 0.0f;
    ry.m[3][0] = 0.0f   ; ry.m[3][1] = 0.0f; ry.m[3][2] = 0.0f    ; ry.m[3][3] = 1.0f;

    rz.m[0][0] = cosf(z); rz.m[0][1] = -sinf(z); rz.m[0][2] = 0.0f; rz.m[0][3] = 0.0f;
    rz.m[1][0] = sinf(z); rz.m[1][1] = cosf(z) ; rz.m[1][2] = 0.0f; rz.m[1][3] = 0.0f;
    rz.m[2][0] = 0.0f   ; rz.m[2][1] = 0.0f    ; rz.m[2][2] = 1.0f; rz.m[2][3] = 0.0f;
    rz.m[3][0] = 0.0f   ; rz.m[3][1] = 0.0f    ; rz.m[3][2] = 0.0f; rz.m[3][3] = 1.0f;

    *this = rz * ry * rx;
  }


  void InitRotateTransform(const Quaternion& quat)
  {
    float yy2 = 2.0f * quat.y * quat.y;
    float xy2 = 2.0f * quat.x * quat.y;
    float xz2 = 2.0f * quat.x * quat.z;
    float yz2 = 2.0f * quat.y * quat.z;
    float zz2 = 2.0f * quat.z * quat.z;
    float wz2 = 2.0f * quat.w * quat.z;
    float wy2 = 2.0f * quat.w * quat.y;
    float wx2 = 2.0f * quat.w * quat.x;
    float xx2 = 2.0f * quat.x * quat.x;
    m[0][0] = - yy2 - zz2 + 1.0f;
    m[0][1] = xy2 + wz2;
    m[0][2] = xz2 - wy2;
    m[0][3] = 0;
    m[1][0] = xy2 - wz2;
    m[1][1] = - xx2 - zz2 + 1.0f;
    m[1][2] = yz2 + wx2;
    m[1][3] = 0;
    m[2][0] = xz2 + wy2;
    m[2][1] = yz2 - wx2;
    m[2][2] = - xx2 - yy2 + 1.0f;
    m[2][3] = 0.0f;
    m[3][0] = m[3][1] = m[3][2] = 0;
    m[3][3] = 1.0f;
  }

  void InitTranslationTransform(float x, float y, float z)
  {
    m[0][0] = 1.0f; m[0][1] = 0.0f; m[0][2] = 0.0f; m[0][3] = x;
    m[1][0] = 0.0f; m[1][1] = 1.0f; m[1][2] = 0.0f; m[1][3] = y;
    m[2][0] = 0.0f; m[2][1] = 0.0f; m[2][2] = 1.0f; m[2][3] = z;
    m[3][0] = 0.0f; m[3][1] = 0.0f; m[3][2] = 0.0f; m[3][3] = 1.0f;
  }

};

