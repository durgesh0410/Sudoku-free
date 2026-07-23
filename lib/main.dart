import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const WorldSudokuApp());
}

class WorldSudokuApp extends StatelessWidget {
  const WorldSudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Sudoku League',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F1E),
        primaryColor: Colors.amber,
      ),
      home: const SudokuGameScreen(),
    );
  }
}

class SudokuGameScreen extends StatefulWidget {
  const SudokuGameScreen({super.key});

  @override
  State<SudokuGameScreen> createState() => _SudokuGameScreenState();
}

class _SudokuGameScreenState extends State<SudokuGameScreen> {
  // --- Multi-Language System ---
  String currentLang = 'en';

  final Map<String, Map<String, String>> localizedText = {
    'en': {
      'title': 'World Sudoku',
      'you': 'You',
      'high': 'High',
      'wrong': '❌ Wrong Number! -5 Points',
      'victory': '🌍 VICTORY! 🏆',
      'completed': '🎉 GAME COMPLETED!',
      'win_msg': 'You defeated {rival} in World League!',
      'loss_msg': 'Great game! Better luck beating {rival} next time.',
      'your_score': 'Your Score: ',
      'rival_score': ' Score: ',
      'share_btn': 'Share Score 🚀',
      'next_btn': 'Play Next Match 🔄',
      'exit_title': 'Exit Game?',
      'exit_msg':
          'Are you sure you want to exit? Your game progress will be lost.',
      'keep_playing': 'Keep Playing 🎮',
      'exit_btn': 'Exit 🚪',
      'share_text':
          '🌐 World Sudoku League: I scored {score} points and challenged {rival}! Can you beat my high score? 🚀',
      'restart_title': 'Start New Game?',
      'restart_msg': 'Current progress will be saved in history. Are you sure?',
      'undo_msg': 'Restored previous Sudoku board! ↩️',
      'no_prev_msg': 'No previous Sudoku to restore!',
    },
    'hi': {
      'title': 'विश्व सुडोकू',
      'you': 'आप',
      'high': 'सर्वश्रेष्ठ',
      'wrong': '❌ गलत नंबर! -5 अंक',
      'victory': '🌍 शानदार जीत! 🏆',
      'completed': '🎉 खेल पूरा हुआ!',
      'win_msg': 'आपने वर्ल्ड लीग में {rival} को हरा दिया!',
      'loss_msg': 'अच्छा खेल! अगली बार {rival} को हराने की कोशिश करें।',
      'your_score': 'आपका स्कोर: ',
      'rival_score': ' का स्कोर: ',
      'share_btn': 'स्कोर शेयर करें 🚀',
      'next_btn': 'अगला मैच खेलें 🔄',
      'exit_title': 'गेम बंद करें?',
      'exit_msg': 'क्या आप बाहर निकलना चाहते हैं? आपकी प्रोग्रेस मिट जाएगी।',
      'keep_playing': 'खेलते रहें 🎮',
      'exit_btn': 'बाहर निकलें 🚪',
      'share_text':
          '🌐 विश्व सुडोकू लीग: मैंने {score} अंक बनाए और {rival} को चुनौती दी! क्या आप मुझे हरा सकते हैं? 🚀',
      'restart_title': 'नया गेम शुरू करें?',
      'restart_msg':
          'मौजूदा गेम हिस्ट्री में सेव रहेगा। क्या आप पक्का नया गेम चाहते हैं?',
      'undo_msg': 'पुराना सुडोकू बोर्ड वापस लाया गया! ↩️',
      'no_prev_msg': 'वापस लाने के लिए कोई पुराना सुडोकू नहीं है!',
    },
    'es': {
      'title': 'Sudoku Mundial',
      'you': 'Tú',
      'high': 'R record',
      'wrong': '❌ ¡Número incorrecto! -5 Pts',
      'victory': '🌍 ¡VICTORIA! 🏆',
      'completed': '🎉 ¡JUEGO COMPLETADO!',
      'win_msg': '¡Derrotaste a {rival} en la Liga Mundial!',
      'loss_msg': '¡Buen juego! Más suerte venciendo a {rival} la próxima.',
      'your_score': 'Tu Puntuación: ',
      'rival_score': ' Puntuación: ',
      'share_btn': 'Compartir 🚀',
      'next_btn': 'Siguiente Partida 🔄',
      'exit_title': '¿Salir del juego?',
      'exit_msg': '¿Seguro que quieres salir? Se perderá tu progreso.',
      'keep_playing': 'Seguir jugando 🎮',
      'exit_btn': 'Salir 🚪',
      'share_text':
          '🌐 Liga Mundial de Sudoku: ¡Logré {score} puntos y desafié a {rival}! ¿Puedes superarme? 🚀',
      'restart_title': '¿Nuevo juego?',
      'restart_msg':
          'El progreso actual se guardará en el historial. ¿Estás seguro?',
      'undo_msg': '¡Tablero de Sudoku anterior restaurado! ↩️',
      'no_prev_msg': '¡No hay Sudoku anterior para restaurar!',
    },
    'de': {
      'title': 'Welt Sudoku',
      'you': 'Du',
      'high': 'Rekord',
      'wrong': '❌ Falsche Zahl! -5 Punkte',
      'victory': '🌍 SIEG! 🏆',
      'completed': '🎉 SPIEL BEENDET!',
      'win_msg': 'Du hast {rival} in der Weltliga besiegt!',
      'loss_msg': 'Gutes Spiel! Viel Glück beim nächsten Mal gegen {rival}.',
      'your_score': 'Deine Punkte: ',
      'rival_score': ' Punkte: ',
      'share_btn': 'Teilen 🚀',
      'next_btn': 'Nächstes Spiel 🔄',
      'exit_title': 'Spiel verlassen?',
      'exit_msg':
          'Möchtest du wirklich beenden? Dein Fortschritt geht verloren.',
      'keep_playing': 'Weiterspielen 🎮',
      'exit_btn': 'Beenden 🚪',
      'share_text':
          '🌐 Welt-Sudoku-Liga: Ich habe {score} Punkte erzielt und {rival} herausgefordert! 🚀',
      'restart_title': 'Neues Spiel starten?',
      'restart_msg':
          'Der aktuelle Fortschritt wird gespeichert. Bist du sicher?',
      'undo_msg': 'Vorheriges Sudoku-Feld wiederhergestellt! ↩️',
      'no_prev_msg': 'Kein vorheriges Sudoku vorhanden!',
    },
    'ja': {
      'title': '世界数独',
      'you': 'あなた',
      'high': '最高点',
      'wrong': '❌ 間違い！ -5点',
      'victory': '🌍 勝利！ 🏆',
      'completed': '🎉 ゲームクリア！',
      'win_msg': 'ワールドリーグで {rival} に勝利しました！',
      'loss_msg': 'ナイスゲーム！次回は {rival} に挑戦しよう。',
      'your_score': 'あなたのスコア: ',
      'rival_score': ' のスコア: ',
      'share_btn': 'スコアを共有 🚀',
      'next_btn': '次の試合へ 🔄',
      'exit_title': '終了しますか？',
      'exit_msg': '本当に終了しますか？進行状況は失われます。',
      'keep_playing': '続ける 🎮',
      'exit_btn': '終了 🚪',
      'share_text': '🌐 世界数独リーグ: {score}点を獲得し{rival}に挑戦しました！🚀',
      'restart_title': '新しいゲームを開始しますか？',
      'restart_msg': '現在の進行状況は履歴に保存されます。よろしいですか？',
      'undo_msg': '前の数独ボードを復元しました！ ↩️',
      'no_prev_msg': '復元する前の数独がありません！',
    },
    'fr': {
      'title': 'Sudoku Mondial',
      'you': 'Vous',
      'high': 'Record',
      'wrong': '❌ Mauvais chiffre! -5 Pts',
      'victory': '🌍 VICTOIRE! 🏆',
      'completed': '🎉 JEU TERMINÉ!',
      'win_msg': 'Vous avez battu {rival} en Ligue Mondiale!',
      'loss_msg': 'Bien joué! Plus de chance contre {rival} la prochaine fois.',
      'your_score': 'Votre score: ',
      'rival_score': ' Score: ',
      'share_btn': 'Partager 🚀',
      'next_btn': 'Partie suivante 🔄',
      'exit_title': 'Quitter le jeu?',
      'exit_msg':
          'Voulez-vous vraiment quitter? Votre progression sera perdue.',
      'keep_playing': 'Continuer 🎮',
      'exit_btn': 'Quitter 🚪',
      'share_text':
          '🌐 Ligue Mondiale de Sudoku: J\'ai marqué {score} points et défié {rival}! 🚀',
      'restart_title': 'Commencer une nouvelle partie?',
      'restart_msg': 'La progression actuelle sera sauvegardée. Êtes-vous sûr?',
      'undo_msg': 'Grille de Sudoku précédente restaurée! ↩️',
      'no_prev_msg': 'Pas de Sudoku précédent à restaurer!',
    },
  };

