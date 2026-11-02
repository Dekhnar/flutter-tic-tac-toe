import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'online_availability_provider.g.dart';

/// Whether Firebase is initialized; `main` overrides it once the initialization settled.
@riverpod
bool isOnlineAvailable(Ref ref) => throw UnimplementedError('isOnlineAvailableProvider must be overridden in main');
