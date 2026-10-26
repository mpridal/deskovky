import '../../core/game/game_texts.dart';

/// Texts of Miny in Czech, English and Spanish (keys `minesweeper.*`).
const minesweeperTexts = GameTexts(
  cs: {
    'minesweeper.title': 'Miny',
    'minesweeper.description': 'Odkryj pole a vyhni se minám.',
    'minesweeper.rules':
        'Ťukni na pole a odkryj ho. Číslo říká, kolik min je kolem. Kde tušíš minu, dej vlajku. Vyhraješ, když odkryješ všechna pole bez min. Ve Střídačce se hráči střídají a kdo odkryje minu, vypadává.',
    'minesweeper.option.questionMarks': 'Otazníky',
    'minesweeper.option.controls': 'Ovládání',
    'minesweeper.option.controls.longPress': 'dlouhý stisk = vlajka',
    'minesweeper.option.controls.switch': 'přepínač ⛏/🚩',
  },
  en: {
    'minesweeper.title': 'Minesweeper',
    'minesweeper.description': 'Clear the field, avoid the mines.',
    'minesweeper.rules':
        'Tap a square to uncover it. A number tells how many mines are around. Flag the squares where you think a mine is. You win when every square without a mine is uncovered. In Take turns, players alternate and whoever finds a mine is out.',
    'minesweeper.option.questionMarks': 'Question marks',
    'minesweeper.option.controls': 'Controls',
    'minesweeper.option.controls.longPress': 'long press = flag',
    'minesweeper.option.controls.switch': '⛏/🚩 switch',
  },
  es: {
    'minesweeper.title': 'Buscaminas',
    'minesweeper.description': 'Despeja el campo sin pisar minas.',
    'minesweeper.rules':
        'Toca una casilla para descubrirla. El número dice cuántas minas hay alrededor. Pon una bandera donde creas que hay una mina. Ganas al descubrir todas las casillas sin mina. En Por turnos, quien encuentra una mina queda fuera.',
    'minesweeper.option.questionMarks': 'Interrogaciones',
    'minesweeper.option.controls': 'Controles',
    'minesweeper.option.controls.longPress': 'pulsación larga = bandera',
    'minesweeper.option.controls.switch': 'interruptor ⛏/🚩',
  },
);
