import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:translator/translator.dart' show GoogleTranslator;
import 'package:flutter/rendering.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  bool isDarkMode = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      if (_animationController.status == AnimationStatus.completed) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: isDarkMode ? _buildDarkTheme() : _buildLightTheme(),
            home: DefaultTabController(
              length: 3,
              initialIndex: 0,
              child: WeatherSuggestionApp(
                  toggleTheme: toggleTheme, isDarkMode: isDarkMode),
            ),
          );
        });
  }

  ThemeData _buildDarkTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      primaryColor: Color(0xFF2E7D32), // Deeper green
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF2E7D32),
        secondary: Color(0xFF81C784),
        surface: Color(0xFF121212),
        background: Color(0xFF121212),
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: Color(0xFF121212),
      cardColor: Color(0xFF1E1E1E),
      textTheme: _buildTextTheme(base.textTheme, Colors.white),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          textStyle: TextStyle(fontSize: 16),
          elevation: 3,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF81C784), width: 2),
        ),
        labelStyle: TextStyle(color: Colors.white70),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Color(0xFF1E1E1E),
        shadowColor: Colors.green.withOpacity(0.3),
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
      splashColor: Colors.green.withOpacity(0.3),
      highlightColor: Colors.green.withOpacity(0.1),
    );
  }

  ThemeData _buildLightTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      primaryColor: Color(0xFF2E7D32), // Deeper green
      colorScheme: ColorScheme.light(
        primary: Color(0xFF2E7D32),
        secondary: Color(0xFF81C784),
        surface: Colors.white,
        background: Colors.white,
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: Color(0xFFF5F5F5),
      cardColor: Colors.white,
      textTheme: _buildTextTheme(base.textTheme, Color(0xFF263238)),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          textStyle: TextStyle(fontSize: 16),
          elevation: 2,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
        labelStyle: TextStyle(color: Colors.grey[700]),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        shadowColor: Colors.green.withOpacity(0.3),
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
      splashColor: Colors.green.withOpacity(0.3),
      highlightColor: Colors.green.withOpacity(0.1),
    );
  }

  TextTheme _buildTextTheme(TextTheme base, Color color) {
    return base.copyWith(
      headlineLarge: base.headlineLarge
          ?.copyWith(color: color, fontWeight: FontWeight.bold),
      titleLarge:
          base.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
      bodyMedium: base.bodyMedium?.copyWith(color: color),
    );
  }
}