  String t(String key) {
    return localizedText[currentLang]?[key] ?? localizedText['en']![key]!;
  }

  // --- Current Game Grids ---
  List<List<int>> solutionGrid = List.generate(9, (_) => List.filled(9, 0));
  List<List<int>> userGrid = List.generate(9, (_) => List.filled(9, 0));
  List<List<bool>> isOriginal = List.generate(9, (_) => List.filled(9, false));

  // --- History / Restore System (Previous Sudoku Backup) ---
  List<List<int>>? prevSolutionGrid;
  List<List<int>>? prevUserGrid;
  List<List<bool>>? prevIsOriginal;
  int prevScore = 0;
  bool hasPreviousGame = false;

  int selectedRow = -1;
  int selectedCol = -1;

  // --- Scores & Smart AI Rival ---
  int currentScore = 0;
  int highScore = 0;
  int rivalScore = 120;
  String rivalName = 'Alex 🇺🇸';
  Timer? _dynamicRivalTimer;

  final List<Map<String, String>> globalRivals = [
    {'name': 'Alex 🇺🇸'},
    {'name': 'Kenji 🇯🇵'},
    {'name': 'Aarav 🇮🇳'},
    {'name': 'Elena 🇷🇺'},
    {'name': 'Mateo 🇧🇷'},
    {'name': 'Emma 🇬🇧'},
    {'name': 'Hans 🇩🇪'},
  ];

