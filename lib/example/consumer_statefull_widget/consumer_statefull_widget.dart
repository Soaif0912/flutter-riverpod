import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_statemanagement/example/consumer_statefull_widget/provider.dart';

class ConsumerStatefullWidgetutorial extends ConsumerStatefulWidget {
  const ConsumerStatefullWidgetutorial({super.key});

  @override
  ConsumerState createState() => _ConsumerStatefullWidgetutorialState();
}

class _ConsumerStatefullWidgetutorialState
    extends ConsumerState<ConsumerStatefullWidgetutorial> {
  late final TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '');
    _controller.addListener(
      () => ref.read(textProvider.notifier).state = _controller.text,
    );

    // Schedule update after the first frame so it does not mutate state during initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.text = 'ABC';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            TextField(controller: _controller),
            Text(ref.watch(textProvider)),
          ],
        ),
      ),
    );
  }
}
