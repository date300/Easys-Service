// lib/helpers/detail_navigation_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';

class DetailViewWrapper extends ConsumerStatefulWidget {
  final String title;
  final Widget child;
  
  const DetailViewWrapper({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  @override
  ConsumerState<DetailViewWrapper> createState() => _DetailViewWrapperState();
}

class _DetailViewWrapperState extends ConsumerState<DetailViewWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(isDetailViewProvider.notifier).state = true;
      ref.read(detailViewTitleProvider.notifier).state = widget.title;
    });
  }

  @override
  void dispose() {
    ref.read(isDetailViewProvider.notifier).state = false;
    ref.read(detailViewTitleProvider.notifier).state = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

void enterDetailView(WidgetRef ref, {required String title}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(isDetailViewProvider.notifier).state = true;
    ref.read(detailViewTitleProvider.notifier).state = title;
  });
}

void exitDetailView(WidgetRef ref) {
  ref.read(isDetailViewProvider.notifier).state = false;
  ref.read(detailViewTitleProvider.notifier).state = '';
}
