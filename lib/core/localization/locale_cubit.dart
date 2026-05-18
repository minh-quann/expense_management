import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('vi')); // Mặc định tiếng Việt

  void toggleLanguage() {
    if (state.languageCode == 'vi') {
      emit(const Locale('en'));
    } else {
      emit(const Locale('vi'));
    }
  }
}
