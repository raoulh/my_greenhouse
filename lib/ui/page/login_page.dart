import 'package:flutter/material.dart';
import 'package:my_greenhouse/services/auth_service.dart';
import 'dart:ui';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:my_greenhouse/ui/widgets/logo.dart';
import 'package:my_greenhouse/ui/background/background.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  ButtonState stateLoginButton = ButtonState.idle;

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  void onPressedLoginButton(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    switch (stateLoginButton) {
      case ButtonState.idle:
        setState(() {
          stateLoginButton = ButtonState.loading;
        });

        final auth = await authService.login(
            emailCtrl.text.trim(), passCtrl.text.trim());

        setState(() {
          stateLoginButton = auth ? ButtonState.success : ButtonState.fail;
        });

        if (auth) {
          Future.delayed(const Duration(milliseconds: 600), () {
            Navigator.pushReplacementNamed(context, '/dashboard');
            setState(() {
              stateLoginButton = ButtonState.idle;
            });
          });
        } else {
          Future.delayed(const Duration(milliseconds: 3000), () {
            setState(() {
              stateLoginButton = ButtonState.idle;
            });
          });
        }

        break;
      case ButtonState.loading:
        break;
      case ButtonState.success:
        break;
      case ButtonState.fail:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0x00FFFFFF),
      body: ScrollConfiguration(
        behavior: MyScrollBehavior(),
        child: SingleChildScrollView(
          child: SizedBox(
            height: size.height,
            child: Stack(
              children: [
                const Background(),
                Column(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.only(top: size.height * .1),
                        child: const Logo(),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          editComponent(Icons.account_circle_outlined,
                              'Email...', false, true, emailCtrl),
                          editComponent(Icons.lock_outline, 'Password...', true,
                              false, passCtrl),
                          ProgressButton.icon(
                              iconedButtons: {
                                ButtonState.idle: IconedButton(
                                    text: "Login",
                                    icon: const Icon(Icons.login,
                                        color: Colors.white),
                                    color: Colors.green.shade500),
                                ButtonState.loading: IconedButton(
                                    text: "Loading",
                                    color: Colors.green.shade700),
                                ButtonState.fail: IconedButton(
                                    text: "Failed",
                                    icon: const Icon(Icons.cancel,
                                        color: Colors.white),
                                    color: Colors.red.shade300),
                                ButtonState.success: IconedButton(
                                    text: "Success",
                                    icon: const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                    color: Colors.green.shade400)
                              },
                              onPressed: () {
                                onPressedLoginButton(context);
                              },
                              state: stateLoginButton),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget editComponent(IconData icon, String hintText, bool isPassword,
      bool isEmail, TextEditingController controller) {
    Size size = MediaQuery.of(context).size;
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaY: 15,
          sigmaX: 15,
        ),
        child: Container(
          height: size.width / 8,
          width: size.width / 1.2,
          alignment: Alignment.center,
          padding: EdgeInsets.only(right: size.width / 30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.05),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(color: Colors.white.withOpacity(.8)),
            cursorColor: Colors.white,
            obscureText: isPassword,
            keyboardType:
                isEmail ? TextInputType.emailAddress : TextInputType.text,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: Colors.white.withOpacity(.7),
              ),
              border: InputBorder.none,
              hintMaxLines: 1,
              hintText: hintText,
              hintStyle:
                  TextStyle(fontSize: 14, color: Colors.white.withOpacity(.5)),
            ),
          ),
        ),
      ),
    );
  }
}

class MyScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
