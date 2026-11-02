import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'online_availability_provider.g.dart';

/// Whether Firebase is initialized: `composition.dart` binds it once the initialization settled.
@riverpod
bool isOnlineAvailable(Ref ref) => throw UnimplementedError('isOnlineAvailableProvider is bound in composition');
