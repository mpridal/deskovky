// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Deskovky';

  @override
  String get navGames => 'Jogos';

  @override
  String get navPlayers => 'Jogadores';

  @override
  String get navLeaderboards => 'Ranking';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get comingSoon => 'Em breve';

  @override
  String get panelPlayersOnDevice => 'Jogadores neste aparelho';

  @override
  String get panelLeaderboardWeek => 'Ranking da semana';

  @override
  String get panelLastReward => 'Último prêmio';

  @override
  String get screenEmpty => 'Ainda não tem nada aqui.';

  @override
  String playersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jogadores',
      one: '$count jogador',
    );
    return '$_temp0';
  }

  @override
  String get avatarEditorTitle => 'Meu avatar';

  @override
  String get avatarSave => 'Salvar';

  @override
  String get avatarRandom => 'Aleatório';

  @override
  String get back => 'Voltar';

  @override
  String get avatarTabFace => 'Rosto';

  @override
  String get avatarTabSkin => 'Pele';

  @override
  String get avatarTabHair => 'Cabelo';

  @override
  String get avatarTabEyes => 'Olhos';

  @override
  String get avatarTabMouth => 'Boca';

  @override
  String get avatarTabBackground => 'Fundo';

  @override
  String get avatarHairColor => 'Cor do cabelo';

  @override
  String get faceOval => 'oval';

  @override
  String get faceRound => 'redondo';

  @override
  String get faceWide => 'largo';

  @override
  String get faceSquare => 'quadrado';

  @override
  String get hairShort => 'curto';

  @override
  String get hairLong => 'comprido';

  @override
  String get hairCurly => 'cacheado';

  @override
  String get hairBun => 'coque';

  @override
  String get hairSpiky => 'espetado';

  @override
  String get hairPigtails => 'maria-chiquinha';

  @override
  String get hairBob => 'chanel';

  @override
  String get hairBraids => 'tranças';

  @override
  String get hairCap => 'boné';

  @override
  String get hairBald => 'careca';

  @override
  String get eyesRound => 'redondos';

  @override
  String get eyesHappy => 'felizes';

  @override
  String get eyesWink => 'piscando';

  @override
  String get eyesSleepy => 'sonolentos';

  @override
  String get eyesWide => 'arregalados';

  @override
  String get eyesLashes => 'com cílios';

  @override
  String get mouthSmile => 'sorriso';

  @override
  String get mouthOpen => 'aberta';

  @override
  String get mouthFlat => 'reta';

  @override
  String get mouthGrin => 'sorrisão';

  @override
  String get mouthTongue => 'língua de fora';

  @override
  String get mouthSurprised => 'surpresa';

  @override
  String get hairColorBlack => 'preto';

  @override
  String get hairColorBrown => 'castanho';

  @override
  String get hairColorChestnut => 'acaju';

  @override
  String get hairColorBlond => 'loiro';

  @override
  String get hairColorPlatinum => 'platinado';

  @override
  String get hairColorRed => 'ruivo';

  @override
  String get hairColorGrey => 'grisalho';

  @override
  String get hairColorBlue => 'azul';

  @override
  String skinTone(int n) {
    return 'Tom de pele $n';
  }

  @override
  String backgroundColor(int n) {
    return 'Fundo $n';
  }

  @override
  String get playersNew => 'Novo jogador';

  @override
  String get playersLimit => 'Este aparelho pode ter no máximo 8 jogadores.';

  @override
  String get playersEmpty =>
      'Ainda não tem ninguém aqui. Crie o primeiro jogador!';

  @override
  String playersNowPlaying(String name) {
    return '$name está jogando agora';
  }

  @override
  String get playerActiveTag => 'Jogando';

  @override
  String playerEdit(String name) {
    return 'Editar $name';
  }

  @override
  String playerDelete(String name) {
    return 'Excluir $name';
  }

  @override
  String get profileName => 'Nome';

  @override
  String get profileErrorEmpty => 'Digite um nome.';

  @override
  String get profileErrorTooLong => 'No máximo 16 caracteres.';

  @override
  String get profileErrorTaken => 'Outro jogador já tem esse nome.';

  @override
  String get profileErrorLimit =>
      'Este aparelho pode ter no máximo 8 jogadores.';

  @override
  String deleteTitle(String name) {
    return 'Excluir o jogador $name?';
  }

  @override
  String get deleteMessage =>
      'Os resultados também serão excluídos. Isso não pode ser desfeito.';

  @override
  String get deleteConfirm => 'Excluir';

  @override
  String get discardTitle => 'Descartar alterações?';

  @override
  String get discardMessage =>
      'As mudanças no avatar e no nome não serão salvas.';

  @override
  String get discardConfirm => 'Descartar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get homeHello => 'Oi,';

  @override
  String get homeSwitchPlayer => 'Trocar jogador';

  @override
  String get homeCreatePlayer => 'Criar jogador';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Igual ao celular';

  @override
  String gamePlayersRange(int min, int max) {
    return '$min–$max jogadores';
  }

  @override
  String continueTitle(String game) {
    return 'Continuar: $game';
  }

  @override
  String get continueSaved => 'Jogo em andamento';

  @override
  String continueSummary(String players, String difficulty) {
    return '$players · $difficulty';
  }

  @override
  String seatSummary(String players, int humans, int robots) {
    return '$players ($humans + $robots 🤖)';
  }

  @override
  String get continuePlay => 'Jogar ▸';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Médio';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get setupPlayers => 'Número de jogadores';

  @override
  String seatsHumans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas',
      one: '$count pessoa',
    );
    return '$_temp0';
  }

  @override
  String seatsRobots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count robôs',
      one: '$count robô',
    );
    return '$_temp0';
  }

  @override
  String get setupDifficulty => 'Dificuldade dos robôs';

  @override
  String get setupSpeed => 'Velocidade dos robôs';

  @override
  String get speedSlow => 'Devagar';

  @override
  String get speedNormal => 'Normal';

  @override
  String get speedFast => 'Rápido';

  @override
  String get seatHuman => 'Pessoa';

  @override
  String get seatRobot => '🤖 Robô';

  @override
  String get setupLoaded => '↺ Ajustes carregados do seu último jogo';

  @override
  String get setupFilled => 'lugares livres preenchidos com robôs';

  @override
  String get setupNoFreeProfile => 'Todos os jogadores já estão na mesa.';

  @override
  String get seatMoveUp => 'Subir';

  @override
  String get seatMoveDown => 'Descer';

  @override
  String get setupPlay => 'Jogar!';

  @override
  String get setupNeedPlayer => 'Crie um jogador primeiro.';

  @override
  String get robotName0 => 'Robo';

  @override
  String get robotName1 => 'Chip';

  @override
  String get robotName2 => 'Bolt';

  @override
  String get robotName3 => 'Buzz';

  @override
  String get hudExit => 'Sair';

  @override
  String get hudPause => 'Pausar';

  @override
  String get hudMusic => 'Música';

  @override
  String get hudSfx => 'Efeitos sonoros';

  @override
  String get exitTitle => 'Quer mesmo sair?';

  @override
  String get exitSaved => 'O jogo em andamento será salvo.';

  @override
  String get exitNotSaved => 'O jogo em andamento não será salvo.';

  @override
  String get exitConfirm => 'Sair';

  @override
  String get pauseResume => 'Continuar';

  @override
  String get pauseRestart => 'Recomeçar';

  @override
  String get pauseRules => 'Regras';

  @override
  String get close => 'Fechar';

  @override
  String turnOf(String name) {
    return 'Vez de $name';
  }

  @override
  String robotThinking(String name) {
    return '🤖 $name está pensando…';
  }

  @override
  String get resumeFailed => 'Não dá para continuar o jogo salvo.';

  @override
  String resultWins(String name) {
    return '$name venceu!';
  }

  @override
  String get resultDraw => 'Empate!';

  @override
  String get resultPlayAgain => 'Jogar de novo';

  @override
  String get resultChangeSettings => 'Mudar ajustes';

  @override
  String get resultHome => 'Início';

  @override
  String get resultRobotTag => 'robô';

  @override
  String resultSubtitle(String game, String difficulty) {
    return '$game · $difficulty';
  }

  @override
  String get seatReplacedByRobot =>
      'Os jogadores que faltaram foram trocados por robôs.';

  @override
  String get settingsSound => 'Som';

  @override
  String get settingsMusic => 'Música';

  @override
  String get settingsMusicVolume => 'Volume da música';

  @override
  String get settingsSfx => 'Efeitos sonoros';

  @override
  String get settingsSfxVolume => 'Volume dos efeitos';

  @override
  String get settingsVibration => 'Vibração';

  @override
  String get settingsCredits => 'Créditos e licenças';

  @override
  String get creditsSounds => 'Música e sons';

  @override
  String get creditsFonts => 'Fontes';

  @override
  String get creditsLibraries => 'Licenças de bibliotecas';

  @override
  String creditsLicense(String license) {
    return 'Licença: $license';
  }

  @override
  String get badgeFirstWinTitle => 'Primeira vitória';

  @override
  String get badgeFirstWinDescription => 'Vença seu primeiro jogo.';

  @override
  String get badgeStreak5Title => 'Cinco seguidas';

  @override
  String get badgeStreak5Description => 'Vença 5 jogos seguidos.';

  @override
  String get badgeGames10Title => 'Dez jogos';

  @override
  String get badgeGames10Description => 'Jogue 10 jogos.';

  @override
  String get badgeHardWinTitle => 'Domador de robôs';

  @override
  String get badgeHardWinDescription => 'Vença os robôs no Difícil.';

  @override
  String get badgeAllGamesTitle => 'Explorador';

  @override
  String get badgeAllGamesDescription => 'Jogue todos os jogos.';

  @override
  String get resultNewBadges => 'Novas medalhas';

  @override
  String get leaderboardWeek => 'Semana';

  @override
  String get leaderboardMonth => 'Mês';

  @override
  String get leaderboardAllTime => 'Sempre';

  @override
  String get leaderboardAllGames => 'Todos os jogos';

  @override
  String get leaderboardAnyDifficulty => 'Qualquer dificuldade';

  @override
  String get leaderboardEmpty => 'Ainda não tem ninguém aqui. Termine um jogo!';

  @override
  String leaderboardWins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vitórias',
      one: '$count vitória',
    );
    return '$_temp0';
  }

  @override
  String leaderboardDetail(int played, int rate) {
    String _temp0 = intl.Intl.pluralLogic(
      played,
      locale: localeName,
      other: '$played jogos',
      one: '$played jogo',
    );
    return '$_temp0 · $rate%';
  }

  @override
  String playerStats(String name) {
    return 'Estatísticas: $name';
  }

  @override
  String get statsPlayed => 'Jogos';

  @override
  String get statsWins => 'Vitórias';

  @override
  String get statsWinRate => 'Aproveitamento';

  @override
  String get statsBestStreak => 'Melhor sequência';

  @override
  String get statsCurrentStreak => 'Sequência atual';

  @override
  String get statsByGame => 'Por jogo';

  @override
  String statsBestScore(int score) {
    return 'Melhor pontuação: $score';
  }

  @override
  String statsFastestWin(String time) {
    return 'Vitória mais rápida: $time';
  }

  @override
  String get statsBadges => 'Medalhas';

  @override
  String statsBadgeEarned(String date) {
    return 'Ganha em $date';
  }

  @override
  String get statsNoGames => 'Nenhum jogo terminado ainda.';

  @override
  String homeBestStars(int stars) {
    return 'Melhor nota: $stars de 3 estrelas';
  }

  @override
  String get resultPoints => 'Pontos';

  @override
  String get pointsWin => 'Vitória';

  @override
  String get pointsDraw => 'Empate';

  @override
  String get pointsSecond => '2º lugar';

  @override
  String get pointsParticipation => 'Participação';

  @override
  String pointsStars(int count) {
    return 'Nota $count ★';
  }

  @override
  String pointsStreak(int count) {
    return '$count vitórias seguidas';
  }

  @override
  String get pointsFirstToday => 'Primeiro jogo do dia';

  @override
  String get pointsRecord => 'Novo recorde pessoal';

  @override
  String pointsBadge(String name) {
    return 'Medalha: $name';
  }

  @override
  String get pointsCapped => 'Muitas vitórias no Fácil hoje';

  @override
  String get pointsGift => 'Presente de um responsável';

  @override
  String get pointsPurchase => 'Compra';

  @override
  String pointsTotal(int points) {
    return 'Total +$points ●';
  }

  @override
  String levelUp(int level) {
    return 'Novo nível $level!';
  }

  @override
  String homePointsBalance(int points) {
    return 'Pontos: $points';
  }

  @override
  String levelShort(int level) {
    return 'Nv $level';
  }

  @override
  String levelLabel(int level) {
    return 'Nível $level';
  }

  @override
  String levelNext(int current, int needed) {
    return '$current / $needed ● para o próximo nível';
  }

  @override
  String get levelMax => 'Nível máximo!';

  @override
  String get statsBalance => 'Saldo';

  @override
  String get statsTotalEarned => 'Total ganho';

  @override
  String get statsPointsHistory => 'Histórico de pontos';

  @override
  String get settingsParents => 'Cantinho dos pais';

  @override
  String get parentsGateTitle => 'Só para adultos';

  @override
  String parentsGateQuestion(int a, int b) {
    return 'Quanto é $a × $b?';
  }

  @override
  String get parentsGateWrong => 'Não está certo.';

  @override
  String get parentsGateOpen => 'Abrir';

  @override
  String get parentsGiftTitle => 'Dar pontos';

  @override
  String parentsGiftConfirm(int points, String name) {
    return 'Dar $points ● para $name?';
  }

  @override
  String get parentsGiftAction => 'Dar';

  @override
  String parentsGiftDone(int points, String name) {
    return 'Dado: $points ● – $name';
  }

  @override
  String updateAvailable(String version) {
    return 'Chegou a nova versão $version';
  }

  @override
  String get updateNow => 'Atualizar';

  @override
  String get updateLater => 'Depois';

  @override
  String updateDownloading(int percent) {
    return 'Baixando… $percent%';
  }

  @override
  String get updateMandatory =>
      'Esta versão é muito antiga – atualize, por favor.';

  @override
  String get updateFailed => 'O download falhou. Tente de novo mais tarde.';

  @override
  String get updatePermissionTitle => 'Mais uma permissão';

  @override
  String get updatePermissionText =>
      'O Android vai perguntar se o Deskovky pode instalar apps. É só para a nova versão do Deskovky. Peça a um adulto para ligar a chave e depois volte aqui.';

  @override
  String get updatePermissionOpen => 'Abrir ajustes';

  @override
  String get settingsApp => 'App';

  @override
  String settingsVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get settingsCheckNow => 'Procurar atualizações agora';

  @override
  String get settingsAutoUpdate => 'Procurar automaticamente';

  @override
  String get updateUpToDate => 'Você tem a versão mais nova.';

  @override
  String get updateCheckFailed =>
      'A verificação falhou – o aparelho está conectado?';

  @override
  String get itemCap => 'Boné';

  @override
  String get itemEarsHeadband => 'Tiara de orelhinhas';

  @override
  String get itemFlowerWreath => 'Coroa de flores';

  @override
  String get itemTopHat => 'Cartola';

  @override
  String get itemVikingHelmet => 'Capacete viking';

  @override
  String get itemPirateBandana => 'Bandana de pirata';

  @override
  String get itemWizardHat => 'Chapéu de mago';

  @override
  String get itemCrown => 'Coroa';

  @override
  String get itemHalo => 'Auréola';

  @override
  String get itemGlasses => 'Óculos';

  @override
  String get itemMustache => 'Bigode';

  @override
  String get itemFacePaintStar => 'Pintura de estrela';

  @override
  String get itemSunglasses => 'Óculos de sol';

  @override
  String get itemHeroMask => 'Máscara de herói';

  @override
  String get itemMonocle => 'Monóculo';

  @override
  String get itemCarnivalMask => 'Máscara de carnaval';

  @override
  String get itemLollipop => 'Pirulito';

  @override
  String get itemBalloon => 'Balão';

  @override
  String get itemIceCream => 'Sorvete';

  @override
  String get itemPhone => 'Celular';

  @override
  String get itemMicrophone => 'Microfone';

  @override
  String get itemMagicWand => 'Varinha mágica';

  @override
  String get itemTrophy => 'Troféu';

  @override
  String get itemKitten => 'Gatinho';

  @override
  String get itemChick => 'Pintinho';

  @override
  String get itemPuppy => 'Cachorrinho';

  @override
  String get itemParrot => 'Papagaio';

  @override
  String get itemDragon => 'Dragãozinho';

  @override
  String get itemWoodFrame => 'Moldura de madeira';

  @override
  String get itemGoldFrame => 'Moldura dourada';

  @override
  String get itemRainbowFrame => 'Moldura arco-íris';

  @override
  String get itemFlameFrame => 'Moldura de fogo';

  @override
  String get itemStarFrame => 'Moldura de estrelas';

  @override
  String get itemSparkles => 'Brilhos';

  @override
  String get itemBubbles => 'Bolhas';

  @override
  String get itemSnow => 'Neve caindo';

  @override
  String get pointsReset => 'Um responsável zerou os pontos';

  @override
  String get badgeWins50Title => 'Cinquenta';

  @override
  String get badgeWins50Description =>
      'Vença 50 jogos. Prêmio: um troféu para segurar.';

  @override
  String get badgeAllHardTitle => 'Mestre de todos os jogos';

  @override
  String get badgeAllHardDescription =>
      'Vença os robôs no Difícil em todos os jogos. Prêmio: uma moldura de estrelas.';

  @override
  String get badgeCollectorTitle => 'Colecionador';

  @override
  String get badgeCollectorDescription => 'Compre 10 itens para o avatar.';

  @override
  String get shopTitle => 'Loja';

  @override
  String shopTryOn(String name) {
    return 'Experimentando: $name';
  }

  @override
  String get shopAll => 'Tudo';

  @override
  String get slotHead => 'Cabeça';

  @override
  String get slotFace => 'Rosto';

  @override
  String get slotHand => 'Mão';

  @override
  String get slotPet => 'Bichinho';

  @override
  String get slotFrame => 'Moldura';

  @override
  String get slotEffect => 'Efeito';

  @override
  String shopBuy(int price) {
    return 'Comprar por $price ●';
  }

  @override
  String shopBuyConfirm(String name, int price) {
    return 'Comprar $name por $price ●?';
  }

  @override
  String get shopBuyAction => 'Comprar';

  @override
  String shopMissing(int points) {
    return 'Faltam $points ●';
  }

  @override
  String shopLevelLock(int level) {
    return '🔒 Nível $level';
  }

  @override
  String shopBadgeLock(String name) {
    return '🔒 Medalha: $name';
  }

  @override
  String get shopOwned => 'Já é seu';

  @override
  String get shopEquipped => 'Usando';

  @override
  String get shopEquipNow => 'Usar agora?';

  @override
  String get shopEquip => 'Usar';

  @override
  String get shopUnequip => 'Tirar';

  @override
  String get shopNotNow => 'Agora não';

  @override
  String shopNextLevel(int level, int next, int points) {
    return 'Nível $level → $next · faltam $points pontos';
  }

  @override
  String shopPlayerLevel(String name, int level) {
    return '$name · Nível $level';
  }

  @override
  String get wardrobeTitle => 'Guarda-roupa';

  @override
  String get wardrobeEmpty => 'Ainda não tem nada aqui. Compre itens na loja.';

  @override
  String get wardrobeToShop => 'Ir à loja';

  @override
  String wardrobeColour(String name) {
    return 'Cor: $name';
  }

  @override
  String get colourGold => 'dourado';

  @override
  String get colourSilver => 'prateado';

  @override
  String get colourRed => 'vermelho';

  @override
  String get colourBlue => 'azul';

  @override
  String get colourGreen => 'verde';

  @override
  String get colourYellow => 'amarelo';

  @override
  String get colourBrown => 'marrom';

  @override
  String get parentsResetTitle => 'Zerar pontos e itens';

  @override
  String get parentsReset => 'Zerar';

  @override
  String parentsResetConfirm(String name, int points) {
    return '$name vai perder $points ● e todos os itens comprados. O nível e as medalhas ficam.';
  }

  @override
  String parentsResetDone(String name) {
    return '$name: pontos e itens zerados.';
  }

  @override
  String resultCanBuy(String name, String item) {
    return '$name, agora você pode comprar: $item!';
  }

  @override
  String pointsPurchaseItem(String item) {
    return 'Compra: $item';
  }

  @override
  String shopNewBadge(String badge) {
    return 'Nova medalha: $badge!';
  }

  @override
  String shopNewBadgeReward(String description, int points) {
    return '$description Prêmio +$points ●.';
  }

  @override
  String get shopHooray => 'Oba!';

  @override
  String get shopNotEnough =>
      'Você não tem pontos suficientes para isso agora.';

  @override
  String get shopFailed => 'Não deu certo. Tente de novo.';

  @override
  String get updatePreparing => 'Preparando a atualização…';

  @override
  String get setupDifficultySolo => 'Dificuldade';

  @override
  String get whereLabel => 'Onde jogar';

  @override
  String get whereHere => 'Neste aparelho';

  @override
  String get whereWifi => 'Cada um no seu (Wi-Fi)';

  @override
  String get trialTag => 'Teste';

  @override
  String get noWifi =>
      'Você não está no Wi-Fi. Conecte-se ao mesmo Wi-Fi que os outros.';

  @override
  String get setupOpenRoom => 'Abrir a sala';

  @override
  String get roomTitle => 'Sala';

  @override
  String get roomCode => 'Código da sala';

  @override
  String get roomJoinHint =>
      'Os outros leem o QR code com a câmera ou tocam em Entrar num jogo.';

  @override
  String get slotOpen => 'Lugar livre';

  @override
  String get slotHere => '🏠 Aqui';

  @override
  String get slotOwnDevice => '📱 Aparelho próprio';

  @override
  String get slotReady => 'Pronto';

  @override
  String get slotWaiting => 'Esperando';

  @override
  String get slotDisconnected => 'Desconectado';

  @override
  String get slotMakeRobot => 'Colocar um robô';

  @override
  String get slotAddLocal => 'Colocar jogador deste aparelho';

  @override
  String get slotLeaveOpen => 'Deixar livre';

  @override
  String get roomRemove => 'Remover jogador';

  @override
  String get roomStart => 'Começar o jogo';

  @override
  String get roomWaitReady => 'Esperando todos ficarem prontos.';

  @override
  String get roomNoServer => 'Não foi possível abrir a sala.';

  @override
  String get homeJoin => 'Entrar num jogo';

  @override
  String get joinWho => 'Quem joga neste aparelho';

  @override
  String get joinRooms => 'Salas na rede';

  @override
  String get joinSearching => 'Procurando salas…';

  @override
  String get joinByCode => 'Código da sala (4 dígitos)';

  @override
  String get joinCodeNotFound => 'Nenhuma sala com esse código na rede.';

  @override
  String get joinAdvanced => 'Avançado';

  @override
  String get joinAddress => 'Endereço (IP:porta)';

  @override
  String get joinConnect => 'Conectar';

  @override
  String get joinFailed => 'Não foi possível conectar.';

  @override
  String get joinPickSomeone => 'Escolha pelo menos um jogador.';

  @override
  String get joinScanQr => 'Ler QR code';

  @override
  String get joinQrRoom => 'Sala do QR code';

  @override
  String get joinOtherRoom => 'Escolher outra sala';

  @override
  String get qrNotRoom =>
      'Este não é um QR code do Deskovky. Leia o código da tela Sala.';

  @override
  String get qrCameraDenied =>
      'Sem a câmera não consigo ler o QR code. Permita nos ajustes do celular ou digite o código da sala.';

  @override
  String get qrScanTitle => 'Aponte para o QR code';

  @override
  String get byeVersion =>
      'O anfitrião tem outra versão do app. Atualizem todos para a mesma.';

  @override
  String get byeCode => 'Código da sala errado.';

  @override
  String get byeFull => 'A sala está cheia.';

  @override
  String get byeStarted => 'O jogo já começou.';

  @override
  String get byeKicked => 'O anfitrião tirou você da sala.';

  @override
  String get byeLost => 'A conexão com o anfitrião caiu.';

  @override
  String get lobbyReady => 'Estou pronto';

  @override
  String get lobbyNotReady => 'Ainda não';

  @override
  String get lobbySettings => 'Ajustes do jogo (o anfitrião escolhe)';

  @override
  String get lobbyWaitStart => 'Esperando o anfitrião começar.';

  @override
  String get leaveRoom => 'Sair da sala';

  @override
  String joinFree(int count) {
    return 'Lugares livres: $count';
  }

  @override
  String get netDecideTitle => 'Um jogador não voltou';

  @override
  String get netWaitMore => 'Esperar mais';

  @override
  String get netReplaceRobot => 'Trocar por um robô';

  @override
  String get netEndGame => 'Encerrar o jogo';

  @override
  String get netLeave => 'Sair do jogo';

  @override
  String get netRematch => 'Revanche';

  @override
  String get netWaitHost => 'Esperando o anfitrião…';

  @override
  String get byeEnded => 'O anfitrião encerrou o jogo.';

  @override
  String netYourTurn(String name) {
    return '$name, é a sua vez!';
  }

  @override
  String netTurnRemote(String name) {
    return 'Vez de $name (no aparelho dele)';
  }

  @override
  String netWaiting(String name, String time) {
    return '$name: desconectado – esperando ($time)';
  }

  @override
  String get netReconnect => 'Reconectar';

  @override
  String resultNotThisTime(String name) {
    return '$name, não foi dessa vez';
  }

  @override
  String get joinLinkBusy =>
      'Você já está jogando. Saia do jogo ou da sala primeiro.';

  @override
  String get familyTitle => 'Família';

  @override
  String get familyIntro =>
      'Conecte os aparelhos da família: perfis, pontos, prêmios e histórico de jogos ficam iguais em todos. Basta o Wi-Fi de casa, não precisa de internet.';

  @override
  String get familyCreate => 'Criar uma família';

  @override
  String get familyJoin => 'Entrar numa família';

  @override
  String get familyJoinOther => 'Entrar em outra família';

  @override
  String get familyJoinOtherWarning =>
      'Este aparelho já está numa família. Ao entrar em outra, ele sai da família atual; os perfis deste aparelho serão oferecidos para juntar.';

  @override
  String get familyJoinOtherConfirm => 'Entrar mesmo assim';

  @override
  String get familyAddDevice => 'Adicionar aparelho';

  @override
  String get familyQrHint =>
      'No aparelho novo, abra Ajustes → Cantinho dos pais → Família → Entrar numa família e leia este código. Os dois aparelhos precisam estar no mesmo Wi-Fi.';

  @override
  String get familyDevices => 'Aparelhos da família';

  @override
  String get familyThisDevice => 'este aparelho';

  @override
  String get familyNeverSynced => 'ainda não sincronizado';

  @override
  String get familyRemove => 'Remover da família';

  @override
  String get familyRemoveMessage =>
      'O aparelho vai parar de receber perfis e pontos. Os dados que já estão nele continuam lá.';

  @override
  String get familyRemoved => 'removido';

  @override
  String get familyJoined => 'Pronto – você está na família!';

  @override
  String get familyJoinFailed =>
      'Não deu para entrar na família. Os dois aparelhos estão no mesmo Wi-Fi, com Família aberta no outro?';

  @override
  String get familyNotACode => 'Este não é um código de família.';

  @override
  String get familyUpdateApps =>
      'Um aparelho tem outra versão do app. Atualize o app em todos os aparelhos.';

  @override
  String get familyCodeInJoin =>
      'Este é um código de família. Adicione o aparelho em Ajustes → Cantinho dos pais → Família.';

  @override
  String get familySynced => 'Sincronizado com a família';

  @override
  String get deviceTablet => 'Tablet';

  @override
  String get devicePhone => 'Celular';

  @override
  String familyLastSync(String time) {
    return 'última sincronização $time';
  }

  @override
  String familyRemoveTitle(String name) {
    return 'Remover $name da família?';
  }

  @override
  String get pairTitle => 'Juntar perfis';

  @override
  String get pairQuestion => 'É a mesma pessoa?';

  @override
  String get pairMerge => 'Sim, juntar';

  @override
  String get pairKeep => 'Não, são duas';

  @override
  String get pairLook => 'Ver depois de juntar';

  @override
  String get pairManual => 'Juntar manualmente';

  @override
  String get pairFirst => 'Perfil';

  @override
  String get pairSecond => 'é o mesmo que';

  @override
  String get pairNone => 'Não há mais pares.';

  @override
  String get refundTitle => 'Os pontos voltaram';

  @override
  String get refundOk => 'Entendi';

  @override
  String familyPairs(int count) {
    return 'Possíveis pares ($count)';
  }

  @override
  String refundNotice(String item) {
    return 'Seus pontos de $item voltaram – não havia pontos suficientes para os dois.';
  }

  @override
  String get inviteFamily => 'Convidar da família';

  @override
  String get inviteSent => 'Convite enviado.';

  @override
  String get inviteNoDevice => 'Nenhum aparelho da família encontrado na rede.';

  @override
  String get invitePlay => 'Jogar';

  @override
  String get inviteLater => 'Agora não';

  @override
  String inviteTitle(String host, String game) {
    return '$host convida você para $game – vamos jogar?';
  }

  @override
  String pointsRefundDuplicate(String item) {
    return 'Devolvido: $item – comprado duas vezes';
  }

  @override
  String pointsRefundNotEnough(String item) {
    return 'Devolvido: $item – pontos insuficientes';
  }

  @override
  String get setupElsewhere => 'Em outro aparelho';

  @override
  String get setupBusyTag => 'Em outro jogo';

  @override
  String get setupInvitePlay => 'Convidar e jogar';

  @override
  String get slotInvited => 'Convidado, esperando';

  @override
  String inviteFailed(String name) {
    return 'Não foi possível entregar o convite para $name.';
  }

  @override
  String get inviteNotHere => 'Fora do Wi-Fi';

  @override
  String get navDonations => 'Doar';

  @override
  String get donationsTitle => 'Apoie o Deskovky';

  @override
  String get donationsIntro =>
      'O Deskovky é feito em casa, para famílias com crianças. Ele é grátis e vai continuar grátis. Se ele traz alegria para vocês, dá para fazer uma contribuição voluntária para o desenvolvimento.';

  @override
  String get donationsFreeTitle => 'O jogo todo é grátis';

  @override
  String get donationsFreeText =>
      'Sem fases pagas, nada é liberado por dinheiro.';

  @override
  String get donationsNoAdsTitle => 'Sem anúncios';

  @override
  String get donationsNoAdsText =>
      'Nada distrai as crianças e nada as tenta a comprar.';

  @override
  String get donationsNoDataTitle => 'Sem coleta de dados';

  @override
  String get donationsNoDataText =>
      'Sem contas, sem login. Perfis e resultados ficam nos seus aparelhos.';

  @override
  String get donationsOfflineTitle => 'Seguro sem internet';

  @override
  String get donationsOfflineText =>
      'Funciona offline e não envia nada sobre você para lugar nenhum. Só usa a internet para baixar uma nova versão.';

  @override
  String get donationsFamilyTitle => 'A família toda joga';

  @override
  String get donationsFamilyText =>
      'Em volta de uma mesa ou cada um no seu, pelo Wi-Fi de casa. Os aparelhos da família só trocam dados entre si.';

  @override
  String get donationsKidsTitle => 'Também para os menores';

  @override
  String get donationsKidsText =>
      'Robôs em três níveis, regras com figuras, botões grandes e um cantinho dos pais.';

  @override
  String get donationsEveryoneTitle => 'Para todos';

  @override
  String get donationsEveryoneText =>
      'Funciona com leitor de tela, tem marcas para daltônicos e fala dez idiomas.';

  @override
  String get donationsGrowingTitle => 'Sempre chegam jogos novos';

  @override
  String get donationsGrowingText =>
      'Nove jogos e mais a caminho – alguns pedidos pelas crianças.';

  @override
  String get donationsWhy =>
      'A contribuição ajuda a pagar o tempo para criar novos jogos e as taxas do Google Play.';

  @override
  String get donationsSoon =>
      'Será possível doar quando o jogo estiver no Google Play. Obrigado!';

  @override
  String get familyRename => 'Renomear aparelho';

  @override
  String get familyOnline => 'Deskovky está aberto';

  @override
  String get familyOffline => 'Indisponível';

  @override
  String familyPlaysNow(String name) {
    return '$name está jogando agora';
  }

  @override
  String get settingsShareApp => 'Baixar em outro aparelho';

  @override
  String get shareAppTitle => 'Deskovky em outro aparelho';

  @override
  String get shareAppHint =>
      'Leia o código com a câmera do outro celular ou tablet. Vai abrir a página com a versão mais nova: baixe o arquivo deskovky-….apk e abra.';

  @override
  String get inviteToAllDevices =>
      'O convite vai para todos os aparelhos da rede';

  @override
  String get parentsReportBug => 'Relatar um erro';

  @override
  String get parentsReportBugHint =>
      'Abre um formulário curto (sem login) onde você descreve o erro. Não escreva nomes de crianças nem outros dados pessoais.';

  @override
  String get bugReportNoBrowser =>
      'Não foi possível abrir o navegador. Você pode relatar o erro em:';

  @override
  String get saveFailed => 'Não foi possível salvar o jogo.';
}
