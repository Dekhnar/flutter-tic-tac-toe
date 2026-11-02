import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:tic_tac_toe_app/features/game/board/data/auth/firebase_player_identity.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/firestore_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/in_memory_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_providers.dart';
import 'package:tic_tac_toe_app/shared/firebase/online_availability_provider.dart';

/// Binds the contracts of `game_providers.dart`: the only place that knows the implementations. The online ones need
/// Firebase initialized, so they stay unbound without it.
List<Override> bindGameProviders({required bool isOnlineAvailable}) => [
  isOnlineAvailableProvider.overrideWithValue(isOnlineAvailable),
  localGameRepositoryProvider.overrideWith((ref) {
    final repository = InMemoryGameRepository();
    ref.onDispose(repository.dispose);
    return repository;
  }),
  if (isOnlineAvailable) ...[
    onlineGameRepositoryProvider.overrideWith((ref) => FirestoreGameRepository(firestore: FirebaseFirestore.instance)),
    playerIdentityProvider.overrideWith((ref) => FirebasePlayerIdentity(auth: FirebaseAuth.instance)),
  ],
];
