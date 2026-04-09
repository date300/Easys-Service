  int _indexFromLocation(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/messages')) return 1; // নতুন
    if (location.startsWith('/categories')) return 2; // নতুন (মাঝখানের বাটন)
    if (location.startsWith('/cart')) return 3; // নতুন
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onNavTap(BuildContext context, int index) {
    ref.read(isDetailViewProvider.notifier).state = false;
    ref.read(detailViewTitleProvider.notifier).state = '';

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/messages'); // নতুন
        break;
      case 2:
        context.go('/categories'); // মাঝখানের বাটন
        break;
      case 3:
        context.go('/cart'); // নতুন
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