  // --- AdMob Ads ---
  BannerAd? _topBannerAd;
  bool _isTopBannerLoaded = false;

  NativeAd? _nativeAd;
  bool _isNativeAdLoaded = false;

  InterstitialAd? _interstitialAd;

  // Test Ad Unit IDs
  final String bannerAdUnitId = 'ca-app-pub-8490034567216022/1861368814';
  final String nativeAdUnitId = 'ca-app-pub-8490034567216022/3492022987';
  final String interstitialAdUnitId = 'ca-app-pub-8490034567216022/6856552920';

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _startNewGame(forceDirect: true);
    _startSmartDynamicRival();
    _loadTopBannerAd();
    _loadNativeAd();
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    _dynamicRivalTimer?.cancel();
    _topBannerAd?.dispose();
    _nativeAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  // --- Shared Preferences ---
  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('sudoku_high_score') ?? 0;
    });
  }

  Future<void> _updateHighScore(int score) async {
    if (score > highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('sudoku_high_score', score);
      setState(() {
        highScore = score;
      });
    }
  }

  // --- Smart Adaptive AI Rival ---
  void _startSmartDynamicRival() {
    _dynamicRivalTimer?.cancel();
    _dynamicRivalTimer = Timer.periodic(const Duration(seconds: 12), (timer) {
      if (!mounted) return;

      setState(() {
        Random rng = Random();
        if (currentScore > rivalScore) {
          rivalScore += rng.nextInt(25) + 15;
        } else if (rivalScore - currentScore > 30) {
          rivalScore += rng.nextInt(5);
        } else {
          rivalScore += rng.nextInt(15) + 5;
        }
      });
    });
  }

  void _switchGlobalRival() {
    Random rng = Random();
    var rival = globalRivals[rng.nextInt(globalRivals.length)];
    setState(() {
      rivalName = rival['name']!;
      rivalScore = max(50, currentScore + rng.nextInt(40) - 20);
    });
  }

  // --- AdMob Helpers ---
  void _loadTopBannerAd() {
    _topBannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _isTopBannerLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Top Banner Error: $error');
        },
      ),
    )..load();
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: nativeAdUnitId,
      factoryId: 'adFactoryExample',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isNativeAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Native Ad Error: $error');
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _loadInterstitialAd();
    }
  }

  // --- Save Current Game To History Before New One ---
  void _backupCurrentGame() {
    prevSolutionGrid = List.generate(9, (r) => List.from(solutionGrid[r]));
    prevUserGrid = List.generate(9, (r) => List.from(userGrid[r]));
    prevIsOriginal = List.generate(9, (r) => List.from(isOriginal[r]));
    prevScore = currentScore;
    hasPreviousGame = true;
  }

  // --- Restore Previous Sudoku Board ---
  void _restorePreviousSudoku() {
    if (!hasPreviousGame || prevSolutionGrid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('no_prev_msg')),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() {
      solutionGrid = List.generate(9, (r) => List.from(prevSolutionGrid![r]));
      userGrid = List.generate(9, (r) => List.from(prevUserGrid![r]));
      isOriginal = List.generate(9, (r) => List.from(prevIsOriginal![r]));
      currentScore = prevScore;
      selectedRow = -1;
      selectedCol = -1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t('undo_msg')),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  // --- Infinite Unique Sudoku Engine ---
  void _startNewGame({bool forceDirect = false}) {
    if (!forceDirect && currentScore > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          title: Text(t('restart_title'),
              style: const TextStyle(color: Colors.amber)),
          content: Text(t('restart_msg')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t('keep_playing'),
                  style: const TextStyle(color: Colors.greenAccent)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _executeGameReset();
              },
              child: const Text('New Game 🚀',
                  style: TextStyle(color: Colors.amber)),
            ),
          ],
        ),
      );
    } else {
      _executeGameReset();
    }
  }

  void _executeGameReset() {
    _backupCurrentGame();
    setState(() {
      currentScore = 0;
      selectedRow = -1;
      selectedCol = -1;
      _switchGlobalRival();
      _generateInfiniteSudoku();
    });
  }

  void _generateInfiniteSudoku() {
    solutionGrid = List.generate(9, (_) => List.filled(9, 0));
    _fillGridRandomly(0, 0);

    userGrid = List.generate(9, (r) => List.from(solutionGrid[r]));
    isOriginal = List.generate(9, (_) => List.filled(9, true));

    Random rng = Random();
    int removed = 0;
    int targetRemoval = 45 + rng.nextInt(5);
    while (removed < targetRemoval) {
      int r = rng.nextInt(9);
      int c = rng.nextInt(9);
      if (isOriginal[r][c]) {
        isOriginal[r][c] = false;
        userGrid[r][c] = 0;
        removed++;
      }
    }
  }

  bool _fillGridRandomly(int row, int col) {
    if (row == 9) return true;
    int nextRow = col == 8 ? row + 1 : row;
    int nextCol = col == 8 ? 0 : col + 1;

    List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle(Random());
    for (int num in numbers) {
      if (_isValid(solutionGrid, row, col, num)) {
        solutionGrid[row][col] = num;
        if (_fillGridRandomly(nextRow, nextCol)) return true;
        solutionGrid[row][col] = 0;
      }
    }
    return false;
  }

  bool _isValid(List<List<int>> grid, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (grid[row][i] == num || grid[i][col] == num) return false;
    }
    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (grid[startRow + r][startCol + c] == num) return false;
      }
    }
    return true;
  }

  void _onNumberInput(int number) {
    if (selectedRow == -1 || selectedCol == -1) return;
    if (isOriginal[selectedRow][selectedCol]) return;

    setState(() {
      if (solutionGrid[selectedRow][selectedCol] == number) {
        userGrid[selectedRow][selectedCol] = number;
        currentScore += 10;
        _updateHighScore(currentScore);
        _checkWinCondition();
      } else {
        currentScore = max(0, currentScore - 5);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t('wrong')),
            duration: const Duration(milliseconds: 500),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });
  }

  void _clearCell() {
    if (selectedRow != -1 &&
        selectedCol != -1 &&
        !isOriginal[selectedRow][selectedCol]) {
      setState(() {
        userGrid[selectedRow][selectedCol] = 0;
      });
    }
  }

  void _checkWinCondition() {
    bool isComplete = true;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (userGrid[r][c] != solutionGrid[r][c]) {
          isComplete = false;
          break;
        }
      }
    }

    if (isComplete) {
      _showInterstitialAd();
      bool wonAgainstRival = currentScore > rivalScore;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            wonAgainstRival ? t('victory') : t('completed'),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.amber),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                wonAgainstRival
                    ? t('win_msg').replaceAll('{rival}', rivalName)
                    : t('loss_msg').replaceAll('{rival}', rivalName),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text('${t('your_score')}$currentScore',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text('$rivalName${t('rival_score')}$rivalScore',
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
          actions: [
            Column(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    minimumSize: const Size(double.infinity, 42),
                  ),
                  onPressed: _shareScore,
                  icon: const Icon(Icons.share, color: Colors.black),
                  label: Text(t('share_btn'),
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _startNewGame(forceDirect: true);
                  },
                  child: Text(t('next_btn'),
                      style: const TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  void _shareScore() {
    String msg = t('share_text')
        .replaceAll('{score}', '$currentScore')
        .replaceAll('{rival}', rivalName);
    Share.share(msg);
  }

  // --- Exit Confirmation ---
  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E2E),
            title: Text(t('exit_title'),
                style: const TextStyle(color: Colors.amber)),
            content: Text(t('exit_msg')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(t('keep_playing'),
                    style: const TextStyle(color: Colors.greenAccent)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(t('exit_btn'),
                    style: const TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        )) ??
        false;
  }

  // --- Language Selector Dialog ---
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('🌐 Select Language / भाषा चुनें',
            style: TextStyle(color: Colors.amber, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _langOption('English 🇬🇧', 'en'),
            _langOption('हिंदी 🇮🇳', 'hi'),
            _langOption('Español 🇪🇸', 'es'),
            _langOption('Deutsch 🇩🇪', 'de'),
            _langOption('日本語 🇯🇵', 'ja'),
            _langOption('Français 🇫🇷', 'fr'),
          ],
        ),
      ),
    );
  }

  Widget _langOption(String name, String code) {
    return ListTile(
      title: Text(name,
          style: TextStyle(
              color: currentLang == code ? Colors.amber : Colors.white)),
      trailing: currentLang == code
          ? const Icon(Icons.check, color: Colors.amber)
          : null,
      onTap: () {
        setState(() {
          currentLang = code;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🌍 ${t('title')} ',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text('PRO',
                  style: TextStyle(
                      color: Colors.amber, fontWeight: FontWeight.bold)),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            // ↩️ Restore Previous Sudoku Button
            IconButton(
              icon: const Icon(Icons.undo, color: Colors.amber),
              tooltip: 'Restore Previous Board',
              onPressed: _restorePreviousSudoku,
            ),
            IconButton(
              icon: const Icon(Icons.language, color: Colors.cyanAccent),
              onPressed: _showLanguageDialog,
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.amber),
              onPressed: _shareScore,
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: () => _startNewGame(),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Top Banner Ad
              if (_isTopBannerLoaded)
                SizedBox(
                  height: _topBannerAd!.size.height.toDouble(),
                  width: _topBannerAd!.size.width.toDouble(),
                  child: AdWidget(ad: _topBannerAd!),
                ),

              // Score Board
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _scoreTile(
                        ' ${t('you')} 👤', '$currentScore', Colors.amber),
                    Container(height: 30, width: 1, color: Colors.white24),
                    _scoreTile(
                        ' ${t('high')} 👑', '$highScore', Colors.greenAccent),
                    Container(height: 30, width: 1, color: Colors.white24),
                    _scoreTile(' $rivalName', '$rivalScore', Colors.redAccent),
                  ],
                ),
              ),

              // Sudoku Grid
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 9,
                            ),
                            itemCount: 81,
                            itemBuilder: (context, index) {
                              int row = index ~/ 9;
                              int col = index % 9;
                              bool isSelected =
                                  row == selectedRow && col == selectedCol;
                              bool isOrig = isOriginal[row][col];
                              int val = userGrid[row][col];

                              BorderSide thickBorder = const BorderSide(
                                  color: Colors.amber, width: 1.5);
                              BorderSide thinBorder = const BorderSide(
                                  color: Colors.white12, width: 0.5);

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedRow = row;
                                    selectedCol = col;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.amber.withOpacity(0.35)
                                        : (isOrig
                                            ? Colors.white10
                                            : Colors.transparent),
                                    border: Border(
                                      top: row % 3 == 0
                                          ? thickBorder
                                          : thinBorder,
                                      left: col % 3 == 0
                                          ? thickBorder
                                          : thinBorder,
                                      right:
                                          col == 8 ? thickBorder : thinBorder,
                                      bottom:
                                          row == 8 ? thickBorder : thinBorder,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      val == 0 ? '' : '$val',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: isOrig
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isOrig
                                            ? Colors.white
                                            : (isSelected
                                                ? Colors.amber
                                                : Colors.cyanAccent),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Number Controls
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (i) => _numButton(i + 1)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ...List.generate(4, (i) => _numButton(i + 6)),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.withOpacity(0.2),
                            minimumSize: const Size(42, 42),
                            padding: EdgeInsets.zero,
                            side: const BorderSide(color: Colors.redAccent),
                          ),
                          onPressed: _clearCell,
                          child: const Icon(Icons.backspace_outlined,
                              color: Colors.redAccent, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Native Ad Component
              if (_isNativeAdLoaded && _nativeAd != null)
                Container(
                  height: 65,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.withOpacity(0.4)),
                  ),
                  child: AdWidget(ad: _nativeAd!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreTile(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _numButton(int number) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white12,
        minimumSize: const Size(42, 42),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => _onNumberInput(number),
      child: Text(
        '$number',
        style: const TextStyle(
            fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
