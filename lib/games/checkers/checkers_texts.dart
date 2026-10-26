import '../../core/game/game_texts.dart';

/// Texts of Dáma in Czech, English and Spanish (keys `checkers.*`).
const checkersTexts = GameTexts(
  cs: {
    'checkers.title': 'Dáma',
    'checkers.description': 'Přeskakuj a sbírej soupeřovy kameny.',
    'checkers.rules':
        'Kameny táhnou šikmo vpřed po tmavých polích. Soupeřův kámen sebereš přeskokem – braní je povinné. Kámen na poslední řadě se mění v dámu, která táhne libovolně daleko. Vyhrává, kdo sebere nebo zablokuje všechny soupeřovy kameny.',
    'checkers.option.rules': 'Pravidla',
    'checkers.option.rules.czech': 'česká 8×8',
    'checkers.option.rules.international': 'mezinárodní 10×10',
  },
  en: {
    'checkers.title': 'Checkers',
    'checkers.description': 'Jump over and capture the other pieces.',
    'checkers.rules':
        'Pieces move diagonally forward on the dark squares. Capture by jumping over a piece – capturing is compulsory. A piece reaching the last row becomes a king that moves any distance. Capture or block all the other pieces to win.',
    'checkers.option.rules': 'Rules',
    'checkers.option.rules.czech': 'Czech 8×8',
    'checkers.option.rules.international': 'international 10×10',
  },
  es: {
    'checkers.title': 'Damas',
    'checkers.description': 'Salta y captura las fichas rivales.',
    'checkers.rules':
        'Las fichas avanzan en diagonal por las casillas oscuras. Se captura saltando por encima, y capturar es obligatorio. La ficha que llega a la última fila se convierte en dama, que se mueve cualquier distancia. Gana quien capture o bloquee todas las fichas rivales.',
    'checkers.option.rules': 'Reglas',
    'checkers.option.rules.czech': 'checa 8×8',
    'checkers.option.rules.international': 'internacional 10×10',
  },
);
