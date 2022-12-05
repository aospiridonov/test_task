import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:test_task/bloc/event.dart';
import 'package:test_task/bloc/state.dart';
import 'package:test_task/repository/repository_implementation.dart';

import 'bloc/bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 56),
          child: BlocProvider<LoginBloc>(
              create: (_) => LoginBloc(MockLoginRepositoryImplementation()),
              child: const LoginForm()),
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
    phoneController.dispose();
    super.dispose();
  }

  void onPhoneSubmitted() {
    pinController.clear();
    context.read<LoginBloc>().add(PhoneEnteredEvent(phoneController.text));
  }

  void onPinEntered() {
    context.read<LoginBloc>().add(CheckEnteredCode(pinController.text));
  }

  void onReenterPhone() {
    context.read<LoginBloc>().add(ReenterPhoneEvent());
    pinController.clear();
  }

  void onResendSms() {
    context.read<LoginBloc>().add(ResendSmsEvent());
    pinController.clear();
  }

  @override
  Widget build(BuildContext context) {
    const defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(fontSize: 25.0, color: Colors.black),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 2),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(flex: 2),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final columnChildren = <Widget>[];
            if (state is PhoneInputState) {
              columnChildren.addAll([
                const Text('Please enter your phone number'),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 20),
                  child: TextField(
                    controller: phoneController,
                    onSubmitted: (_) => onPhoneSubmitted(),
                    decoration: InputDecoration(errorText: state.error),
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
                  child: Pinput(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    pinAnimationType: PinAnimationType.fade,
                    separator: const SizedBox(width: 19),
                    separatorPositions: const [1, 2, 3],
                    defaultPinTheme: defaultPinTheme,
                    errorText: state.error,
                    forceErrorState: (state.error != null),
                  ),
                ),
                if (state.error != null)
                  ElevatedButton(
                    onPressed: onResendSms,
                    child: const Text('Resend SMS'),
                  ),
                ElevatedButton(
                  onPressed: onPinEntered,
                  child: const Text('Continue'),
                ),
                TextButton(
                  onPressed: onReenterPhone,
                  child: const Text('Change phone'),
                ),
              ]);
            } else {
              columnChildren.addAll([
                const Text('Success'),
                TextButton(
                  onPressed: onReenterPhone,
                  child: const Text('Logout'),
                ),
              ]);
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
