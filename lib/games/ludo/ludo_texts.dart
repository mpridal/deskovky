import '../../core/game/game_texts.dart';

/// Texts of Člověče, nezlob se in Czech, English and Spanish (keys `ludo.*`).
const ludoTexts = GameTexts(
  cs: {
    'ludo.title': 'Člověče, nezlob se',
    'ludo.description': 'Dostaň figurky domů dřív než ostatní.',
    'ludo.rules':
        'Hoď kostkou a posuň figurku. Na desku nasadíš figurku jen šestkou, po šestce házíš znovu. Když skočíš na soupeřovu figurku, vyhodíš ji na start. Do domečku se musíš trefit přesně. Vyhrává, kdo má první všechny figurky doma.',
    'ludo.option.length': 'Délka',
    'ludo.option.length.full': 'plná (4 figurky)',
    'ludo.option.length.short': 'krátká (2 figurky)',
    'ludo.option.mustCapture': 'Povinné vyhazování',
    'ludo.option.threeTries': '3 pokusy na nasazení',
    'ludo.option.playOut': 'Dohrát pořadí',
  },
  en: {
    'ludo.title': 'Ludo',
    'ludo.description': 'Get your pieces home before the others.',
    'ludo.rules':
        'Roll the die and move a piece. A piece enters the board only on a six, and a six rolls again. Land on another player\'s piece to send it back to start. You must reach home with an exact roll. The first with all pieces home wins.',
    'ludo.option.length': 'Length',
    'ludo.option.length.full': 'full (4 pieces)',
    'ludo.option.length.short': 'short (2 pieces)',
    'ludo.option.mustCapture': 'Must capture',
    'ludo.option.threeTries': '3 tries to enter',
    'ludo.option.playOut': 'Play out all places',
  },
  es: {
    'ludo.title': 'Parchís',
    'ludo.description': 'Lleva tus fichas a casa antes que nadie.',
    'ludo.rules':
        'Tira el dado y mueve una ficha. Una ficha solo sale con un seis, y con un seis vuelves a tirar. Si caes sobre una ficha rival, vuelve a la salida. Hay que llegar a casa con la tirada exacta. Gana quien primero tenga todas las fichas en casa.',
    'ludo.option.length': 'Duración',
    'ludo.option.length.full': 'larga (4 fichas)',
    'ludo.option.length.short': 'corta (2 fichas)',
    'ludo.option.mustCapture': 'Comer obligatorio',
    'ludo.option.threeTries': '3 intentos para salir',
    'ludo.option.playOut': 'Jugar todos los puestos',
  },
);
