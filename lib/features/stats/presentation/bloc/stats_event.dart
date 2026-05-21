import 'package:equatable/equatable.dart';

abstract class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object?> get props => [];
}

class GetStats extends StatsEvent {
  final int? month;
  final int? year;
  final String? walletId;

  const GetStats({this.month, this.year, this.walletId});

  @override
  List<Object?> get props => [month, year, walletId];
}
