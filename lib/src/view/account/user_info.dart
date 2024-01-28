import 'dart:async';
import 'dart:convert';

import 'package:amc_2024/src/application/auth_service.dart';
import 'package:amc_2024/src/infra/account/profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../injection_container.dart';
import '../../../routes/routes.dart';
import '../../exceptions/exceptions.dart';
import '../widgets/error_dialog.dart';

class UserInfo extends HookWidget {
  const UserInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final cars = useState<List<String>>(List<String>.empty());
    final selectedCar = useState<String>("");
    final isLoading = useState(false);

    final nameController = useTextEditingController();
    final surnameController = useTextEditingController();
    final carMakeController = useTextEditingController();

    useEffect(() {
      Future<void> readJson() async {
        final String response =
            await rootBundle.loadString("assets/data/make_models.json");
        final Map<String, dynamic> data = await json.decode(response);
        cars.value = data.keys.toList();
      }
      readJson();
      return () {
      };
    }, const []);

    String? validateName(String? value) {
      if (value!.isEmpty) {
        return 'Can not be empty';
      }
      return null;
    }

    Future<void> submitInfo() async {
      final String name = nameController.text;
      final String surname = surnameController.text;
      final String car = carMakeController.text;

      print(name);
      print(surname);
      print(car);

      if (formKey.currentState!.validate()) {
        isLoading.value = true;
        try {
          isLoading.value = false;
          UserRepository profileRepository = locator<UserRepository>();
          AuthService authService = locator<AuthService>();
          final userId = authService.currentUser!.uid;
          await profileRepository.addUser(userId, name, surname, "1234");

          if (context.mounted) {
            Navigator.pushReplacementNamed(context, Routes.home.name);
          }
        } on FirestoreException catch (e) {
          isLoading.value = false;
          showDialog(
            context: context,
            builder: (BuildContext context) => ErrorDialog(
              title: "Oops",
              message: e.message,
              buttonText: "OK",
            ),
          );
        }
      }
    }

    return Scaffold(
      body: Center(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                child: Text(
                  "User Info",
                  style: TextStyle(fontSize: 24),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: nameController,
                    validator: validateName,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'First Name',
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: surnameController,
                    validator: validateName,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Last Name',
                    ),
                  ),
                ),
              ),
              const Center(
                child: Text("Enter your car model"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Autocomplete<String>(
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController carMakeController,
                      FocusNode fieldFocusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextFormField(
                      controller: carMakeController,
                      focusNode: fieldFocusNode,
                      validator: validateName,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Car Model',
                      ),
                    );
                  },
                  optionsBuilder: (TextEditingValue carTextEditingValue) {
                    return cars.value.where(
                      (String option) {
                        return option
                            .toLowerCase()
                            .contains(carTextEditingValue.text.toLowerCase());
                      },
                    );
                  },
                  onSelected: (String value) {
                    // debugPrint('You just selected $value');
                    // selectedCar.value = value;
                    // FocusScope.of(context).requestFocus(FocusNode());
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    child: ElevatedButton(
                      // ignore: avoid_print
                        onPressed: () => submitInfo(),
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            shape: const BeveledRectangleBorder()),
                        child: const Text("Continue"))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
