import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/features/stats/domain/repositories/stats_repository.dart';
import 'package:expense_management/features/stats/presentation/bloc/stats_event.dart';
import 'package:expense_management/features/stats/presentation/bloc/stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final StatsRepository statsRepository;

  StatsBloc({required this.statsRepository}) : super(StatsInitial()) {
    on<GetStats>(_onGetStats);
  }

  Future<void> _onGetStats(GetStats event, Emitter<StatsState> emit) async {
    emit(StatsLoading());
    try {
      final stats = await statsRepository.getStats(
        month: event.month,
        year: event.year,
        walletId: event.walletId,
      );
      emit(StatsLoaded(stats));
    } catch (e) {
      emit(StatsError(e.toString()));
    }
  }
}
