import 'package:flutter/material.dart';

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with  SingleTickerProviderStateMixin{
  late AnimationController _controller;
@override
void initState(){

  super.initState();
  _controller = AnimationController(vsync: 
  this,
  duration: Duration(milliseconds: 1200),
  )..repeat();
}
@override
void dispose(){
  _controller.stop();
  _controller.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
           borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
           gradient: LinearGradient(
            begin: Alignment(-1.0 + _controller.value * 2, 0),
            end: Alignment(1.0 + _controller.value * 2, 0),
            colors: isDark
            ?const [ Color(0xFF1A2030),
                      Color(0xFF232D40),
                      Color(0xFF1A2030),] :
                      const [
                      Color(0xFFE2E5EA),
                      Color(0xFFF0F2F5),
                      Color(0xFFE2E5EA),
                    ], )
        ),
      
      );
      },
    );
  }
}
