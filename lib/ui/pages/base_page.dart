import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/ui/pages/base_view.dart';
import 'package:sample/ui/widgets/alert.dart';
import 'package:sample/ui/widgets/progress.dart';

final sampleProvider = StateProvider((ref) => 0);

//ignore: must_be_immutable
abstract class BasePage extends ConsumerWidget
    with ProgressWidget, Alert, BaseView {

  BasePage({Key? key}) : super(key: key);

}

abstract class BaseStatefulWidget extends ConsumerStatefulWidget {
  const BaseStatefulWidget({Key? key}) : super(key: key);
}

abstract class BaseState<Page extends BaseStatefulWidget>
    extends ConsumerState<Page>
    with ProgressWidget, Alert, BaseView {

  @override
  void initState() {

    super.initState();
  }


  void appShowBottomSheet(Widget  widget) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40))),
        builder: (context) => widget);
  }
}
