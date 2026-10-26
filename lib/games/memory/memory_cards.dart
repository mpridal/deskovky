/// Picture sets of Pexeso (spec 13.6): 24 Noto Emoji motifs each (Apache 2.0,
/// see `assets/games/memory/CREDITS.json`), bundled as 256 px PNG named by
/// their code points, so every phone shows the same pictures.
const memorySets = <String, List<String>>{
  'animals': [
    '1f436', '1f431', '1f42d', '1f430', '1f98a', '1f43b', '1f43c', '1f428', //
    '1f42f', '1f981', '1f42e', '1f437', '1f438', '1f435', '1f414', '1f427',
    '1f989', '1f986', '1f422', '1f420', '1f419', '1f418', '1f992', '1f98b',
  ],
  'food': [
    '1f34e', '1f350', '1f34c', '1f347', '1f353', '1f352', '1f349', '1f34a', //
    '1f34b', '1f34d', '1f351', '1f95d', '1f965', '1f96d', '1f955', '1f33d',
    '1f966', '1f345', '1f346', '1f952', '1f954', '1f951', '1f344', '1f9c5',
  ],
  'transport': [
    '1f697', '1f695', '1f68c', '1f693', '1f691', '1f692', '1f3ce', '1f69a', //
    '1f69c', '1f6b2', '1f3cd', '1f6f4', '1f682', '1f68b', '2708', '1f681',
    '1f680', '1f6a2', '26f5', '1f6f6', '1f6fb', '1f685', '1f6a4', '1f6a1',
  ],
  'space': [
    '1f680', '1f6f8', '1f6f0', '1f52d', '2600', '1f31e', '1f315', '1f319', //
    '2b50', '1f320', '2604', '1f30d', '1fa90', '1f30c', '1f9d1_200d_1f680', '1f47d',
    '1f47e', '1f916', '1f4e1', '1f4ab', '2728', '1f311', '1f31b', '1f31f',
  ],
};

const memoryDefaultSet = 'animals';

/// Motifs per set; 48 cards need all 24.
const memoryMotifs = 24;

String memoryCardAsset(String set, int motif) => 'assets/games/memory/cards/$set/${memorySets[set]![motif]}.png';
