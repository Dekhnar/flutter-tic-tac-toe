import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/shared/routing/auto_router.dart';
part 'app_router_provider.g.dart';

@riverpod
AppRouter appRouter(Ref ref) => AppRouter();
