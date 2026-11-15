// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Deskovky';

  @override
  String get navGames => 'Jeux';

  @override
  String get navPlayers => 'Joueurs';

  @override
  String get navLeaderboards => 'Scores';

  @override
  String get navSettings => 'Réglages';

  @override
  String get comingSoon => 'Bientôt';

  @override
  String get panelPlayersOnDevice => 'Joueurs sur cet appareil';

  @override
  String get panelLeaderboardWeek => 'Classement de la semaine';

  @override
  String get panelLastReward => 'Dernière récompense';

  @override
  String get screenEmpty => 'Rien ici pour l’instant.';

  @override
  String playersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count joueurs',
      one: '$count joueur',
    );
    return '$_temp0';
  }

  @override
  String get avatarEditorTitle => 'Mon avatar';

  @override
  String get avatarSave => 'Enregistrer';

  @override
  String get avatarRandom => 'Au hasard';

  @override
  String get back => 'Retour';

  @override
  String get avatarTabFace => 'Visage';

  @override
  String get avatarTabSkin => 'Peau';

  @override
  String get avatarTabHair => 'Cheveux';

  @override
  String get avatarTabEyes => 'Yeux';

  @override
  String get avatarTabMouth => 'Bouche';

  @override
  String get avatarTabBackground => 'Fond';

  @override
  String get avatarHairColor => 'Couleur des cheveux';

  @override
  String get faceOval => 'ovale';

  @override
  String get faceRound => 'rond';

  @override
  String get faceWide => 'large';

  @override
  String get faceSquare => 'carré';

  @override
  String get hairShort => 'courts';

  @override
  String get hairLong => 'longs';

  @override
  String get hairCurly => 'bouclés';

  @override
  String get hairBun => 'chignon';

  @override
  String get hairSpiky => 'en pétard';

  @override
  String get hairPigtails => 'couettes';

  @override
  String get hairBob => 'carré';

  @override
  String get hairBraids => 'tresses';

  @override
  String get hairCap => 'casquette';

  @override
  String get hairBald => 'chauve';

  @override
  String get eyesRound => 'ronds';

  @override
  String get eyesHappy => 'joyeux';

  @override
  String get eyesWink => 'clin d’œil';

  @override
  String get eyesSleepy => 'endormis';

  @override
  String get eyesWide => 'grands ouverts';

  @override
  String get eyesLashes => 'avec des cils';

  @override
  String get mouthSmile => 'sourire';

  @override
  String get mouthOpen => 'ouverte';

  @override
  String get mouthFlat => 'droite';

  @override
  String get mouthGrin => 'grand sourire';

  @override
  String get mouthTongue => 'langue tirée';

  @override
  String get mouthSurprised => 'surprise';

  @override
  String get hairColorBlack => 'noir';

  @override
  String get hairColorBrown => 'brun';

  @override
  String get hairColorChestnut => 'châtain';

  @override
  String get hairColorBlond => 'blond';

  @override
  String get hairColorPlatinum => 'platine';

  @override
  String get hairColorRed => 'roux';

  @override
  String get hairColorGrey => 'gris';

  @override
  String get hairColorBlue => 'bleu';

  @override
  String skinTone(int n) {
    return 'Teint $n';
  }

  @override
  String backgroundColor(int n) {
    return 'Fond $n';
  }

  @override
  String get playersNew => 'Nouveau joueur';

  @override
  String get playersLimit => 'Cet appareil peut avoir 8 joueurs au maximum.';

  @override
  String get playersEmpty =>
      'Personne pour l’instant. Crée le premier joueur !';

  @override
  String playersNowPlaying(String name) {
    return '$name joue maintenant';
  }

  @override
  String get playerActiveTag => 'Joue';

  @override
  String playerEdit(String name) {
    return 'Modifier $name';
  }

  @override
  String playerDelete(String name) {
    return 'Supprimer $name';
  }

  @override
  String get profileName => 'Nom';

  @override
  String get profileErrorEmpty => 'Écris un nom.';

  @override
  String get profileErrorTooLong => '16 caractères au maximum.';

  @override
  String get profileErrorTaken => 'Un autre joueur a déjà ce nom.';

  @override
  String get profileErrorLimit =>
      'Cet appareil peut avoir 8 joueurs au maximum.';

  @override
  String deleteTitle(String name) {
    return 'Supprimer le joueur $name ?';
  }

  @override
  String get deleteMessage =>
      'Ses résultats seront supprimés aussi. Impossible de revenir en arrière.';

  @override
  String get deleteConfirm => 'Supprimer';

  @override
  String get discardTitle => 'Abandonner les changements ?';

  @override
  String get discardMessage =>
      'Les changements de ton avatar et de ton nom ne seront pas enregistrés.';

  @override
  String get discardConfirm => 'Abandonner';

  @override
  String get cancel => 'Annuler';

  @override
  String get homeHello => 'Salut,';

  @override
  String get homeSwitchPlayer => 'Changer de joueur';

  @override
  String get homeCreatePlayer => 'Créer un joueur';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSystem => 'Réglage du téléphone';

  @override
  String gamePlayersRange(int min, int max) {
    return '$min à $max joueurs';
  }

  @override
  String continueTitle(String game) {
    return 'Continuer : $game';
  }

  @override
  String get continueSaved => 'Partie en cours';

  @override
  String continueSummary(String players, String difficulty) {
    return '$players · $difficulty';
  }

  @override
  String seatSummary(String players, int humans, int robots) {
    return '$players ($humans + $robots 🤖)';
  }

  @override
  String get continuePlay => 'Jouer ▸';

  @override
  String get difficultyEasy => 'Facile';

  @override
  String get difficultyMedium => 'Moyen';

  @override
  String get difficultyHard => 'Difficile';

  @override
  String get setupPlayers => 'Nombre de joueurs';

  @override
  String seatsHumans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '$count personne',
    );
    return '$_temp0';
  }

  @override
  String seatsRobots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count robots',
      one: '$count robot',
    );
    return '$_temp0';
  }

  @override
  String get setupDifficulty => 'Niveau des robots';

  @override
  String get setupSpeed => 'Vitesse des robots';

  @override
  String get speedSlow => 'Lente';

  @override
  String get speedNormal => 'Normale';

  @override
  String get speedFast => 'Rapide';

  @override
  String get seatHuman => 'Humain';

  @override
  String get seatRobot => '🤖 Robot';

  @override
  String get setupLoaded => '↺ Réglages repris de ta dernière partie';

  @override
  String get setupFilled => 'places libres remplies par des robots';

  @override
  String get setupNoFreeProfile => 'Tous les joueurs sont déjà à la table.';

  @override
  String get seatMoveUp => 'Monter';

  @override
  String get seatMoveDown => 'Descendre';

  @override
  String get setupPlay => 'Jouer !';

  @override
  String get setupNeedPlayer => 'Crée d’abord un joueur.';

  @override
  String get robotName0 => 'Robo';

  @override
  String get robotName1 => 'Chip';

  @override
  String get robotName2 => 'Bolt';

  @override
  String get robotName3 => 'Buzz';

  @override
  String get hudExit => 'Quitter';

  @override
  String get hudPause => 'Pause';

  @override
  String get hudMusic => 'Musique';

  @override
  String get hudSfx => 'Effets sonores';

  @override
  String get exitTitle => 'Vraiment quitter ?';

  @override
  String get exitSaved => 'La partie en cours sera enregistrée.';

  @override
  String get exitNotSaved => 'La partie en cours ne sera pas enregistrée.';

  @override
  String get exitConfirm => 'Quitter';

  @override
  String get pauseResume => 'Continuer';

  @override
  String get pauseRestart => 'Recommencer';

  @override
  String get pauseRules => 'Règles';

  @override
  String get close => 'Fermer';

  @override
  String turnOf(String name) {
    return 'Au tour de $name';
  }

  @override
  String robotThinking(String name) {
    return '🤖 $name réfléchit…';
  }

  @override
  String get resumeFailed => 'Impossible de continuer la partie enregistrée.';

  @override
  String resultWins(String name) {
    return '$name gagne !';
  }

  @override
  String get resultDraw => 'Match nul !';

  @override
  String get resultPlayAgain => 'Rejouer';

  @override
  String get resultChangeSettings => 'Changer les réglages';

  @override
  String get resultHome => 'Accueil';

  @override
  String get resultRobotTag => 'robot';

  @override
  String resultSubtitle(String game, String difficulty) {
    return '$game · $difficulty';
  }

  @override
  String get seatReplacedByRobot =>
      'Les joueurs absents ont été remplacés par des robots.';

  @override
  String get settingsSound => 'Son';

  @override
  String get settingsMusic => 'Musique';

  @override
  String get settingsMusicVolume => 'Volume de la musique';

  @override
  String get settingsSfx => 'Effets sonores';

  @override
  String get settingsSfxVolume => 'Volume des effets';

  @override
  String get settingsVibration => 'Vibrations';

  @override
  String get settingsCredits => 'Crédits et licences';

  @override
  String get creditsSounds => 'Musique et sons';

  @override
  String get creditsFonts => 'Polices';

  @override
  String get creditsLibraries => 'Licences des bibliothèques';

  @override
  String creditsLicense(String license) {
    return 'Licence : $license';
  }

  @override
  String get badgeFirstWinTitle => 'Première victoire';

  @override
  String get badgeFirstWinDescription => 'Gagne ta première partie.';

  @override
  String get badgeStreak5Title => 'Cinq d’affilée';

  @override
  String get badgeStreak5Description => 'Gagne 5 parties d’affilée.';

  @override
  String get badgeGames10Title => 'Dix parties';

  @override
  String get badgeGames10Description => 'Joue 10 parties.';

  @override
  String get badgeHardWinTitle => 'Dompteur de robots';

  @override
  String get badgeHardWinDescription => 'Bats les robots en Difficile.';

  @override
  String get badgeAllGamesTitle => 'Explorateur';

  @override
  String get badgeAllGamesDescription => 'Joue à tous les jeux.';

  @override
  String get resultNewBadges => 'Nouveaux badges';

  @override
  String get leaderboardWeek => 'Semaine';

  @override
  String get leaderboardMonth => 'Mois';

  @override
  String get leaderboardAllTime => 'Depuis le début';

  @override
  String get leaderboardAllGames => 'Tous les jeux';

  @override
  String get leaderboardAnyDifficulty => 'Tous les niveaux';

  @override
  String get leaderboardEmpty =>
      'Personne pour l’instant. Termine une partie !';

  @override
  String leaderboardWins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count victoires',
      one: '$count victoire',
    );
    return '$_temp0';
  }

  @override
  String leaderboardDetail(int played, int rate) {
    String _temp0 = intl.Intl.pluralLogic(
      played,
      locale: localeName,
      other: '$played parties',
      one: '$played partie',
    );
    return '$_temp0 · $rate %';
  }

  @override
  String playerStats(String name) {
    return 'Statistiques : $name';
  }

  @override
  String get statsPlayed => 'Jouées';

  @override
  String get statsWins => 'Victoires';

  @override
  String get statsWinRate => 'Taux de victoire';

  @override
  String get statsBestStreak => 'Meilleure série';

  @override
  String get statsCurrentStreak => 'Série en cours';

  @override
  String get statsByGame => 'Par jeu';

  @override
  String statsBestScore(int score) {
    return 'Meilleur score : $score';
  }

  @override
  String statsFastestWin(String time) {
    return 'Victoire la plus rapide : $time';
  }

  @override
  String get statsBadges => 'Badges';

  @override
  String statsBadgeEarned(String date) {
    return 'Obtenu le $date';
  }

  @override
  String get statsNoGames => 'Aucune partie terminée pour l’instant.';

  @override
  String homeBestStars(int stars) {
    return 'Meilleure note : $stars étoiles sur 3';
  }

  @override
  String get resultPoints => 'Points';

  @override
  String get pointsWin => 'Victoire';

  @override
  String get pointsDraw => 'Match nul';

  @override
  String get pointsSecond => '2e place';

  @override
  String get pointsParticipation => 'Participation';

  @override
  String pointsStars(int count) {
    return 'Note $count ★';
  }

  @override
  String pointsStreak(int count) {
    return '$count victoires d’affilée';
  }

  @override
  String get pointsFirstToday => 'Première partie du jour';

  @override
  String get pointsRecord => 'Nouveau record perso';

  @override
  String pointsBadge(String name) {
    return 'Badge : $name';
  }

  @override
  String get pointsCapped => 'Beaucoup de victoires en Facile aujourd’hui';

  @override
  String get pointsGift => 'Cadeau d’un parent';

  @override
  String get pointsPurchase => 'Achat';

  @override
  String pointsTotal(int points) {
    return 'Total +$points ●';
  }

  @override
  String levelUp(int level) {
    return 'Nouveau niveau $level !';
  }

  @override
  String homePointsBalance(int points) {
    return 'Points : $points';
  }

  @override
  String levelShort(int level) {
    return 'Niv. $level';
  }

  @override
  String levelLabel(int level) {
    return 'Niveau $level';
  }

  @override
  String levelNext(int current, int needed) {
    return '$current / $needed ● jusqu’au niveau suivant';
  }

  @override
  String get levelMax => 'Niveau maximum !';

  @override
  String get statsBalance => 'Solde';

  @override
  String get statsTotalEarned => 'Total gagné';

  @override
  String get statsPointsHistory => 'Historique des points';

  @override
  String get settingsParents => 'Coin des parents';

  @override
  String get parentsGateTitle => 'Parents seulement';

  @override
  String parentsGateQuestion(int a, int b) {
    return 'Combien font $a × $b ?';
  }

  @override
  String get parentsGateWrong => 'Ce n’est pas ça.';

  @override
  String get parentsGateLocked => 'Trop d’essais. Réessaie dans une minute.';

  @override
  String get parentsGateOpen => 'Ouvrir';

  @override
  String get parentsGiftTitle => 'Offrir des points';

  @override
  String parentsGiftConfirm(int points, String name) {
    return 'Offrir $points ● à $name ?';
  }

  @override
  String get parentsGiftAction => 'Offrir';

  @override
  String parentsGiftDone(int points, String name) {
    return 'Offert : $points ● – $name';
  }

  @override
  String updateAvailable(String version) {
    return 'La nouvelle version $version est là';
  }

  @override
  String get updateNow => 'Mettre à jour';

  @override
  String get updateLater => 'Plus tard';

  @override
  String updateDownloading(int percent) {
    return 'Téléchargement… $percent %';
  }

  @override
  String get updateMandatory =>
      'Cette version est trop ancienne – mets-la à jour.';

  @override
  String get updateFailed => 'Le téléchargement a échoué. Réessaie plus tard.';

  @override
  String get updatePermissionTitle => 'Encore une autorisation';

  @override
  String get updatePermissionText =>
      'Android va demander si Deskovky peut installer des applis. C’est seulement pour la nouvelle version de Deskovky. Demande à un adulte d’activer l’interrupteur, puis reviens ici.';

  @override
  String get updatePermissionOpen => 'Ouvrir les réglages';

  @override
  String get settingsApp => 'Appli';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsCheckNow => 'Chercher une mise à jour';

  @override
  String get settingsAutoUpdate => 'Vérifier automatiquement';

  @override
  String get updateUpToDate => 'Tu as la version la plus récente.';

  @override
  String get updateCheckFailed =>
      'La vérification a échoué – l’appareil est-il connecté ?';

  @override
  String get itemCap => 'Casquette';

  @override
  String get itemEarsHeadband => 'Serre-tête à oreilles';

  @override
  String get itemFlowerWreath => 'Couronne de fleurs';

  @override
  String get itemTopHat => 'Haut-de-forme';

  @override
  String get itemVikingHelmet => 'Casque de viking';

  @override
  String get itemPirateBandana => 'Bandana de pirate';

  @override
  String get itemWizardHat => 'Chapeau de magicien';

  @override
  String get itemCrown => 'Couronne';

  @override
  String get itemHalo => 'Auréole';

  @override
  String get itemGlasses => 'Lunettes';

  @override
  String get itemMustache => 'Moustache';

  @override
  String get itemFacePaintStar => 'Maquillage étoile';

  @override
  String get itemSunglasses => 'Lunettes de soleil';

  @override
  String get itemHeroMask => 'Masque de héros';

  @override
  String get itemMonocle => 'Monocle';

  @override
  String get itemCarnivalMask => 'Masque de carnaval';

  @override
  String get itemLollipop => 'Sucette';

  @override
  String get itemBalloon => 'Ballon';

  @override
  String get itemIceCream => 'Glace';

  @override
  String get itemPhone => 'Téléphone';

  @override
  String get itemMicrophone => 'Micro';

  @override
  String get itemMagicWand => 'Baguette magique';

  @override
  String get itemTrophy => 'Trophée';

  @override
  String get itemKitten => 'Chaton';

  @override
  String get itemChick => 'Poussin';

  @override
  String get itemPuppy => 'Chiot';

  @override
  String get itemParrot => 'Perroquet';

  @override
  String get itemDragon => 'Petit dragon';

  @override
  String get itemWoodFrame => 'Cadre en bois';

  @override
  String get itemGoldFrame => 'Cadre doré';

  @override
  String get itemRainbowFrame => 'Cadre arc-en-ciel';

  @override
  String get itemFlameFrame => 'Cadre de flammes';

  @override
  String get itemStarFrame => 'Cadre étoilé';

  @override
  String get itemSparkles => 'Paillettes';

  @override
  String get itemBubbles => 'Bulles';

  @override
  String get itemSnow => 'Chute de neige';

  @override
  String get pointsReset => 'Un parent a remis les points à zéro';

  @override
  String get badgeWins50Title => 'Cinquante';

  @override
  String get badgeWins50Description =>
      'Gagne 50 parties. Récompense : un trophée à tenir.';

  @override
  String get badgeAllHardTitle => 'Maître de tous les jeux';

  @override
  String get badgeAllHardDescription =>
      'Bats les robots en Difficile dans chaque jeu. Récompense : un cadre étoilé.';

  @override
  String get badgeCollectorTitle => 'Collectionneur';

  @override
  String get badgeCollectorDescription => 'Achète 10 accessoires d’avatar.';

  @override
  String get shopTitle => 'Boutique';

  @override
  String shopTryOn(String name) {
    return 'Essayage : $name';
  }

  @override
  String get shopAll => 'Tout';

  @override
  String get slotHead => 'Tête';

  @override
  String get slotFace => 'Visage';

  @override
  String get slotHand => 'Main';

  @override
  String get slotPet => 'Animal';

  @override
  String get slotFrame => 'Cadre';

  @override
  String get slotEffect => 'Effet';

  @override
  String shopBuy(int price) {
    return 'Acheter pour $price ●';
  }

  @override
  String shopBuyConfirm(String name, int price) {
    return 'Acheter $name pour $price ● ?';
  }

  @override
  String get shopBuyAction => 'Acheter';

  @override
  String shopMissing(int points) {
    return 'Il te manque $points ●';
  }

  @override
  String shopLevelLock(int level) {
    return '🔒 Niveau $level';
  }

  @override
  String shopBadgeLock(String name) {
    return '🔒 Badge : $name';
  }

  @override
  String get shopOwned => 'À toi';

  @override
  String get shopEquipped => 'Porté';

  @override
  String get shopEquipNow => 'Le porter maintenant ?';

  @override
  String get shopEquip => 'Porter';

  @override
  String get shopUnequip => 'Enlever';

  @override
  String get shopNotNow => 'Pas maintenant';

  @override
  String shopNextLevel(int level, int next, int points) {
    return 'Niveau $level → $next · encore $points points';
  }

  @override
  String shopPlayerLevel(String name, int level) {
    return '$name · Niveau $level';
  }

  @override
  String get wardrobeTitle => 'Garde-robe';

  @override
  String get wardrobeEmpty =>
      'Rien ici pour l’instant. Achète des accessoires à la boutique.';

  @override
  String get wardrobeToShop => 'À la boutique';

  @override
  String wardrobeColour(String name) {
    return 'Couleur : $name';
  }

  @override
  String get colourGold => 'or';

  @override
  String get colourSilver => 'argent';

  @override
  String get colourRed => 'rouge';

  @override
  String get colourBlue => 'bleu';

  @override
  String get colourGreen => 'vert';

  @override
  String get colourYellow => 'jaune';

  @override
  String get colourBrown => 'marron';

  @override
  String get parentsResetTitle => 'Remettre à zéro points et accessoires';

  @override
  String get parentsReset => 'Remettre à zéro';

  @override
  String parentsResetConfirm(String name, int points) {
    return '$name va perdre $points ● et tous les accessoires achetés. Le niveau et les badges restent.';
  }

  @override
  String parentsResetDone(String name) {
    return '$name : points et accessoires remis à zéro.';
  }

  @override
  String resultCanBuy(String name, String item) {
    return '$name, tu peux maintenant acheter : $item !';
  }

  @override
  String pointsPurchaseItem(String item) {
    return 'Achat : $item';
  }

  @override
  String shopNewBadge(String badge) {
    return 'Nouveau badge : $badge !';
  }

  @override
  String shopNewBadgeReward(String description, int points) {
    return '$description Récompense +$points ●.';
  }

  @override
  String get shopHooray => 'Hourra !';

  @override
  String get shopNotEnough => 'Tu n’as pas assez de points pour ça maintenant.';

  @override
  String get shopFailed => 'Ça n’a pas marché. Réessaie.';

  @override
  String get updatePreparing => 'Préparation de la mise à jour…';

  @override
  String get setupDifficultySolo => 'Niveau';

  @override
  String get whereLabel => 'Où jouer';

  @override
  String get whereHere => 'Sur cet appareil';

  @override
  String get whereWifi => 'Chacun le sien (Wi-Fi)';

  @override
  String get trialTag => 'Essai';

  @override
  String get noWifi =>
      'Tu n’es pas sur le Wi-Fi. Connecte-toi au même Wi-Fi que les autres.';

  @override
  String get setupOpenRoom => 'Ouvrir le salon';

  @override
  String get roomTitle => 'Salon';

  @override
  String get roomCode => 'Code du salon';

  @override
  String get roomJoinHint =>
      'Les autres scannent le QR code avec l’appareil photo, ou touchent Rejoindre une partie.';

  @override
  String get slotOpen => 'Place libre';

  @override
  String get slotHere => '🏠 Ici';

  @override
  String get slotOwnDevice => '📱 Son appareil';

  @override
  String get slotReady => 'Prêt';

  @override
  String get slotWaiting => 'En attente';

  @override
  String get slotDisconnected => 'Déconnecté';

  @override
  String get slotMakeRobot => 'Ajouter un robot';

  @override
  String get slotAddLocal => 'Ajouter un joueur de cet appareil';

  @override
  String get slotLeaveOpen => 'Laisser libre';

  @override
  String get roomRemove => 'Retirer le joueur';

  @override
  String get roomStart => 'Lancer la partie';

  @override
  String get roomWaitReady => 'On attend que tout le monde soit prêt.';

  @override
  String get roomNoServer => 'Impossible d’ouvrir le salon.';

  @override
  String get homeJoin => 'Rejoindre une partie';

  @override
  String get joinWho => 'Qui joue sur cet appareil';

  @override
  String get joinRooms => 'Salons sur le réseau';

  @override
  String get joinSearching => 'Recherche de salons…';

  @override
  String get joinByCode => 'Code du salon (4 chiffres)';

  @override
  String get joinCodeNotFound => 'Aucun salon avec ce code sur le réseau.';

  @override
  String get joinAdvanced => 'Avancé';

  @override
  String get joinAddress => 'Adresse (IP:port)';

  @override
  String get joinConnect => 'Se connecter';

  @override
  String get joinFailed => 'Connexion impossible.';

  @override
  String get joinPickSomeone => 'Choisis au moins un joueur.';

  @override
  String get joinScanQr => 'Scanner le QR';

  @override
  String get joinQrRoom => 'Salon du QR code';

  @override
  String get joinOtherRoom => 'Choisir un autre salon';

  @override
  String get qrNotRoom =>
      'Ce n’est pas un QR code Deskovky. Scanne le code de l’écran Salon.';

  @override
  String get qrCameraDenied =>
      'Sans l’appareil photo, je ne peux pas lire le QR code. Autorise-le dans les réglages du téléphone, ou tape le code du salon.';

  @override
  String get qrScanTitle => 'Vise le QR code';

  @override
  String get byeVersion =>
      'L’hôte a une autre version de l’appli. Mettez tous à jour vers la même.';

  @override
  String get byeCode => 'Mauvais code de salon.';

  @override
  String get byeFull => 'Le salon est plein.';

  @override
  String get byeStarted => 'La partie a déjà commencé.';

  @override
  String get byeKicked => 'L’hôte t’a retiré du salon.';

  @override
  String get byeLost => 'La connexion avec l’hôte est perdue.';

  @override
  String get lobbyReady => 'Je suis prêt';

  @override
  String get lobbyNotReady => 'Pas encore';

  @override
  String get lobbySettings => 'Réglages de la partie (l’hôte choisit)';

  @override
  String get lobbyWaitStart => 'On attend que l’hôte lance la partie.';

  @override
  String get leaveRoom => 'Quitter le salon';

  @override
  String joinFree(int count) {
    return 'Places libres : $count';
  }

  @override
  String get netDecideTitle => 'Un joueur n’est pas revenu';

  @override
  String get netWaitMore => 'Attendre encore';

  @override
  String get netReplaceRobot => 'Remplacer par un robot';

  @override
  String get netEndGame => 'Terminer la partie';

  @override
  String get netLeave => 'Quitter la partie';

  @override
  String get netRematch => 'Revanche';

  @override
  String get netWaitHost => 'On attend l’hôte…';

  @override
  String get byeEnded => 'L’hôte a terminé la partie.';

  @override
  String netYourTurn(String name) {
    return '$name, c’est ton tour !';
  }

  @override
  String netTurnRemote(String name) {
    return 'Au tour de $name (sur son appareil)';
  }

  @override
  String netWaiting(String name, String time) {
    return '$name : déconnecté – on attend ($time)';
  }

  @override
  String get netReconnect => 'Se reconnecter';

  @override
  String resultNotThisTime(String name) {
    return '$name, pas cette fois';
  }

  @override
  String get joinLinkBusy =>
      'Tu joues déjà. Quitte d’abord la partie ou le salon.';

  @override
  String get familyTitle => 'Famille';

  @override
  String get familyIntro =>
      'Relie les appareils de ta famille : profils, points, récompenses et historique des parties seront les mêmes sur tous. Le Wi-Fi de la maison suffit, pas besoin d’internet.';

  @override
  String get familyCreate => 'Créer une famille';

  @override
  String get familyJoin => 'Rejoindre une famille';

  @override
  String get familyJoinOther => 'Rejoindre une autre famille';

  @override
  String get familyJoinOtherWarning =>
      'Cet appareil fait déjà partie d’une famille. En rejoindre une autre fait quitter la famille actuelle ; les profils de cet appareil seront proposés pour l’association.';

  @override
  String get familyJoinOtherConfirm => 'Rejoindre quand même';

  @override
  String get familyAddDevice => 'Ajouter un appareil';

  @override
  String get familyQrHint =>
      'Sur le nouvel appareil, ouvre Réglages → Coin des parents → Famille → Rejoindre une famille et scanne ce code. Les deux appareils doivent être sur le même Wi-Fi.';

  @override
  String get familyDevices => 'Appareils de la famille';

  @override
  String get familyThisDevice => 'cet appareil';

  @override
  String get familyNeverSynced => 'pas encore synchronisé';

  @override
  String get familyRemove => 'Retirer de la famille';

  @override
  String get familyRemoveMessage =>
      'L’appareil ne recevra plus les profils ni les points. Les données déjà dessus y restent.';

  @override
  String get familyRemoved => 'retiré';

  @override
  String get familyJoined => 'C’est fait – tu fais partie de la famille !';

  @override
  String get familyJoinFailed =>
      'Impossible de rejoindre la famille. Les deux appareils sont-ils sur le même Wi-Fi, avec Famille ouvert sur l’autre ?';

  @override
  String get familyNotACode => 'Ce n’est pas un code de famille.';

  @override
  String get familyUpdateApps =>
      'Un appareil a une autre version de l’appli. Mets l’appli à jour sur chaque appareil.';

  @override
  String get familyCodeInJoin =>
      'C’est un code de famille. Ajoute l’appareil dans Réglages → Coin des parents → Famille.';

  @override
  String get familySynced => 'Synchronisé avec la famille';

  @override
  String get deviceTablet => 'Tablette';

  @override
  String get devicePhone => 'Téléphone';

  @override
  String familyLastSync(String time) {
    return 'dernière synchro $time';
  }

  @override
  String familyRemoveTitle(String name) {
    return 'Retirer $name de la famille ?';
  }

  @override
  String get pairTitle => 'Associer les profils';

  @override
  String get pairQuestion => 'Est-ce la même personne ?';

  @override
  String get pairMerge => 'Oui, les réunir';

  @override
  String get pairKeep => 'Non, deux personnes';

  @override
  String get pairLook => 'Voir après la réunion';

  @override
  String get pairManual => 'Associer à la main';

  @override
  String get pairFirst => 'Profil';

  @override
  String get pairSecond => 'va avec';

  @override
  String get pairNone => 'Plus de paires.';

  @override
  String get refundTitle => 'Les points sont revenus';

  @override
  String get refundOk => 'Compris';

  @override
  String familyPairs(int count) {
    return 'Paires possibles ($count)';
  }

  @override
  String refundNotice(String item) {
    return 'Tes points pour $item sont revenus – il n’y avait pas assez de points pour les deux.';
  }

  @override
  String get inviteFamily => 'Inviter la famille';

  @override
  String get inviteSent => 'Invitation envoyée.';

  @override
  String get inviteNoDevice =>
      'Aucun appareil de la famille trouvé sur le réseau.';

  @override
  String get invitePlay => 'Jouer';

  @override
  String get inviteLater => 'Pas maintenant';

  @override
  String inviteTitle(String host, String game) {
    return '$host t’invite à jouer à $game – on joue ?';
  }

  @override
  String pointsRefundDuplicate(String item) {
    return 'Remboursé : $item – acheté deux fois';
  }

  @override
  String pointsRefundNotEnough(String item) {
    return 'Remboursé : $item – pas assez de points';
  }

  @override
  String get setupElsewhere => 'Sur un autre appareil';

  @override
  String get setupBusyTag => 'Dans une autre partie';

  @override
  String get setupInvitePlay => 'Inviter et jouer';

  @override
  String get slotInvited => 'Invité, en attente';

  @override
  String inviteFailed(String name) {
    return 'Impossible d’envoyer l’invitation à $name.';
  }

  @override
  String get inviteNotHere => 'Pas sur le Wi-Fi';

  @override
  String get navDonations => 'Soutenir';

  @override
  String get donationsTitle => 'Soutenir Deskovky';

  @override
  String get donationsIntro =>
      'Deskovky est fait à la maison, pour les familles avec enfants. Il est gratuit et le restera. S’il vous fait plaisir, vous pouvez faire un don libre pour son développement.';

  @override
  String get donationsFreeTitle => 'Tout le jeu est gratuit';

  @override
  String get donationsFreeText =>
      'Pas de niveaux payants, rien ne se débloque avec de l’argent.';

  @override
  String get donationsNoAdsTitle => 'Pas de pub';

  @override
  String get donationsNoAdsText =>
      'Rien ne distrait les enfants et rien ne les pousse à acheter.';

  @override
  String get donationsNoDataTitle => 'Pas de collecte de données';

  @override
  String get donationsNoDataText =>
      'Pas de compte, pas de connexion. Les profils et les résultats restent sur vos appareils.';

  @override
  String get donationsOfflineTitle => 'Sûr, sans internet';

  @override
  String get donationsOfflineText =>
      'Il fonctionne hors ligne et n’envoie rien sur vous nulle part. Il utilise internet seulement pour télécharger une nouvelle version.';

  @override
  String get donationsFamilyTitle => 'Toute la famille joue';

  @override
  String get donationsFamilyText =>
      'Autour d’une table, ou chacun le sien sur le Wi-Fi de la maison. Les appareils de la famille partagent les données seulement entre eux.';

  @override
  String get donationsKidsTitle => 'Pour les plus petits aussi';

  @override
  String get donationsKidsText =>
      'Des robots à trois niveaux, des règles en images, de gros boutons et un coin des parents.';

  @override
  String get donationsEveryoneTitle => 'Pour tout le monde';

  @override
  String get donationsEveryoneText =>
      'Fonctionne avec un lecteur d’écran, a des repères pour les daltoniens et parle dix langues.';

  @override
  String get donationsGrowingTitle => 'De nouveaux jeux arrivent';

  @override
  String get donationsGrowingText =>
      'Neuf jeux et d’autres en route – certains souhaités par des enfants.';

  @override
  String get donationsWhy =>
      'Un don aide à payer le temps passé à créer de nouveaux jeux et les frais de Google Play.';

  @override
  String get donationsSoon =>
      'Les dons seront possibles quand le jeu sera sur Google Play. Merci !';

  @override
  String get familyRename => 'Renommer l’appareil';

  @override
  String get familyOnline => 'Deskovky est lancé';

  @override
  String get familyOffline => 'Indisponible';

  @override
  String familyPlaysNow(String name) {
    return '$name joue maintenant';
  }

  @override
  String get settingsShareApp => 'Installer sur un autre appareil';

  @override
  String get shareAppTitle => 'Deskovky sur un autre appareil';

  @override
  String get shareAppHint =>
      'Scanne le code avec l’appareil photo de l’autre téléphone ou tablette. La page avec la version la plus récente s’ouvre : télécharge le fichier deskovky-….apk et ouvre-le.';

  @override
  String get inviteToAllDevices =>
      'L’invitation arrive sur tous les appareils du Wi-Fi';

  @override
  String get parentsReportBug => 'Signaler un bug';

  @override
  String get parentsReportBugHint =>
      'Ouvre un court formulaire (sans connexion) pour décrire le bug. N’écris pas de prénoms d’enfants ni d’autres données personnelles.';

  @override
  String get bugReportNoBrowser =>
      'Le navigateur n’a pas pu s’ouvrir. Tu peux signaler le bug ici :';

  @override
  String get saveFailed => 'La partie n\'a pas pu être enregistrée.';
}
