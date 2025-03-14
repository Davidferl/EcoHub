import 'package:amc_2024/src/application/auth_service.dart';
import 'package:amc_2024/src/infra/account/user_repo.dart';
import 'package:amc_2024/src/infra/http_client.dart';
import 'package:amc_2024/src/theme/colors.dart';
import 'package:amc_2024/src/view/widgets/card_carbon.dart';
import 'package:amc_2024/src/view/widgets/card_summary.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../injection_container.dart';
import '../widgets/card_tip.dart';

class Home extends HookWidget {
  const Home({super.key});

  String getAqiText(int aqi) {
    if (aqi < 100) {
      return "Good";
    } else if (aqi < 200) {
      return "Moderate";
    }
    return "Unhealthy";
  }

  String getAqiRange(int aqi) {
    if (aqi < 100) {
      return "1-100";
    } else if (aqi < 200) {
      return "101-200";
    }
    return "200+";
  }

  @override
  Widget build(BuildContext context) {
    final name = useState("");
    final airPollution = useState(0);
    final temperature = useState(0);
    final weatherCondition = useState("");

    var apiKey = dotenv.env['WEATHER_API_KEY']!;
    Future<void> fetchWeatherData(double lat, double lon) async {
      final apiUrl =
          "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey";

      HttpClientImpl client = HttpClientImpl(locator());
      await client.get(Uri.parse(apiUrl).toString(), "").then((value) => {
            temperature.value = (value.data["main"]["temp"] - 273.15).toInt(),
            weatherCondition.value = value.data["weather"][0]["main"]
          });
    }

    Future<void> fetchAirPollutionData(double lat, double lon) async {
      final apiUrl =
          "http://api.openweathermap.org/data/2.5/air_pollution/forecast?lat=$lat&lon=$lon&appid=$apiKey";

      HttpClientImpl client = HttpClientImpl(locator());
      await client.get(Uri.parse(apiUrl).toString(), "").then(
          (value) => airPollution.value = value.data["list"][0]["main"]["aqi"]);
    }

    useEffect(() {
      Future<void> getUserName() async {
        final AuthService authService = locator<AuthService>();
        final UserRepository userRepository = locator<UserRepository>();

        final userId = authService.currentUser!.uid;
        final userInfo = await userRepository.getUser(userId);
        name.value = userInfo.name;
      }

      getUserName();
      return () {};
    }, []);

    useEffect(() {
      Future<void> requestNotificationPermissions() async {
        NotificationSettings settings =
            await FirebaseMessaging.instance.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        print('User granted permission: ${settings.authorizationStatus}');
      }

      Future<void> getCurrentLocation() async {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        await fetchWeatherData(position.latitude, position.longitude);
        await fetchAirPollutionData(position.latitude, position.longitude);
      }

      getCurrentLocation();

      requestNotificationPermissions();
      return () {};
    }, []);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${AppLocalizations.of(context)!.hello} ${name.value} !",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: kcPrimaryVariant,
                    ),
              ),
            ),
            const CardCarbon(score: 341),
            SizedBox(
              height: 125, // Set the height as needed
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  CardTip(
                    topIcon: Icons.whatshot,
                    descriptionText: AppLocalizations.of(context)!.slack_text,
                    titleText: AppLocalizations.of(context)!.slack_title,
                  ),
                  CardTip(
                    topIcon: Icons.house,
                    descriptionText: AppLocalizations.of(context)!.heating_text,
                    titleText: AppLocalizations.of(context)!.heating_title,
                  ),
                  CardTip(
                    topIcon: Icons.car_crash,
                    descriptionText: AppLocalizations.of(context)!.bus_text,
                    titleText: AppLocalizations.of(context)!.bus_title,
                  ),
                  CardTip(
                    topIcon: Icons.attach_money,
                    descriptionText: AppLocalizations.of(context)!.savings_text,
                    titleText: AppLocalizations.of(context)!.savings_title,
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.quick_look,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CardSummary(
                    topIcon: Icons.device_thermostat,
                    titleText: '${temperature.value}°C',
                    descriptionText: weatherCondition.value,
                    categoryText: "Temp."),
                CardSummary(
                    topIcon: Icons.electric_bolt,
                    titleText: '757',
                    descriptionText: "Wh",
                    categoryText: AppLocalizations.of(context)!.consumption),
                CardSummary(
                    topIcon: Icons.air,
                    titleText: getAqiRange(airPollution.value),
                    descriptionText: getAqiText(airPollution.value),
                    categoryText: AppLocalizations.of(context)!.air),
              ],
            )
          ],
        ),
      ),
    );
  }
}
