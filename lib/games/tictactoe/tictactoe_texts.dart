import '../../core/game/game_texts.dart';

/// Texts of Piškvorky in Czech, English and Spanish (keys `tictactoe.*`).
const tictactoeTexts = GameTexts(
  cs: {
    'tictactoe.title': 'Piškvorky',
    'tictactoe.description': 'Kdo první složí řadu?',
    'tictactoe.rules':
        'Hráči střídavě kladou křížky a kolečka. Vyhrává, kdo první složí řadu – na desce 3×3 tři v řadě, na velké desce pět. Řada může být vodorovně, svisle i šikmo. Plná deska je remíza.',
    'tictactoe.option.board': 'Deska',
    'tictactoe.option.start': 'Začíná',
    'tictactoe.option.start.alternate': 'střídavě',
    'tictactoe.option.start.random': 'náhodně',
    'tictactoe.option.start.first': 'vždy hráč 1',
  },
  en: {
    'tictactoe.title': 'Tic-tac-toe',
    'tictactoe.description': 'Who makes a row first?',
    'tictactoe.rules':
        'Players take turns placing crosses and noughts. The first to make a row wins – three in a row on 3×3, five on the big boards. Rows count across, down and diagonally. A full board is a draw.',
    'tictactoe.option.board': 'Board',
    'tictactoe.option.start': 'Who starts',
    'tictactoe.option.start.alternate': 'take turns',
    'tictactoe.option.start.random': 'random',
    'tictactoe.option.start.first': 'always player 1',
  },
  es: {
    'tictactoe.title': 'Tres en raya',
    'tictactoe.description': '¿Quién hace primero una línea?',
    'tictactoe.rules':
        'Los jugadores ponen por turnos cruces y círculos. Gana quien primero hace una línea: tres en el tablero de 3×3, cinco en los grandes. Vale en horizontal, vertical y diagonal. Tablero lleno es empate.',
    'tictactoe.option.board': 'Tablero',
    'tictactoe.option.start': 'Empieza',
    'tictactoe.option.start.alternate': 'por turnos',
    'tictactoe.option.start.random': 'al azar',
    'tictactoe.option.start.first': 'siempre el jugador 1',
  },
);
