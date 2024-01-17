import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SampleDir extends StatelessWidget {
  final String title;
  final Color background;
  final Color foreground;

  const SampleDir({
    required this.title,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;
    //final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () { Get.to(DirPage(title)); },
      child: Material(
        elevation: 2,
        borderRadius:
          BorderRadius.all(Radius.circular(20)),
        child: Container(
          width: Get.width,
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: textTheme.titleLarge!
                  .copyWith(
                    color: foreground,
                ),
              ), // Text
            ],
          ), // Column
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ), // BorderRadius
            color: background,
          ), // BoxDecoration
        ), // Container
      ), // Material
    );
  }
}