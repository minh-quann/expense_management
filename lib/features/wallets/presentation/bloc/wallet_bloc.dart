import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/features/wallets/domain/repositories/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository repository;
  StreamSubscription? _walletSubscription;

  WalletBloc({required this.repository}) : super(WalletInitial()) {
    on<LoadWalletsEvent>(_onLoadWallets);
    on<AddWalletEvent>(_onAddWallet);
    on<UpdateWalletEvent>(_onUpdateWallet);
    on<DeleteWalletEvent>(_onDeleteWallet);
    on<ToggleFavoriteWalletEvent>(_onToggleFavoriteWallet);
    on<WalletsUpdatedInternalEvent>((event, emit) => emit(WalletLoaded(event.wallets)));
    on<WalletsErrorInternalEvent>((event, emit) => emit(WalletError(event.error)));
  }

  void _onLoadWallets(LoadWalletsEvent event, Emitter<WalletState> emit) {
    emit(WalletLoading());
    _walletSubscription?.cancel();
    _walletSubscription = repository.getWallets(event.userId).listen((wallets) {
      add(WalletsUpdatedInternalEvent(wallets));
    }, onError: (error) {
      add(WalletsErrorInternalEvent(error.toString()));
    });
  }

  void _onAddWallet(AddWalletEvent event, Emitter<WalletState> emit) async {
    try {
      await repository.addWallet(event.wallet);
    } catch (e) {
      add(WalletsErrorInternalEvent(e.toString()));
    }
  }

  void _onUpdateWallet(UpdateWalletEvent event, Emitter<WalletState> emit) async {
    try {
      await repository.updateWallet(event.wallet);
    } catch (e) {
      add(WalletsErrorInternalEvent(e.toString()));
    }
  }

  void _onDeleteWallet(DeleteWalletEvent event, Emitter<WalletState> emit) async {
    try {
      await repository.deleteWalletForUser(event.userId, event.walletId);
    } catch (e) {
      add(WalletsErrorInternalEvent(e.toString()));
    }
  }

  void _onToggleFavoriteWallet(ToggleFavoriteWalletEvent event, Emitter<WalletState> emit) async {
    try {
      await repository.toggleFavoriteWallet(event.userId, event.walletId);
    } catch (e) {
      add(WalletsErrorInternalEvent(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _walletSubscription?.cancel();
    return super.close();
  }
}
