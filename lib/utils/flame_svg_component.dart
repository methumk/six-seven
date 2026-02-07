import 'package:flame/components.dart';
import 'package:flame_svg/svg.dart';
import 'package:flame_svg/svg_component.dart';
import 'package:flutter/material.dart';

Future<SvgComponent?> loadSvgFromPath(
  String path, {
  Vector2? position,
  Vector2? size,
}) async {
  try {
    final svgInstance = await Svg.load(path);
    final svgComponent = SvgComponent(
      size: size ?? Vector2.all(100), // To show size if user forgot to set
      position: position ?? Vector2.all(0),
      svg: svgInstance,
    );

    return svgComponent;
  } catch (err) {
    debugPrint("Error on loadSvgFrompath $err");
  }
  return null;
}

Future<SvgComponent?> loadSvgFromSvg(
  Svg svg, {
  Vector2? position,
  Vector2? size,
}) async {
  try {
    final svgComponent = SvgComponent(
      size: size ?? Vector2.all(100), // To show size if user forgot to set
      position: position ?? Vector2.all(0),
      svg: svg,
    );

    return svgComponent;
  } catch (err) {
    debugPrint("Error on loadSvgFrompath $err");
  }
  return null;
}
