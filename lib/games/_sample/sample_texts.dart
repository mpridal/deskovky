import '../../core/game/game_texts.dart';

/// Texts of the sample game "Hádej číslo" (spec 8: texts in the game folder).
const sampleTexts = GameTexts(
  cs: {
    'sample.title': 'Hádej číslo',
    'sample.description': 'Kdo dřív uhodne tajné číslo?',
    'sample.rules':
        'Hra skryje číslo. Hráči se střídají v tipování. Po každém tipu se dozvíte, jestli je tajné číslo větší, nebo menší. Kdo ho trefí, vyhrává!',
    'sample.option.range': 'Rozsah čísel',
    'sample.higher': 'Víc!',
    'sample.lower': 'Míň!',
    'sample.turnHint': '{name}, tipni číslo od {low} do {high}',
    'sample.badge.bullseye.title': 'Trefa!',
    'sample.badge.bullseye.description': 'Uhádni číslo hned prvním tipem.',
    'sample.step1': 'Ťukni na číslo.',
    'sample.step2': 'Šipka napoví: víc, nebo míň?',
    'sample.firstHint': 'Ťukni na číslo, které tipuješ.',
  },
  en: {
    'sample.title': 'Guess the number',
    'sample.description': 'Who guesses the secret number first?',
    'sample.rules':
        'The game hides a number. Players take turns guessing. After each guess you learn whether the secret number is higher or lower. Whoever hits it wins!',
    'sample.option.range': 'Number range',
    'sample.higher': 'Higher!',
    'sample.lower': 'Lower!',
    'sample.turnHint': '{name}, guess a number from {low} to {high}',
    'sample.badge.bullseye.title': 'Bullseye!',
    'sample.badge.bullseye.description': 'Guess the number with your first tip.',
    'sample.step1': 'Tap a number.',
    'sample.step2': 'The arrow tells you: higher or lower?',
    'sample.firstHint': 'Tap the number you guess.',
  },
  es: {
    'sample.title': 'Adivina el número',
    'sample.description': '¿Quién adivina primero el número secreto?',
    'sample.rules':
        'El juego esconde un número. Los jugadores adivinan por turnos. Después de cada intento sabréis si el número secreto es mayor o menor. ¡Gana quien lo acierte!',
    'sample.option.range': 'Rango de números',
    'sample.higher': '¡Más!',
    'sample.lower': '¡Menos!',
    'sample.turnHint': '{name}, adivina un número del {low} al {high}',
    'sample.badge.bullseye.title': '¡En el blanco!',
    'sample.badge.bullseye.description': 'Adivina el número a la primera.',
    'sample.step1': 'Toca un número.',
    'sample.step2': 'La flecha te dice: ¿más o menos?',
    'sample.firstHint': 'Toca el número que adivinas.',
  },
);
