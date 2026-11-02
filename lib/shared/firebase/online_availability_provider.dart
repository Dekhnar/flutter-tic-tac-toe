import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'online_availability_provider.g.dart';

/// Whether Firebase was initialized, overridden in `main` once the initialization settled.
@Riverpod(keepAlive: true)
bool isOnlineAvailable(Ref ref) => false;
