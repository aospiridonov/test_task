import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:test_task/bloc/state.dart';
import 'package:test_task/repository/repository_implementation.dart';

import 'bloc/bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 56),
          child: BlocProvider<LoginBloc>(create: (_) => LoginBloc(MockLoginRepositoryImplementation()), child: const LoginForm()),
        ),
      );
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final phoneController = TextEditingController();
  final pinController = TextEditingController();

  static const pinLength = 4;

  @override
  void initState() {
    pinController.addListener(() {
      if (pinController.text.length == pinLength) {
        onPinEntered();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  //TODO show errors in any appropriate way (with dialog or as a red color text under the input field or any other way)

  void onPhoneSubmitted() {
    //TODO add action
  }

  void onPinEntered() {
    //TODO add action
  }

  void reenterPhone() {
    //TODO add action
  }

  @override
  Widget build(BuildContext context) {
    const pinPutDecoration = BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.black, width: 2),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(flex: 2),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
            //TODO show progress when state.isLoading is true
            final columnChildren = <Widget>[];
            if (state is PhoneInputState) {
              columnChildren.addAll([
                const Text('Please enter your phone number'),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 20),
                  child: TextField(
                    controller: phoneController,
                    onSubmitted: (_) => onPhoneSubmitted(),
                  ),
                ),
                ElevatedButton(
                  onPressed: onPhoneSubmitted,
                  child: const Text('Continue'),
                ),
              ]);
            } else if (state is SmsRequestedState) {
              columnChildren.addAll([
                Text('The code was sent to ${state.phone}'),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 20),
                  child: PinPut(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    fieldsCount: pinLength,
                    pinAnimationType: PinAnimationType.fade,
                    textStyle: const TextStyle(fontSize: 25.0, color: Colors.black),
                    fieldsAlignment: MainAxisAlignment.spaceEvenly,
                    separator: const SizedBox(width: 19),
                    separatorPositions: const [1, 2, 3],
                    withCursor: true,
                    submittedFieldDecoration: pinPutDecoration,
                    selectedFieldDecoration: pinPutDecoration,
                    followingFieldDecoration: pinPutDecoration,
                  ),
                ),
                ElevatedButton(
                  onPressed: onPhoneSubmitted,
                  child: const Text('Continue'),
                ),
                TextButton(onPressed: reenterPhone, child: const Text('Change phone')),
              ]);
            } else {
              columnChildren.add(const Text('Success'));
            }
            return Column(
              children: columnChildren,
              crossAxisAlignment: CrossAxisAlignment.start,
            );
          }),
        ),
        const Spacer(flex: 3),
      ],
    );
  }
}