class WeatherSuggestionApp extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const WeatherSuggestionApp(
      {super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  _WeatherSuggestionAppState createState() => _WeatherSuggestionAppState();
}

class _WeatherSuggestionAppState extends State<WeatherSuggestionApp>
    with SingleTickerProviderStateMixin {
  final TextEditingController _locationController = TextEditingController();
  String? weatherInfo;
  String? suggestion;
  String translatedText = "";
  final translator = GoogleTranslator(); // Online Translator
  late AnimationController _themeIconController;

  @override
  void initState() {
    super.initState();
    _themeIconController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _themeIconController.dispose();
    super.dispose();
  }

  Map<String, Map<String, String>> cropDetails = {
    'Tomato': {
      'description':
          'Tomatoes require full sun and well-drained soil. Water regularly and provide support for the plants as they grow.',
      'planting':
          'Plant seeds ¼ inch deep, or set transplants 18-36 inches apart, depending on variety.',
      'care':
          'Provide support for plants with stakes or cages. Water deeply and consistently. Apply mulch to retain moisture.',
      'harvesting':
          'Harvest when fruits have reached full color but are still firm, typically 60-85 days after planting.',
      'pests':
          'Common pests include tomato hornworms, aphids, and flea beetles. Watch for early blight and late blight diseases.'
    },
    'Radish': {
      'description':
          'Radishes grow best in cool weather. Plant them in loose soil and keep them well-watered.',
      'planting':
          'Sow seeds ½ inch deep and 1 inch apart, with rows 12 inches apart. Thin to 2 inches apart when seedlings emerge.',
      'care':
          'Keep soil consistently moist. Provide even watering to prevent splitting. Avoid high nitrogen fertilizers.',
      'harvesting':
          'Harvest when roots are about 1 inch in diameter, typically 3-4 weeks after planting.',
      'pests':
          'Watch for flea beetles, root maggots, and aphids. Ensure good air circulation to prevent disease.'
    },
    'Carrot': {
      'description':
          'Carrots need deep, loose soil to grow properly. Thin the seedlings to avoid overcrowding.',
      'planting':
          'Sow seeds ¼ inch deep and ½ inch apart, with rows 12-18 inches apart. Thin to 2-3 inches apart once established.',
      'care':
          'Keep soil consistently moist. Mulch to retain moisture and suppress weeds. Avoid high nitrogen fertilizers.',
      'harvesting':
          'Harvest when roots reach desired size, typically 60-80 days after planting. Pull gently from the soil.',
      'pests':
          'Watch for carrot rust flies, nematodes, and aphids. Rotate crops to prevent disease buildup.'
    },
    'Potato': {
      'description':
          'Potatoes prefer cool weather and well-drained soil. Hill the soil around the plants as they grow.',
      'planting':
          'Plant seed potatoes 4-6 inches deep and 12 inches apart, with rows 24-36 inches apart.',
      'care':
          'Hill soil around plants as they grow to prevent greening of tubers. Water consistently, especially during tuber formation.',
      'harvesting':
          'Harvest new potatoes 2-3 weeks after plants flower. For mature potatoes, harvest 2-3 weeks after foliage dies back.',
      'pests':
          'Colorado potato beetles and aphids are common pests. Watch for late blight and early blight.'
    },
    'Cabbage': {
      'description':
          'Cabbage needs full sun and rich, well-drained soil. Protect the plants from pests.',
      'planting':
          'Transplant seedlings 12-24 inches apart, with rows 24-36 inches apart. Plant in early spring or fall.',
      'care':
          'Water consistently and apply balanced fertilizer. Add mulch to retain moisture and suppress weeds.',
      'harvesting':
          'Harvest when heads are firm and reach desired size, typically 70-100 days after planting.',
      'pests':
          'Cabbage worms, aphids, and flea beetles are common pests. Use row covers to protect plants.'
    },
    'Spinach': {
      'description':
          'Spinach grows best in cool weather. Plant it in rich, well-drained soil and keep it well-watered.',
      'planting':
          'Sow seeds ½ inch deep and 2 inches apart, with rows 12-18 inches apart. Thin to 4-6 inches apart.',
      'care':
          'Water consistently and fertilize with nitrogen-rich fertilizer. Provide shade in warmer weather.',
      'harvesting':
          'Harvest outer leaves as needed, or cut entire plant 1 inch above soil level 40-50 days after planting.',
      'pests':
          'Watch for aphids, leaf miners, and slugs. Provide good air circulation to prevent disease.'
    },
    'Broccoli': {
      'description':
          'Broccoli requires full sun and rich, well-drained soil. Protect the plants from pests.',
      'planting':
          'Transplant seedlings 18-24 inches apart, with rows 24-36 inches apart.',
      'care':
          'Water consistently and apply balanced fertilizer. Add mulch to retain moisture and suppress weeds.',
      'harvesting':
          'Harvest the central head when buds are firm and tight, before flowers open. Side shoots will develop for later harvests.',
      'pests':
          'Cabbage worms, aphids, and flea beetles are common pests. Use row covers to protect plants.'
    },
    'Cauliflower': {
      'description':
          'Cauliflower needs full sun and rich, well-drained soil. Keep the soil moist and protect the plants from pests.',
      'planting':
          'Transplant seedlings 18-24 inches apart, with rows 24-36 inches apart.',
      'care':
          'Water consistently and apply balanced fertilizer. Blanch heads by tying leaves over the developing head when it is about 2-3 inches across.',
      'harvesting':
          'Harvest when head reaches desired size and is still compact, typically 60-100 days after planting.',
      'pests':
          'Cabbage worms, aphids, and flea beetles are common pests. Use row covers to protect plants.'
    },
    'Lettuce': {
      'description':
          'Lettuce grows best in cool weather. Plant it in rich, well-drained soil and keep it well-watered.',
      'planting':
          'Sow seeds ¼ inch deep and 1 inch apart, with rows 12-18 inches apart. Thin leaf lettuce to 4-6 inches apart, head lettuce to 8-12 inches.',
      'care':
          'Water consistently to prevent bitter taste. Provide shade in warmer weather. Fertilize with balanced fertilizer.',
      'harvesting':
          'Harvest leaf lettuce by picking outer leaves as needed. Harvest head lettuce when heads are firm, typically 45-80 days after planting.',
      'pests':
          'Watch for aphids, slugs, and snails. Ensure good air circulation to prevent disease.'
    },
    'Pepper': {
      'description':
          'Peppers need full sun and well-drained soil. Water regularly and provide support for the plants as they grow.',
      'planting':
          'Transplant seedlings 18-24 inches apart, with rows 24-36 inches apart, after all danger of frost has passed.',
      'care':
          'Water consistently and apply balanced fertilizer. Add mulch to retain moisture and suppress weeds. Support larger varieties with stakes.',
      'harvesting':
          'Harvest when peppers reach desired size and color, typically 60-90 days after planting.',
      'pests':
          'Watch for aphids, pepper maggots, and spider mites. Ensure good air circulation to prevent disease.'
    },
    'Wheat': {
      'description':
          'Wheat is a cereal grain that grows in various climates. It prefers well-drained soil and full sun exposure.',
      'planting':
          'Sow seeds 1-1.5 inches deep and 1 inch apart in rows 6-8 inches apart. Plant in fall for winter wheat or spring for spring wheat.',
      'care':
          'Water regularly during germination and growth stages. Fertilize with nitrogen-rich fertilizer at planting and when plants begin to grow rapidly.',
      'harvesting':
          'Harvest when stalks turn golden and grain is hard, typically 110-130 days after planting. Cut stalks and thresh to remove grain.',
      'pests':
          'Common pests include aphids, Hessian fly, and armyworms. Watch for rust, powdery mildew, and fungal diseases.'
    },
    'Rice': {
      'description':
          'Rice is a cereal grain that thrives in water-saturated soil. It requires warm temperatures and high humidity.',
      'planting':
          'Sow pre-soaked seeds in wet soil or transplant seedlings 6-8 inches apart. Maintain water level 2-4 inches above soil.',
      'care':
          'Keep field flooded until grains begin to ripen. Apply balanced fertilizer at planting and during tillering stage.',
      'harvesting':
          'Harvest when grains are firm and stalks turn golden-yellow, typically 105-150 days after planting. Drain field 7-10 days before harvest.',
      'pests':
          'Common pests include rice water weevil, stem borers, and leafhoppers. Watch for blast disease, bacterial leaf blight, and sheath blight.'
    },
    'Corn': {
      'description':
          'Corn (maize) requires full sun and nutrient-rich, well-drained soil. It needs consistent moisture and warm temperatures.',
      'planting':
          'Plant seeds 1-2 inches deep and 4-6 inches apart in rows 30-36 inches apart after soil temperature reaches 60°F.',
      'care':
          'Water deeply, providing 1-1.5 inches per week. Side-dress with nitrogen when plants are 12 inches tall and again when tassels form.',
      'harvesting':
          'Harvest sweet corn when kernels are plump and milky, about 18-24 days after silk appears. For field corn, wait until kernels are dry and hard.',
      'pests':
          'Common pests include corn earworms, European corn borers, and corn rootworms. Watch for smut, rust, and leaf blights.'
    },
  };

  Future<void> fetchWeatherAndSuggestion(String location) async {
    if (location.trim().isEmpty) {
      setState(() {
        weatherInfo = "Error: Please enter a location";
      });
      return;
    }

    setState(() {
      weatherInfo = "Loading weather data...";
      suggestion = null;
    });

    const String apiKey = "YOUR_API_KEY";
    final String url =
        "https://api.openweathermap.org/data/2.5/forecast?q=$location&units=metric&appid=$apiKey";

    try {
      final response = await http
          .get(Uri.parse(url), headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        try {
          setState(() {
            // Safely extract data with null checks
            weatherInfo = data['list']
                .take(7)
                .map<String>((entry) =>
                    "${entry['dt_txt'] ?? 'Unknown date'}: ${entry['weather']?[0]?['description'] ?? 'Unknown'}, Temp: ${entry['main']?['temp'] ?? 'N/A'}°C")
                .join('\n');

            // Process data for suggestions
            suggestion = getSuggestions(data['list'].take(7).toList());
          });
        } catch (parseError) {
          setState(() {
            weatherInfo = "Error parsing weather data: $parseError";
          });
        }
      } else {
        setState(() {
          weatherInfo =
              "Error: ${json.decode(response.body)['message'] ?? 'Failed to fetch data'}";
        });
      }
    } catch (e) {
      setState(() {
        weatherInfo = "Error fetching weather data: $e";
      });
    }
  }

  String getSuggestions(List<dynamic> forecast) {
    StringBuffer suggestions = StringBuffer();

    for (var entry in forecast) {
      String condition = entry['weather'][0]['description'];

      // Convert numeric values to double to handle both int and double types
      double avgTemp = entry['main']['temp'] is int
          ? (entry['main']['temp'] as int).toDouble()
          : entry['main']['temp'];

      double humidity = entry['main']['humidity'] is int
          ? (entry['main']['humidity'] as int).toDouble()
          : entry['main']['humidity'];

      double windSpeed = entry['wind']['speed'] is int
          ? (entry['wind']['speed'] as int).toDouble()
          : entry['wind']['speed'];

      // Additional parameters if available
      double pressure = 0;
      if (entry['main']?['pressure'] != null) {
        pressure = entry['main']['pressure'] is int
            ? (entry['main']['pressure'] as int).toDouble()
            : entry['main']['pressure'];
      }

      suggestions.writeln("Date: ${entry['dt_txt']}");
      suggestions.writeln("Condition: $condition");
      suggestions.writeln("Average Temperature: ${avgTemp}°C");
      suggestions.writeln("Humidity: ${humidity}%");
      suggestions.writeln("Wind Speed: ${windSpeed} m/s");
      if (pressure > 0) {
        suggestions.writeln("Pressure: ${pressure} hPa");
      }

      // Primary Weather Condition Advice
      if (condition.contains("rain")) {
        if (condition.contains("light rain")) {
          suggestions.writeln(
              "Advice: Light rain expected. Good for most crops, but monitor drainage for seedlings.");
        } else if (condition.contains("heavy") ||
            condition.contains("extreme")) {
          suggestions.writeln(
              "Advice: Heavy rainfall expected. Ensure proper drainage, reinforce crop supports, and protect against soil erosion.");
        } else {
          suggestions.writeln(
              "Advice: Moderate rain expected. Ensure proper drainage and protect crops from waterlogging.");
        }

        // Crop-specific rain advice
        suggestions.writeln(
            "• Rice crops will benefit, ensure field flooding is maintained.");
        suggestions.writeln(
            "• For tomatoes and peppers, consider additional shelter to prevent disease.");
        suggestions.writeln(
            "• Delay any scheduled spraying of pesticides or fertilizers.");
      } else if (condition.contains("snow")) {
        suggestions.writeln(
            "Advice: Snow expected. Protect crops with frost covers or greenhouses.");
        suggestions
            .writeln("• Use row covers or cloches for small vegetable plots.");
        suggestions.writeln(
            "• Consider adding mulch around perennials for insulation.");
        suggestions.writeln(
            "• For fruit trees, ensure branches are supported to prevent snow damage.");
      } else if (condition.contains("storm") || condition.contains("thunder")) {
        suggestions.writeln(
            "Advice: Thunderstorms expected. Secure all farm equipment and protect crops from potential damage.");
        suggestions.writeln(
            "• Stake tall plants like corn, tomatoes, and sunflowers securely.");
        suggestions.writeln("• Move potted plants to sheltered locations.");
        suggestions
            .writeln("• Check drainage systems before the storm arrives.");
      } else if (condition.contains("fog") || condition.contains("mist")) {
        suggestions.writeln(
            "Advice: Foggy conditions expected. Be cautious of increased disease risk in humid conditions.");
        suggestions
            .writeln("• Monitor for fungal diseases in susceptible crops.");
        suggestions.writeln(
            "• Consider preventative fungicide application for high-value crops.");
        suggestions.writeln(
            "• Delay irrigation until fog clears to minimize moisture levels.");
      } else if (condition.contains("clear") || condition.contains("sunny")) {
        if (avgTemp > 35) {
          suggestions.writeln(
              "Advice: Hot, clear conditions expected. Risk of heat stress and increased water needs.");
        } else if (avgTemp > 25) {
          suggestions.writeln(
              "Advice: Warm, clear conditions. Ideal for many crops but monitor moisture levels.");
        } else {
          suggestions.writeln(
              "Advice: Clear conditions expected. Good opportunity for field activities.");
        }
      }

      // Secondary Parameter-Based Advice
      if (humidity > 85) {
        suggestions.writeln(
            "Advice: Very high humidity detected. High risk of fungal diseases and mildew.");
        suggestions
            .writeln("• Increase plant spacing to improve air circulation.");
        suggestions.writeln(
            "• Remove lower leaves from tomatoes, peppers, and cucumbers to improve air flow.");
        suggestions.writeln(
            "• Consider preventative fungicide application for susceptible crops.");
      } else if (humidity > 70) {
        suggestions.writeln(
            "Advice: High humidity detected. Monitor for early signs of fungal growth.");
      }

      if (windSpeed > 15) {
        suggestions.writeln(
            "Advice: Strong winds expected. Secure plants, structures, and equipment immediately.");
        suggestions.writeln("• Delay spraying operations and irrigation.");
        suggestions
            .writeln("• Consider temporary windbreaks for vulnerable crops.");
      } else if (windSpeed > 8) {
        suggestions.writeln(
            "Advice: Moderate winds expected. Secure tall plants with stakes.");
      }

      if (avgTemp > 38) {
        suggestions.writeln(
            "Advice: Extreme heat alert. Risk of crop damage is high.");
        suggestions.writeln(
            "• Use shade cloth for sensitive crops like lettuce and spinach.");
        suggestions.writeln(
            "• Increase irrigation frequency but with shorter durations.");
        suggestions.writeln(
            "• Mulch exposed soil to reduce evaporation and protect roots.");
      } else if (avgTemp > 35) {
        suggestions.writeln(
            "Advice: Very high temperatures. Water crops in early morning or evening.");
        suggestions.writeln("• Consider postponing transplanting operations.");
      } else if (avgTemp < 5) {
        suggestions.writeln(
            "Advice: Very cold conditions expected. High risk of frost damage.");
        suggestions.writeln(
            "• Use frost covers, row covers, or cloches to protect sensitive crops.");
        suggestions.writeln(
            "• Irrigate soil before nightfall to increase heat retention.");
      } else if (avgTemp < 10) {
        suggestions.writeln(
            "Advice: Cold weather ahead. Monitor for frost and protect sensitive plants.");
      }

      if (pressure < 990) {
        suggestions.writeln(
            "Advice: Low pressure system. Prepare for changing weather conditions, possibly storms.");
      } else if (pressure > 1025) {
        suggestions.writeln(
            "Advice: High pressure system. Expect stable weather, good for farm operations.");
      }

      // Optimal conditions check
      if (avgTemp >= 18 &&
          avgTemp <= 28 &&
          humidity >= 40 &&
          humidity <= 70 &&
          windSpeed < 5 &&
          !condition.contains("rain") &&
          !condition.contains("snow") &&
          !condition.contains("storm")) {
        suggestions.writeln(
            "Advice: Optimal growing conditions for most crops. Ideal for seeding, transplanting, and field operations.");
      }

      suggestions.writeln("\n");
    }
    return suggestions.toString();
  }

  void _openChatbot() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChatbotScreen(isDarkMode: widget.isDarkMode)),
    );
  }

  void _showCropDetails(String crop, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CropDetailScreen(
          crop: crop,
          imageUrl: imageUrl,
          details:
              cropDetails[crop] ?? {'description': 'No information available.'},
        ),
      ),
    );
  }

  void _navigateToSection(int index) {
    DefaultTabController.of(context)?.animateTo(index);
    Navigator.pop(context); // Close the drawer
  }

  void _openContactUs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContactUsScreen()),
    );
  }

  // Function to translate text
  Future<void> translateText(String text, String targetLang) async {
    if (text.isEmpty) return;
    final translation = await translator.translate(text, to: targetLang);
    setState(() {
      translatedText = translation.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'app_title',
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: 300),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  child: Text("KrishiMitra"),
                ),
              ),
            ],
          ),
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions: [
          AnimatedBuilder(
            animation: _themeIconController,
            builder: (context, child) {
              return IconButton(
                icon: Icon(
                    widget.isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
                onPressed: widget.toggleTheme,
                tooltip: widget.isDarkMode
                    ? 'Switch to Light Mode'
                    : 'Switch to Dark Mode',
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                image: DecorationImage(
                  image: AssetImage('assets/cabbage.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.darken,
                  ),
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        margin: EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text(
                        'KrishiMitra',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your Farming Assistant',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            _buildAnimatedListTile(
              icon: Icons.eco,
              title: 'About the Crops',
              onTap: () => _navigateToSection(0),
            ),
            _buildAnimatedListTile(
              icon: Icons.lightbulb_outline,
              title: 'Crop Suggestions',
              onTap: () => _navigateToSection(1),
            ),
            _buildAnimatedListTile(
              icon: Icons.cloud,
              title: 'Weather Information',
              onTap: () => _navigateToSection(2),
            ),
            Divider(),
            _buildAnimatedListTile(
              icon: Icons.contact_mail,
              title: 'Contact Us',
              onTap: _openContactUs,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              children: [
                _buildAboutCropsSection(),
                _buildSuggestionsSection(),
                _buildWeatherInfoSection(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(0, 0, 0)..scale(1.0),
        child: FloatingActionButton.extended(
          onPressed: _openChatbot,
          icon: Icon(Icons.chat),
          label: Text("FarmBot"),
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(width: 3.0, color: Colors.white),
          insets: EdgeInsets.symmetric(horizontal: 16.0),
        ),
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
        tabs: [
          _buildAnimatedTab(Icons.eco, "Crops"),
          _buildAnimatedTab(Icons.lightbulb_outline, "Suggestions"),
          _buildAnimatedTab(Icons.cloud, "Weather"),
        ],
      ),
    );
  }

  Widget _buildAnimatedTab(IconData icon, String text) {
    return Tab(
      height: 72,
      child: Padding(
        padding: EdgeInsets.only(top: 8, bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24),
            SizedBox(height: 4),
            Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCropsSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Explore Crops",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Tap on any crop to learn more about growing techniques, care instructions, and harvesting tips.",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildCropCard('Tomato', 'assets/tomato.jpg'),
                _buildCropCard('Radish', 'assets/radish.jpg'),
                _buildCropCard('Carrot', 'assets/carrot.jpg'),
                _buildCropCard('Potato', 'assets/potato.jpg'),
                _buildCropCard('Cabbage', 'assets/cabbage.jpg'),
                _buildCropCard('Spinach', 'assets/spinach.jpeg'),
                _buildCropCard('Broccoli', 'assets/broccoli.jpeg'),
                _buildCropCard('Cauliflower', 'assets/cauliflower.jpeg'),
                _buildCropCard('Lettuce', 'assets/lettuce.jpeg'),
                _buildCropCard('Pepper', 'assets/pepper.jpeg'),
                _buildCropCard('Wheat', 'assets/wheat.webp'),
                _buildCropCard('Rice', 'assets/rice.webp'),
                _buildCropCard('Corn', 'assets/corn.webp'),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(height: 20),
                TranslationButtons(
                    onTranslate: (lang) =>
                        translateText("About the Crops", lang)),
                SizedBox(height: 20),
                if (translatedText.isNotEmpty)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        translatedText,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropCard(String crop, String imageUrl) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: InkWell(
        onTap: () => _showCropDetails(crop, imageUrl),
        borderRadius: BorderRadius.circular(12),
        splashColor: Theme.of(context).primaryColor.withOpacity(0.3),
        highlightColor: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Card(
          elevation: 4,
          shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Hero(
                  tag: 'crop_image_$crop',
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(imageUrl),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.1),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                color: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  crop,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Weather-Based Crop Suggestions",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Enter your location to get personalized crop suggestions based on weather forecast.",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: "Enter Location",
                    hintText: "e.g., New York, London, Mumbai",
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    fetchWeatherAndSuggestion(_locationController.text);
                  },
                  icon: Icon(Icons.search),
                  label: Text("Get Suggestions"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
                SizedBox(height: 24),
                if (suggestion == null && weatherInfo == null)
                  _buildEmptySuggestionState()
                else if (weatherInfo == "Loading weather data...")
                  _buildLoadingState()
                else if (weatherInfo != null &&
                    weatherInfo!.startsWith("Error"))
                  _buildErrorState(weatherInfo!)
                else if (suggestion != null)
                  _buildSuggestionCards(suggestion!),
                SizedBox(height: 20),
                if (suggestion != null)
                  Column(
                    children: [
                      Divider(height: 40),
                      Text(
                        "Translate Suggestions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      TranslationButtons(
                          onTranslate: (lang) =>
                              translateText(suggestion ?? "", lang)),
                      SizedBox(height: 20),
                      if (translatedText.isNotEmpty)
                        Card(
                          elevation: 2,
                          margin: EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              translatedText,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySuggestionState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            "Enter a location to get crop suggestions",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            "Fetching weather data...",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Please check the location name and try again.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCards(String suggestions) {
    List<String> entries =
        suggestions.split('\n\n').where((e) => e.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Forecast & Suggestions",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 12),
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            List<String> lines = entry.split('\n');
            String date =
                lines.isNotEmpty ? lines[0].replaceAll("Date: ", "") : "";

            // Use staggered duration for each card
            final staggeredDuration =
                Duration(milliseconds: 600 + (index * 100));

            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: staggeredDuration,
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                    },
                    borderRadius: BorderRadius.circular(12),
                    splashColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    highlightColor:
                        Theme.of(context).primaryColor.withOpacity(0.05),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.calendar_today,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  date,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider(height: 24),
                          ...lines.skip(1).map((line) {
                            IconData icon;
                            Color iconColor;

                            if (line.startsWith("Condition:")) {
                              icon = Icons.cloud;
                              iconColor = Colors.lightBlue;
                            } else if (line
                                .startsWith("Average Temperature:")) {
                              icon = Icons.thermostat;
                              iconColor = Colors.orange;
                            } else if (line.startsWith("Humidity:")) {
                              icon = Icons.water_drop;
                              iconColor = Colors.blue;
                            } else if (line.startsWith("Wind Speed:")) {
                              icon = Icons.air;
                              iconColor = Colors.blueGrey;
                            } else {
                              icon = Icons.eco;
                              iconColor = Colors.green;
                            }








































                            return Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: iconColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Icon(icon,
                                          color: iconColor, size: 16),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      line,
                                      style: TextStyle(
                                        fontSize: 15,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeatherInfoSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Weather Forecast",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "View detailed weather information to plan your farming activities.",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (weatherInfo == null ||
                    weatherInfo!.startsWith("Error") ||
                    weatherInfo == "Loading weather data...")
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Enter a location in the 'Suggestions' tab to get weather information.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () =>
                              DefaultTabController.of(context)?.animateTo(1),
                          icon: Icon(Icons.navigate_next),
                          label: Text("Go to Suggestions"),
                        ),
                      ],
                    ),
                  )
                else if (weatherInfo != null)
                  _buildWeatherForecast(weatherInfo!),
                SizedBox(height: 20),
                if (weatherInfo != null &&
                    !weatherInfo!.startsWith("Error") &&
                    weatherInfo != "Loading weather data...")
                  Column(
                    children: [
                      Divider(height: 40),
                      Text(
                        "Translate Weather Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      TranslationButtons(
                          onTranslate: (lang) =>
                              translateText(weatherInfo ?? "", lang)),
                      SizedBox(height: 20),
                      if (translatedText.isNotEmpty)
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              translatedText,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherForecast(String weatherInfo) {
    List<String> entries = weatherInfo.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "7-Day Forecast",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 12),
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            List<String> parts = entry.split(': ');
            if (parts.length < 2) return SizedBox.shrink();

            String dateTime = parts[0];
            String weatherDetails = parts.sublist(1).join(': ');

            // Extract weather and temperature
            List<String> detailsParts = weatherDetails.split(', Temp: ');
            String weatherDesc = detailsParts[0];
            String temperature = detailsParts.length > 1 ? detailsParts[1] : '';

            IconData weatherIcon;
            Color iconColor;

            if (weatherDesc.contains('rain')) {
              weatherIcon = Icons.water_drop;
              iconColor = Colors.blue;
            } else if (weatherDesc.contains('cloud')) {
              weatherIcon = Icons.cloud;
              iconColor = Colors.grey;
            } else if (weatherDesc.contains('clear')) {
              weatherIcon = Icons.wb_sunny;
              iconColor = Colors.amber;
            } else if (weatherDesc.contains('snow')) {
              weatherIcon = Icons.ac_unit;
              iconColor = Colors.lightBlue;
            } else if (weatherDesc.contains('storm') ||
                weatherDesc.contains('thunder')) {
              weatherIcon = Icons.thunderstorm;
              iconColor = Colors.deepPurple;
            } else {
              weatherIcon = Icons.cloud_queue;
              iconColor = Colors.lightBlue;
            }

            return AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeIn,
              child: AnimatedSlide(
                offset: Offset.zero,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                child: Container(
                  margin: EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 2,
                    shadowColor: Theme.of(context).shadowColor,
                    child: InkWell(
                      onTap: () {
                        // Add haptic feedback on tap
                        HapticFeedback.lightImpact();
                      },
                      borderRadius: BorderRadius.circular(12),
                      splashColor:
                          Theme.of(context).primaryColor.withOpacity(0.2),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              offset: Offset(0, 3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            AnimatedRotation(
                              turns: weatherIcon == Icons.wb_sunny ? 0.05 : 0,
                              duration: Duration(milliseconds: 2000),
                              child: Icon(
                                weatherIcon,
                                size: 40,
                                color: iconColor,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dateTime,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    weatherDesc,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              temperature,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: temperature.contains('-')
                                    ? Colors.blue
                                    : (temperature.isNotEmpty
                                        ? _getTemperatureColor(temperature)
                                        : null),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Helper method to safely parse temperature for coloring
  Color? _getTemperatureColor(String temp) {
    try {
      final tempValue = double.parse(temp.replaceAll('°C', '').trim());
      return tempValue > 30 ? Colors.red : null;
    } catch (e) {
      // If parsing fails for any reason, return null (default color)
      return null;
    }
  }

  Widget _buildAnimatedListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        // Add haptic feedback
        HapticFeedback.lightImpact();
        onTap();
      },
      trailing: Icon(Icons.chevron_right),
    );
  }
}

class TranslationButtons extends StatelessWidget {
  final Function(String) onTranslate;

  TranslationButtons({required this.onTranslate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Translate",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _buildTranslationButton(context, "hi", "Hindi", 1),
              _buildTranslationButton(context, "ta", "Tamil", 2),
              _buildTranslationButton(context, "te", "Telugu", 3),
              _buildTranslationButton(context, "kn", "Kannada", 4),
              _buildTranslationButton(context, "ml", "Malayalam", 5),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTranslationButton(
      BuildContext context, String langCode, String langName, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.selectionClick();
          onTranslate(langCode);
        },
        icon: Icon(Icons.translate, size: 18),
        label: Text(langName),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
    );
  }
}

class ChatbotScreen extends StatefulWidget {
  final bool isDarkMode;

  const ChatbotScreen({super.key, required this.isDarkMode});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _chatController = TextEditingController();
  String aiResponse = "";
  String translatedText = "";
  final translator = GoogleTranslator();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  List<Map<String, String>> _chatHistory = [];

  @override
  void initState() {
    super.initState();
    // Add initial welcome message
    _chatHistory.add({
      'role': 'bot',
      'message':
          'Hello! I am FarmBot, your agricultural assistant. How can I help you today?'
    });
  }

  Future<void> getAIResponse(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _chatHistory.add({'role': 'user', 'message': query});
    });

    _chatController.clear();
    _scrollToBottom();

    const String apiKey = "AIzaSyBUNSfwwIw5A-5Dq3jqWEcMEfNomO6o3pg";
    const String apiUrl =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "You are FarmBot, an agricultural assistant specialized in providing farming advice. Answer the following question: $query"
                }
              ]
            }
          ]
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          if (data['candidates'] != null && data['candidates'].isNotEmpty) {
            String responseText = data['candidates'][0]['content']['parts'][0]
                    ['text'] ??
                "I'm sorry, I couldn't generate a response. Please try again.";

            _chatHistory.add({'role': 'bot', 'message': responseText});
            aiResponse = responseText;
          } else {
            _chatHistory
                .add({'role': 'bot', 'message': 'No response text available.'});
            aiResponse = "No response text available.";
          }
        });
      } else {
        setState(() {
          String errorMsg =
              "Error: Unable to connect to the AI service. Please try again later.";
          _chatHistory.add({'role': 'bot', 'message': errorMsg});
          aiResponse = errorMsg;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        String errorMsg = "Error connecting to AI service: $e";
        _chatHistory.add({'role': 'bot', 'message': errorMsg});
        aiResponse = errorMsg;
      });
    }

    _scrollToBottom();
  }

  // Function to translate text
  Future<void> translateText(String targetLang) async {
    if (aiResponse.isEmpty) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final translation =
          await translator.translate(aiResponse, to: targetLang);
      setState(() {
        _isLoading = false;
        translatedText = translation.text;
        // Add translated response to chat
        _chatHistory.add({
          'role': 'bot',
          'message': translation.text,
          'isTranslation': 'true'
        });
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        translatedText = "Translation error: $e";
        _chatHistory.add({
          'role': 'bot',
          'message': "Translation error: $e",
          'isTranslation': 'true'
        });
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              height: 32,
              width: 32,
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/logo.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Icon(Icons.smart_toy, size: 24),
            SizedBox(width: 10),
            Text("FarmBot Assistant"),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _chatHistory.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isLoading && index == _chatHistory.length) {
                    return _buildLoadingBubble();
                  }

                  final chat = _chatHistory[index];
                  final bool isUser = chat['role'] == 'user';
                  final bool isTranslation = chat['isTranslation'] == 'true';

                  return _buildChatBubble(
                    message: chat['message'] ?? '',
                    isUser: isUser,
                    isTranslation: isTranslation,
                  );
                },
              ),
            ),
          ),
          Divider(height: 1),
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                if (aiResponse.isNotEmpty && translatedText.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: TranslationButtons(onTranslate: translateText),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        decoration: InputDecoration(
                          hintText: "Ask FarmBot something...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (text) {
                          if (!_isLoading) getAIResponse(text);
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: () {
                        if (!_isLoading) getAIResponse(_chatController.text);
                      },
                      child: Icon(Icons.send),
                      mini: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(
      {required String message,
      required bool isUser,
      bool isTranslation = false}) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 300),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(isUser ? 1 : -1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: ModalRoute.of(context)?.animation ??
              AnimationController(
                  vsync: const _DummyTickerProvider(), duration: Duration.zero),
          curve: Curves.easeOutCubic,
        )),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  backgroundColor: isTranslation
                      ? Theme.of(context).colorScheme.secondary.withOpacity(0.7)
                      : Theme.of(context).primaryColor,
                  child: Icon(
                    isTranslation ? Icons.translate : Icons.smart_toy,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Theme.of(context).primaryColor
                        : (isTranslation
                            ? Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.2)
                            : Theme.of(context).cardColor),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isUser ? 16 : 4),
                      topRight: Radius.circular(isUser ? 4 : 16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isUser
                                ? Theme.of(context).primaryColor
                                : Colors.grey)
                            .withOpacity(0.2),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isUser ? Colors.white : null,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              if (isUser) SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: Icon(Icons.smart_toy, color: Colors.white, size: 18),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: _buildTypingIndicator(),
                ),
                SizedBox(width: 8),
                Text("Thinking...", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 600),
          curve:
              Interval(index * 0.2, 0.6 + index * 0.2, curve: Curves.easeInOut),
          builder: (context, value, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 1),
              height: 6 * value,
              width: 6,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.6),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          },
        );
      }),
    );
  }
}

