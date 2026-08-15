import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The app's single source of "now".
///
/// Sample data is generated relative to this, and the feed and analytics group
/// by it. Reading both from one provider keeps them in agreement — otherwise
/// data pinned to one clock gets bucketed against another, and day labels like
/// "Today" silently drift. Tests override this once instead of pinning every
/// repository separately.
final nowProvider = Provider<DateTime Function()>((ref) => DateTime.now);
