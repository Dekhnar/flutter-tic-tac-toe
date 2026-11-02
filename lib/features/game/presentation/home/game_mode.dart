import 'package:tic_tac_toe_app/design_system/components/lists/right_side_slider.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';

enum GameMode { online1v1, offline1v1, offlineVsAi }

extension GameModeSliderItem on GameMode {
  SliderItem<GameMode> toSliderItem(I18n i18n) => switch (this) {
    GameMode.online1v1 => SliderItem(value: this, title: i18n.online1v1, description: i18n.playFriendOnline),
    GameMode.offline1v1 => SliderItem(value: this, title: i18n.local1v1, description: i18n.playOnSameDevice),
    GameMode.offlineVsAi => SliderItem(value: this, title: i18n.soloVsAi, description: i18n.playAgainstAi),
  };
}
