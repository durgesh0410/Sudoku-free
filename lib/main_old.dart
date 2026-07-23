import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // विज्ञापन पैकेज
import 'package:share_plus/share_plus.dart'; // शेयर और इनवाइट पैकेज
import 'package:flutter_localizations/flutter_localizations.dart'; // ग्लोबल सपोर्ट

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize(); // विज्ञापन चालू करना
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sudoku Unlimited',
      theme: ThemeData.dark(),

      // 🌍 वैश्विक पहुंच (Localization)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('hi'), // Hindi
        Locale('es'), // Spanish
        Locale('ja'), // Japanese
        Locale('de'), // German
        Locale('fr'), // French
        Locale('zh'), // Chinese
      ],

      home: const SudokuBoardScreen(),
    );
  }
}

class SudokuBoardScreen extends StatefulWidget {
  const SudokuBoardScreen({super.key});

  @override
  State<SudokuBoardScreen> createState() => _SudokuBoardScreenState();
}

class _SudokuBoardScreenState extends State<SudokuBoardScreen> {
  List<List<int>> sudokuGrid = List.generate(9, (_) => List.filled(9, 0));
  List<List<int>> originalGrid = List.generate(9, (_) => List.filled(9, 0));
  List<List<int>> solutionGrid = List.generate(9, (_) => List.filled(9, 0));

  int selectedRow = -1;
  int selectedCol = -1;
  int score = 0; // ऑर्गेनिक पब्लिसिटी के लिए स्कोर काउंटर

