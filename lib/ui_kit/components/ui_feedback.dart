import 'package:flutter/widgets.dart';

enum UiSound { tap, back, toggle }

/// Lets ui_kit controls make their click sounds without knowing about the
/// AudioService: the app puts one above the navigator (spec 7.3).
class UiFeedback extends InheritedWidget {
  const UiFeedback({super.key, required this.onSound, required super.child});

  final ValueChanged<UiSound> onSound;

  /// Plays [sound] if a [UiFeedback] is above [context]; silent otherwise.
  static void play(BuildContext context, UiSound sound) =>
      context.getInheritedWidgetOfExactType<UiFeedback>()?.onSound(sound);

  @override
  bool updateShouldNotify(UiFeedback oldWidget) => false;
}
