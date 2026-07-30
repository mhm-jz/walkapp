import 'package:flutter/material.dart';

class EmbeddedDestinationPage extends StatelessWidget {
  const EmbeddedDestinationPage({
    required this.title,
    required this.bodyBuilder,
    this.showEmbeddedHeading = false,
    super.key,
  });

  final String title;
  final Widget Function(bool showHeading) bodyBuilder;
  final bool showEmbeddedHeading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: Text(title)),
      body: SafeArea(top: false, child: bodyBuilder(showEmbeddedHeading)),
    );
  }
}
