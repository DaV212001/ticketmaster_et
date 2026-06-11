import 'package:flutter/material.dart';

import '../api_call_status.dart';
import '../error_card.dart';
import '../error_data.dart';

class LoadedWidget extends StatelessWidget {
  final ApiCallStatus apiCallStatus;
  final ErrorData? errorData;
  final Widget child;
  final Widget? errorChild;
  final Widget loadingChild;
  final VoidCallback? onReload;
  const LoadedWidget({
    super.key,
    required this.apiCallStatus,
    this.errorData,
    required this.child,
    required this.loadingChild,
    this.errorChild,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    if (apiCallStatus == ApiCallStatus.loading) {
      return loadingChild;
    } else {
      return apiCallStatus == ApiCallStatus.error
          ? Center(
              child: GestureDetector(
                onTap: onReload,
                child: errorChild ??
                    ErrorCard(errorData: errorData!, refresh: onReload!),
              ),
            )
          : child;
    }
  }
}

class LoadedListWidget extends StatelessWidget {
  ///Api call status governing this list
  final ApiCallStatus apiCallStatus;

  ///We will construct an error card based on this error data.
  ///You have to provide this if you don't want to provide your own error child
  final ErrorData? errorData;

  ///What you want to happen when a user encounters an error(if you haven't provided your own error child) or pulls down to refresh
  final Future<void> Function() onReload;

  ///What you want to display when the list is not empty, (set shrinkWrap to true if using a ListView)
  final Widget child;

  ///Your own custom widget to display when an error occurs
  final Widget? errorChild;

  ///What you want to display when the list is still loading
  final Widget loadingChild;

  ///The list you want to display
  final List list;

  ///What you want to display when the list is empty
  final Widget onEmpty;

  final bool? scrollToRefresh;
  const LoadedListWidget({
    super.key,
    required this.apiCallStatus,
    this.errorData,
    required this.child,
    required this.loadingChild,
    this.errorChild,
    required this.list,
    required this.onEmpty,
    required this.onReload,
    this.scrollToRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return scrollToRefresh == false
        ? apiCallStatus == ApiCallStatus.loading
            ? loadingChild
            : apiCallStatus == ApiCallStatus.error
                ? Center(
                    child: errorChild ??
                        ErrorCard(errorData: errorData!, refresh: onReload),
                  )
                : list.isEmpty
                    ? onEmpty
                    : SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            scrollToRefresh == false
                                ? child
                                : RefreshIndicator(
                                    onRefresh: onReload, child: child),
                          ],
                        ),
                      )
        : RefreshIndicator(
            onRefresh: onReload,
            child: apiCallStatus == ApiCallStatus.loading
                ? loadingChild
                : apiCallStatus == ApiCallStatus.error
                    ? Center(
                        child: errorChild ??
                            ErrorCard(errorData: errorData!, refresh: onReload),
                      )
                    : list.isEmpty
                        ? onEmpty
                        : SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                scrollToRefresh == false
                                    ? child
                                    : RefreshIndicator(
                                        onRefresh: onReload,
                                        child: child,
                                      ),
                                const SizedBox(height: 70),
                              ],
                            ),
                          ),
          );
  }
}

/// A reusable wrapper widget that displays a [GridView] while automatically handling:
/// - Loading state
/// - Error state
/// - Empty state
/// - Pull-to-refresh functionality
///
/// This widget works similarly to [LoadedListWidget], but is designed for grid layouts.
/// Simply pass the required state variables, callbacks, and a GridView child.
///
/// Example usage:
/// ```dart
/// LoadedGridWidget(
///   apiCallStatus: controller.loadingStatus.value,
///   errorData: controller.errorData.value,
///   onReload: controller.fetchItems,
///   list: controller.items,
///   onEmpty: const Center(child: Text("No items found")),
///   loadingChild: const CircularProgressIndicator(),
///   gridChild: GridView.builder(
///     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
///       crossAxisCount: 2,
///       mainAxisSpacing: 8,
///       crossAxisSpacing: 8,
///     ),
///     itemCount: controller.items.length,
///     itemBuilder: (context, index) {
///       return YourGridItemWidget(item: controller.items[index]);
///     },
///   ),
/// )
/// ```
class LoadedGridWidget extends StatelessWidget {
  /// Current API call status (loading, error, success, etc.)
  final ApiCallStatus apiCallStatus;

  /// Error information for displaying an error message or image.
  /// Required if [errorChild] is not provided.
  final ErrorData? errorData;

  /// Callback triggered when a user pulls down to refresh or taps to retry after an error.
  final Future<void> Function() onReload;

  /// Widget to display when the grid has items to show.
  /// Typically a [GridView] or any scrollable widget.
  final Widget gridChild;

  /// Optional custom widget to display when an error occurs.
  /// If null, a default [ErrorCard] will be shown.
  final Widget? errorChild;

  /// Widget to display when the grid is loading.
  final Widget loadingChild;

  /// The data list used to determine if the grid is empty.
  /// This should be the same list used to build your grid items.
  final List list;

  /// Widget to display when the grid is empty.
  final Widget onEmpty;

  const LoadedGridWidget({
    super.key,
    required this.apiCallStatus,
    this.errorData,
    required this.onReload,
    required this.gridChild,
    required this.loadingChild,
    this.errorChild,
    required this.list,
    required this.onEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onReload,
      child: apiCallStatus == ApiCallStatus.loading
          ? loadingChild
          : apiCallStatus == ApiCallStatus.error
              ? Center(
                  child: errorChild ??
                      ErrorCard(errorData: errorData!, refresh: onReload),
                )
              : list.isEmpty
                  ? onEmpty
                  : gridChild,
    );
  }
}
