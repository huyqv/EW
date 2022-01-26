import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/utils/color_res.dart';
import 'package:sample/widgets/ui.dart';

import 'base_page.dart';

/// Providers are declared globally and specifies how to create a state
final counterProvider = StateProvider((ref) => 0);

class HomePage extends BasePage {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return defaultScaffold(
      child: Stack(
        children: [
          Center(
            child: Consumer(builder: (context, ref, _) {
              int count = ref.watch(counterProvider.state).state;
              return Text(
                '$count',
                style: const TextStyle(fontSize: 32),
              );
            }),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              backgroundColor: ColorRes.primary,

              /// The read method is an utility to read a provider without listening to it
              onPressed: () => ref.read(counterProvider.state).state++,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