// Dummy ticker provider for animations
class _DummyTickerProvider extends TickerProvider {
  const _DummyTickerProvider();

  @override
  Ticker createTicker(onTick) => Ticker(onTick);
}

class CropDetailScreen extends StatefulWidget {
  final String crop;
  final String imageUrl;
  final Map<String, String> details;

  const CropDetailScreen({
    super.key,
    required this.crop,
    required this.imageUrl,
    required this.details,
  });

  @override
  _CropDetailScreenState createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  String translatedText = "";
  final translator = GoogleTranslator(); // Online Translator

  // Function to translate text
  Future<void> translateText(String text, String targetLang) async {
    if (text.isEmpty) return;
    final translation = await translator.translate(text, to: targetLang);
    setState(() {
      translatedText = translation.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'crop_image_${widget.crop}',
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(widget.imageUrl),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    foregroundDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: [0.7, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Text(
                            widget.crop,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 2,
                                  color: Colors.black,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSectionAnimated(
                      'Description', widget.details['description'] ?? '',
                      delayFactor: 1),
                  _buildDetailSectionAnimated(
                      'Planting', widget.details['planting'] ?? '',
                      delayFactor: 2),
                  _buildDetailSectionAnimated(
                      'Care', widget.details['care'] ?? '',
                      delayFactor: 3),
                  _buildDetailSectionAnimated(
                      'Harvesting', widget.details['harvesting'] ?? '',
                      delayFactor: 4),
                  _buildDetailSectionAnimated(
                      'Pests & Diseases', widget.details['pests'] ?? '',
                      delayFactor: 5),
                  SizedBox(height: 20),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: TranslationButtons(
                              onTranslate: (lang) => translateText(
                                  widget.details['description'] ?? '', lang)),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    transform: Matrix4.translationValues(0, 0, 0),
                    child: Text(
                      translatedText,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSectionAnimated(String title, String content,
      {required int delayFactor}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (delayFactor * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: _buildDetailSection(title, content),
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(4),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Need Help with Your Farming?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Our development team is here to support you',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Development Team'),
                  _buildDeveloperCard(
                    context,
                    name: 'Abhilipsa Sahoo',
                    role: 'UI/UX Developer',
                    imageUrl: '',
                  ),
                  _buildDeveloperCard(
                    context,
                    name: 'Sumati Paliwal',
                    role: 'Frontend Developer',
                    imageUrl: '',
                  ),
                  _buildDeveloperCard(
                    context,
                    name: 'Aaditya Tiwary',
                    role: 'Backend Developer',
                    imageUrl: '',
                  ),
                  SizedBox(height: 24),
                  _buildSectionTitle(context, 'App Information'),
                  _buildInfoCard(
                    context,
                    title: 'Version',
                    content: '1.0.0',
                    icon: Icons.info,
                  ),
                  _buildInfoCard(
                    context,
                    title: 'Last Updated',
                    content: 'Today',
                    icon: Icons.update,
                  ),
                  _buildInfoCard(
                    context,
                    title: 'Logo',
                    content: 'KrishiMitra Branding Team',
                    icon: Icons.image,
                  ),
                  SizedBox(height: 24),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Feedback',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'We appreciate your feedback to improve our application. Please share your experience with us.',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Feedback action
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Feedback feature coming soon!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: Icon(Icons.feedback),
                            label: Text('Send Feedback'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildDeveloperCard(
    BuildContext context, {
    required String name,
    required String role,
    required String imageUrl,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(imageUrl),
          radius: 25,
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(role),
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 28,
        ),
        title: Text(title),
        subtitle: Text(
          content,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    );
  }
}
