import 'dart:math' as math;

import 'package:flame/components.dart';

double angleFromThreePoints(Vector2 a, Vector2 center, Vector2 b) {
  // Vectors from center point b
  final ac = a - center;
  final bc = b - center;

  // Dot product and magnitudes
  final dot = ac.dot(bc);
  final mag = ac.length * bc.length;

  // acos gives angle in radians
  return math.acos(dot / mag);
}

double directedAngle(
  Vector2 start,
  Vector2 center,
  Vector2 end, {
  bool ccw = true,
}) {
  final u = start - center; // from center to start
  final v = end - center; // from center to end

  final dot = u.dot(v);
  final cross = u.x * v.y - u.y * v.x;

  // Signed angle (-π, π]
  double angle = math.atan2(cross, dot);

  // Normalize to [0, 2π)
  if (angle < 0) {
    angle += 2 * math.pi;
  }

  if (!ccw) {
    // Convert CCW angle to CW angle
    if (angle == 0) return 0;
    angle = 2 * math.pi - angle;
  }

  return angle; // in radians
}

bool almostEqual(Vector2 a, Vector2 b, {double epsilon = 1e-6}) {
  return (a.x - b.x).abs() < epsilon && (a.y - b.y).abs() < epsilon;
}

bool exactEqual(Vector2 a, Vector2 b) {
  return a.x == b.x && a.y == b.y;
}

bool angleclose(double curr, double target, {double epsilon = 1e-6}) {
  return (curr - target).abs() < epsilon;
}
