import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/app.dart';
import 'package:tic_tac_toe_app/composition.dart';
import 'package:tic_tac_toe_app/features/game/application/game_create_input.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session_starter.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/firestore_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/domain/player_identity.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';

import 'shared/golden_test_utils/devices.dart';

const _jessy = PlayerId('jessy-uid');

void main() {
  ProviderContainer containerWith({required OnlineServices? online}) {
    final container = ProviderContainer(overrides: bindGameProviders(online: online));
    addTearDown(container.dispose);
    return container;
  }

  testWidgets('a build without Firebase options starts, and its online mode says it is unavailable', (tester) async {
    tester.view.physicalSize = GoldenScreen.iphone11.size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final container = await createAppContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const App()));
    await tester.pumpAndSettle();
    await tester.tap(find.text(I18n.current.online1v1));
    await tester.pumpAndSettle();

    expect(find.text(I18n.current.onlineUnavailable), findsOneWidget);
  });

  test('without online services, local games start and online ones are unavailable', () async {
    final starter = containerWith(online: null).read(gameSessionStarterProvider);

    expect(
      await starter.start(GameCreateInput.offline(guestName: 'Mario', hostName: 'Jessy')),
      isA<LocalGameSession>(),
    );
    await expectLater(
      starter.start(GameCreateInput.createOnlineLobby(hostName: 'Jessy')),
      throwsA(isA<OnlineUnavailableException>()),
    );
  });

  test('with online services, online games are created with them', () async {
    final firestore = FakeFirebaseFirestore();
    final container = containerWith(
      online: (repository: FirestoreGameRepository(firestore: firestore), identity: const _SignedIn(_jessy)),
    );

    final session = await container
        .read(gameSessionStarterProvider)
        .start(GameCreateInput.createOnlineLobby(hostName: 'Jessy'));

    expect(session.me, _jessy);
    expect((await firestore.collection('games').doc(session.gameId.value).get()).exists, isTrue);
  });
}

final class _SignedIn implements PlayerIdentity {
  const _SignedIn(this._player);

  final PlayerId _player;

  @override
  Future<PlayerId> signIn() async => _player;
}
