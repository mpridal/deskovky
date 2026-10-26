import 'package:flutter/material.dart';

import '../game/difficulty.dart';
import 'badge.dart';

/// Badges for any game (spec 5.5). Games add their own via `GameModule.badges`.
const frameworkBadges = <BadgeDef>[
  BadgeDef(
    id: 'first_win',
    titleKey: 'badgeFirstWinTitle',
    descriptionKey: 'badgeFirstWinDescription',
    icon: Icons.emoji_events,
    reward: 15,
    condition: BadgeCondition.wins(1),
  ),
  BadgeDef(
    id: 'streak5',
    titleKey: 'badgeStreak5Title',
    descriptionKey: 'badgeStreak5Description',
    icon: Icons.local_fire_department,
    reward: 30,
    condition: BadgeCondition.winStreak(5),
  ),
  BadgeDef(
    id: 'games10',
    titleKey: 'badgeGames10Title',
    descriptionKey: 'badgeGames10Description',
    icon: Icons.casino,
    reward: 15,
    condition: BadgeCondition.played(10),
  ),
  BadgeDef(
    id: 'hard_win',
    titleKey: 'badgeHardWinTitle',
    descriptionKey: 'badgeHardWinDescription',
    icon: Icons.smart_toy,
    reward: 30,
    condition: BadgeCondition.wonAgainst(Difficulty.hard),
  ),
  BadgeDef(
    id: 'all_games',
    titleKey: 'badgeAllGamesTitle',
    descriptionKey: 'badgeAllGamesDescription',
    icon: Icons.explore,
    reward: 20,
    condition: BadgeCondition.allGames(),
  ),
];
