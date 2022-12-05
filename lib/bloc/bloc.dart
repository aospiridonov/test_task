import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_task/bloc/state.dart';
import 'package:test_task/repository/repository.dart';

import 'event.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this.repository) : super(const PhoneInputState()) {
    on<PhoneEnteredEvent>(_onPhoneEnteredEvent);
    on<ResendSmsEvent>(_onResendSmsEvent);
    on<ReenterPhoneEvent>(_onReenterPhoneEvent);
    on<CheckEnteredCode>(_onCheckEnteredCode);
  }

  final LoginRepository repository;
  String _phone = '';

  Future<void> _onPhoneEnteredEvent(
      PhoneEnteredEvent event, Emitter<LoginState> emit) async {
    emit(const LoginSuccessLoading());
    try {
      await repository.requestSms(event.phone);
      _phone = event.phone;
      emit(SmsRequestedState(_phone));
    } catch (error) {
      emit(PhoneInputState(error: error.toString()));
    }
  }

  Future<void> _onResendSmsEvent(
      ResendSmsEvent event, Emitter<LoginState> emit) async {
    emit(const LoginSuccessLoading());
    try {
      await repository.requestSms(_phone);
      emit(SmsRequestedState(_phone));
    } catch (error) {
      emit(SmsRequestedState(_phone, error: error.toString()));
    }
  }

  Future<void> _onReenterPhoneEvent(
      ReenterPhoneEvent event, Emitter<LoginState> emit) async {
    emit(const PhoneInputState(error: null));
  }

  Future<void> _onCheckEnteredCode(
      CheckEnteredCode event, Emitter<LoginState> emit) async {
    if (event.code.isEmpty) {
      emit(SmsRequestedState(_phone, error: 'Empty pin code'));
      return;
    }
    emit(const LoginSuccessLoading());
    try {
      await repository.checkCode(_phone, event.code);
      emit(const LoginSuccessState());
    } catch (error) {
      emit(SmsRequestedState(_phone, error: error.toString()));
    }
  }
}
