import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedRangeSlider extends StatefulWidget {
  const AnimatedRangeSlider({
    super.key,
    required this.width,
    required this.height,
    this.minRange = 0,
    this.maxRange = 100,
    this.onChanged,
  }) : assert(maxRange > minRange);

  final double width;
  final double height;
  final int minRange;
  final int maxRange;
  final void Function(int value)? onChanged;

  @override
  State<AnimatedRangeSlider> createState() => _AnimatedRangeSliderState();
}

class _AnimatedRangeSliderState extends State<AnimatedRangeSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> bezierAnimation;
  late Animation<double> circlePostionAnimation;
  late Animation<Color?> windowColorAnimation;
  late Animation<Color?> textColorAnimation;
  late Animation<double> windowOffsetYAnimation;
  late final double bezierPeakPostion;
  final circleRadius = 5.0;

  // states.
  double _hDragPostion = 0;
  int selectedValue = 0;

  double get hDragPostion => _hDragPostion;
  set hDragPostion(double v) {
    if (_hDragPostion == v) return;
    setState(() => _hDragPostion = v);
  }

  @override
  void initState() {
    super.initState();
    bezierPeakPostion = (widget.height / 2) - 15;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    bezierAnimation = Tween<double>(
      begin: widget.height / 2,
      end: widget.height / 2,
    ).animate(controller);

    circlePostionAnimation = Tween<double>(
      begin: (widget.height / 2) + (circleRadius * 2),
      end: (widget.height / 2) + (circleRadius * 2),
    ).animate(controller);

    windowColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.black,
    ).animate(controller);

    textColorAnimation = ColorTween(
      begin: Colors.black,
      end: Colors.white,
    ).animate(controller);

    windowOffsetYAnimation = Tween<double>(
      begin: widget.height * 0.2,
      end: 0,
    ).animate(controller);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: onHorizontalDragStart,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      onHorizontalDragEnd: onHorizontalDragEnd,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return CustomPaint(
            painter: AnimatedRangeSliderPainter(
              postion: hDragPostion,
              bezierHeight: bezierAnimation.value,
              circleRadius: circleRadius,
              circlePostionY: circlePostionAnimation.value,
              windowColor: windowColorAnimation.value ?? Colors.transparent,
              textColor: textColorAnimation.value ?? Colors.transparent,
              windowOffsetY: windowOffsetYAnimation.value,
              maxRange: widget.maxRange,
              minRange: widget.minRange,
              onChanged: (value) {
                selectedValue = value;
              },
            ),
            child: child,
          );
        },
        child: SizedBox(width: widget.width, height: widget.height),
      ),
    );
  }

  void onHorizontalDragStart(DragStartDetails details) {
    hDragPostion = details.localPosition.dx;
    bezierAnimation = Tween<double>(
      begin: widget.height / 2,
      end: bezierPeakPostion,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.decelerate));

    circlePostionAnimation = Tween<double>(
      begin: (widget.height / 2) + (circleRadius * 2),
      end: (widget.height / 2),
    ).animate(controller);

    windowColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.black,
    ).animate(controller);

    textColorAnimation = ColorTween(
      begin: Colors.black,
      end: Colors.white,
    ).animate(controller);

    windowOffsetYAnimation = Tween<double>(
      begin: widget.height * 0.2,
      end: 0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutExpo));

    controller.reset();
    controller.forward();
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    final renderBox = (context.findRenderObject() as RenderBox);

    final minRange = renderBox.localToGlobal(Offset.zero).dx;
    final maxRange = minRange + (renderBox.size.width);
    if (details.globalPosition.dx >= minRange &&
        details.globalPosition.dx <= maxRange) {
      hDragPostion = details.localPosition.dx;
    }
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    bezierAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: bezierPeakPostion, end: widget.height * 0.51)
          ..chain(CurveTween(curve: Curves.ease)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.height * 0.51, end: widget.height * 0.46)
          ..chain(CurveTween(curve: Curves.ease)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.height * 0.46, end: widget.height * 0.5)
          ..chain(CurveTween(curve: Curves.easeInBack)),
        weight: 1,
      ),
    ]).animate(controller);

    circlePostionAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: widget.height / 2,
          end: (widget.height / 2) + (circleRadius * 3),
        )..chain(CurveTween(curve: Curves.ease)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: (widget.height / 2) + (circleRadius * 3),
          end: (widget.height / 2) + (circleRadius * 1.5),
        )..chain(CurveTween(curve: Curves.ease)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: (widget.height / 2) + (circleRadius * 1.5),
          end: (widget.height / 2) + (circleRadius * 2),
        )..chain(CurveTween(curve: Curves.easeInBack)),
        weight: 2,
      ),
    ]).animate(controller);

    windowColorAnimation = ColorTween(
      begin: Colors.black,
      end: Colors.transparent,
    ).animate(controller);

    textColorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.black,
    ).animate(controller);

    windowOffsetYAnimation = Tween<double>(
      begin: 0,
      end: widget.height * 0.2,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutExpo));

    controller.reset();
    controller.forward();

    widget.onChanged?.call(selectedValue);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class AnimatedRangeSliderPainter extends CustomPainter {
  AnimatedRangeSliderPainter({
    required this.postion,
    required this.bezierHeight,
    required this.circleRadius,
    required this.circlePostionY,
    required this.windowColor,
    required this.textColor,
    required this.windowOffsetY,
    required this.maxRange,
    required this.minRange,
    required this.onChanged,
  });
  final double postion;
  final double bezierHeight;
  final double circleRadius;
  final double circlePostionY;
  final Color windowColor;
  final Color textColor;
  final double windowOffsetY;
  final int maxRange;
  final int minRange;
  final Function(int value) onChanged;

  @override
  void paint(Canvas canvas, Size size) {
    // Line with bezier.
    _drawBezierLine(canvas, size);

    // Circle
    _drawCircle(canvas, size, circleRadius, Offset(postion, circlePostionY));

    // Window
    _drawWindow(canvas, size);

    // min range text
    _drawRangeText(canvas, size, "$minRange", Offset(0, size.height * 0.65));

    // max range text
    _drawRangeText(
        canvas, size, "$maxRange", Offset(size.width, size.height * 0.65));
  }

  void _drawBezierLine(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    double linePostionY = size.height / 2;
    Offset sliderPostion = Offset(postion, linePostionY);
    double bezierRadius = 30;
    double lineIncreaseValue = circleRadius * 2.5;

    final path = Path()
      ..moveTo(-lineIncreaseValue, linePostionY)
      ..lineTo(max(sliderPostion.dx - bezierRadius, -lineIncreaseValue),
          sliderPostion.dy)
      ..cubicTo(
        max(-lineIncreaseValue, sliderPostion.dx - (bezierRadius / 2)),
        linePostionY,
        max(-lineIncreaseValue, sliderPostion.dx - (bezierRadius / 2)),
        bezierHeight,
        sliderPostion.dx,
        bezierHeight,
      )
      ..cubicTo(
        sliderPostion.dx + (bezierRadius / 2),
        bezierHeight,
        sliderPostion.dx + (bezierRadius / 2),
        linePostionY,
        min(sliderPostion.dx + bezierRadius, size.width + lineIncreaseValue),
        sliderPostion.dy,
      )
      ..lineTo(size.width + lineIncreaseValue, linePostionY);

    canvas.drawPath(path, paint);
  }

  void _drawCircle(Canvas canvas, Size size, double radius, Offset pos) {
    final circlePaint = Paint()..color = Colors.black;
    canvas.drawCircle(pos, radius, circlePaint);
  }

  void _drawWindow(Canvas canvas, Size size) {
    // window setup
    final windowSize = Size(40, size.height * 0.25);
    final windowPaint = Paint()..color = windowColor;
    const windowRadius = Radius.circular(10);
    final windowLeftTopPoint =
        Offset(postion - (windowSize.width / 2), windowOffsetY);
    final windowRightBottomPoint = Offset(
        postion + (windowSize.width / 2), windowSize.height + windowOffsetY);

    // text setup
    final v = double.parse((size.width / postion).toStringAsFixed(1));
    final value = ((maxRange - minRange) ~/ v) + minRange;
    final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(maxLines: 1))
      ..pushStyle(
        ui.TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
      )
      ..addText("$value");

    // Call onChanged function.
    onChanged.call(value);

    final paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: windowSize.width));
    final textWidth = paragraph.computeLineMetrics().first.width;
    final textHeight = paragraph.computeLineMetrics().first.height;

    // draw window
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          windowLeftTopPoint.dx,
          windowLeftTopPoint.dy,
          windowRightBottomPoint.dx,
          windowRightBottomPoint.dy,
        ),
        windowRadius,
      ),
      windowPaint,
    );

    // draw text
    canvas.drawParagraph(
      paragraph,
      Offset(
        postion - (textWidth / 2),
        (windowSize.height / 2) - (textHeight / 2) + windowOffsetY,
      ),
    );
  }

  void _drawRangeText(Canvas canvas, Size size, String text, Offset postion) {
    final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle())
      ..pushStyle(
        ui.TextStyle(
          color: Colors.grey,
          fontSize: 14.0,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
      )
      ..addText(text);

    final paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: size.width / 2));

    final textWidth = paragraph.computeLineMetrics().first.width;

    canvas.drawParagraph(
        paragraph, Offset(postion.dx - textWidth / 2, postion.dy));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