  // विज्ञापन वेरिएबल्स
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    generateNewSudoku();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-8490034567216022/1861368814', // टेस्ट आईडी
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerAdReady = true),
        onAdFailedToLoad: (ad, err) {
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-8490034567216022/1820437992', // टेस्ट आईडी
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd?.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      print('इन्टर्स्टिशियल विज्ञापन अभी तैयार नहीं है।');
    }
  }

  void _inviteFriend() {
    Share.share(
      '🧩 अरे देखो! मैं "Sudoku Free" पर माइंड-ब्लोइंग सुडोकू खेल रहा हूँ। क्या तुम मेरा रिकॉर्ड तोड़ सकते हो? अभी डाउनलोड करो और मुझे चैलेंज करो: https://play.google.com/store/apps/details?id=com.yourdomain.sudokufree',
      subject: 'सुडोकू चैलेंज! 🧠',
    );
  }

  void _shareMyScore() {
    Share.share(
      '🎉 मैंने अभी-अभी Sudoku Free में $score पॉइंट्स के साथ एक कठिन सुडोकू लेवल पार किया है! 😎 क्या तुम मुझसे बेहतर कर सकते हो? गेम खेलो और अपना स्कोर दिखाओ!',
    );
  }

  void generateNewSudoku() {
    List<List<int>> baseGrid = List.generate(9, (_) => List.filled(9, 0));
    fillGrid(baseGrid);
    solutionGrid = List.generate(9, (r) => List.from(baseGrid[r]));

    var random = Random();
    int cellsToRemove = 45;

    while (cellsToRemove > 0) {
      int row = random.nextInt(9);
      int col = random.nextInt(9);
      if (baseGrid[row][col] != 0) {
        baseGrid[row][col] = 0;
        cellsToRemove--;
      }
    }

    setState(() {
      originalGrid = List.generate(9, (r) => List.from(baseGrid[r]));
      sudokuGrid = List.generate(9, (r) => List.from(baseGrid[r]));
      selectedRow = -1;
      selectedCol = -1;
    });
  }

  bool fillGrid(List<List<int>> grid) {
    var random = Random();
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle(random);
          for (int num in numbers) {
            if (isValidMove(grid, row, col, num)) {
              grid[row][col] = num;
              if (fillGrid(grid)) return true;
              grid[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool isValidMove(List<List<int>> grid, int row, int col, int num) {
    for (int x = 0; x < 9; x++) {
      if (grid[row][x] == num && x != col) return false;
      if (grid[x][col] == num && x != row) return false;
    }
    int startRow = row - row % 3;
    int startCol = col - col % 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (grid[i + startRow][j + startCol] == num &&
            (i + startRow != row || j + startCol != col)) {
          return false;
        }
      }
    }
    return true;
  }

  // 🏆 जीत की सही कंडीशन जांचने का फंक्शन
  void checkWinCondition() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        // यदि कोई डिब्बा खाली है या सॉल्यूशन ग्रिड से मैच नहीं कर रहा है, तो खेल चालू रहेगा
        if (sudokuGrid[r][c] == 0 || sudokuGrid[r][c] != solutionGrid[r][c]) {
          return;
        }
      }
    }

    // गेम पूरी तरह जीतने पर 100 बोनस स्कोर
    setState(() {
      score += 100;
    });

    // जीत का डायलॉग बॉक्स
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 बधाई हो! 🎉', textAlign: TextAlign.center),
        content: Text(
          'आपने सुडोकू पहेली को सफलतापूर्वक हल कर लिया है!\nआपका कुल स्कोर: $score ⭐️',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton.icon(
            onPressed: _shareMyScore,
            icon: const Icon(Icons.share, color: Colors.amber),
            label: const Text('स्कोर शेयर करें',
                style: TextStyle(color: Colors.amber)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              generateNewSudoku();
              _showInterstitialAd();
            },
            child: const Text('नया गेम खेलें'),
          )
        ],
      ),
    );
  }

  void checkAndSetNumber(int number) {
    if (selectedRow != -1 && selectedCol != -1) {
      if (originalGrid[selectedRow][selectedCol] != 0) return;

      setState(() {
        if (number == 0) {
          sudokuGrid[selectedRow][selectedCol] = 0;
        } else {
          // चेक करें कि भरा हुआ नंबर सही (सॉल्यूशन ग्रिड के अनुसार) है या नहीं
          if (number == solutionGrid[selectedRow][selectedCol]) {
            sudokuGrid[selectedRow][selectedCol] = number;
            score += 10; // हर सही नंबर पर 10 स्कोर बढ़ेगा
            checkWinCondition();
          } else {
            // गलत चाल चलने पर ग्रिड में नंबर तो दिखेगा, पर स्कोर 5 अंक कम हो जाएगा
            sudokuGrid[selectedRow][selectedCol] = number;
            if (score >= 5) score -= 5;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ गलत चाल! ध्यान से सोचें। स्कोर कम हुआ।'),
                duration: Duration(milliseconds: 800),
              ),
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('अनलिमिटेड सुडोकू 🧩'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.group_add, color: Colors.lightBlueAccent),
          tooltip: 'दोस्तों को इनवाइट करें',
          onPressed: _inviteFriend,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Text(
                'स्कोर: $score',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.autorenew),
            onPressed: () {
              generateNewSudoku();
              _showInterstitialAd();
            },
          )
        ],
      ),
      body: Column(
        children: [
          if (_isBannerAdReady)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2.0),
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 81,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 9,
                          ),
                          itemBuilder: (context, index) {
                            int row = index ~/ 9;
                            int col = index % 9;
                            int value = sudokuGrid[row][col];
                            bool isSelected =
                                (row == selectedRow && col == selectedCol);
                            bool isOriginal = originalGrid[row][col] != 0;

                            // गलत भरे गए नंबरों को लाल रंग से दिखाने के लिए
                            bool isWrong =
                                value != 0 && value != solutionGrid[row][col];

                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                      color: Colors.grey[800]!, width: 0.5),
                                  left: BorderSide(
                                      color: Colors.grey[800]!, width: 0.5),
                                  bottom: BorderSide(
                                    color: (row == 2 || row == 5)
                                        ? Colors.white
                                        : Colors.grey[800]!,
                                    width: (row == 2 || row == 5) ? 2.0 : 0.5,
                                  ),
                                  right: BorderSide(
                                    color: (col == 2 || col == 5)
                                        ? Colors.white
                                        : Colors.grey[800]!,
                                    width: (col == 2 || col == 5) ? 2.0 : 0.5,
                                  ),
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedRow = row;
                                    selectedCol = col;
                                  });
                                },
                                child: Container(
                                  color: isSelected
                                      ? Colors.amber[700]
                                      : (isOriginal
                                          ? Colors.grey[900]
                                          : Colors.grey[800]),
                                  child: Center(
                                    child: Text(
                                      value == 0 ? '' : '$value',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: isOriginal
                                            ? Colors.white
                                            : (isWrong
                                                ? Colors.red[300]
                                                : Colors.blue[300]),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        alignment: WrapAlignment.center,
                        children: [
                          ...List.generate(9, (index) {
                            int number = index + 1;
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey[700],
                                minimumSize: const Size(45, 45),
                              ),
                              onPressed: () => checkAndSetNumber(number),
                              child: Text('$number',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            );
                          }),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[800],
                              minimumSize: const Size(100, 45),
                            ),
                            onPressed: () => checkAndSetNumber(0),
                            icon: const Icon(Icons.delete, color: Colors.white),
                            label: const Text('Erase',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      OutlinedButton.icon(
                        onPressed: _inviteFriend,
                        icon: const Icon(Icons.share,
                            color: Colors.lightBlueAccent),
                        label: const Text('दोस्तों को चैलेंज भेजें 🥊',
                            style: TextStyle(color: Colors.lightBlueAccent)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
