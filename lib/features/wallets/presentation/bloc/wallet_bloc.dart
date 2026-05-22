import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/features/wallets/domain/repositories/wallet_repository.dart';
import 'package:expense_management/features/wallets/domain/usecases/get_wallets_usecase.dart';
import 'package:expense_management/features/wallets/domain/usecases/add_wallet_usecase.dart';
import 'package:expense_management/features/wallets/domain/usecases/update_wallet_usecase.dart';
import 'package:expense_management/features/wallets/domain/usecases/delete_wallet_usecase.dart';
import 'package:expense_management/features/wallets/domain/usecases/toggle_favorite_wallet_usecase.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletsUseCase _getWalletsUseCase;
  final AddWalletUseCase _addWalletUseCase;
  final UpdateWalletUseCase _updateWalletUseCase;
  final DeleteWalletUseCase _deleteWalletUseCase;
  final ToggleFavoriteWalletUseCase _toggleFavoriteWalletUseCase;
  StreamSubscription? _walletSubscription;

  WalletBloc({
    required WalletRepository repository,
    GetWalletsUseCase? getWalletsUseCase,
    AddWalletUseCase? addWalletUseCase,
    UpdateWalletUseCase? updateWalletUseCase,
    DeleteWalletUseCase? deleteWalletUseCase,
    ToggleFavoriteWalletUseCase? toggleFavoriteWalletUseCase,
  })  : _getWalletsUseCase = getWalletsUseCase ?? GetWalletsUseCase(repository),
        _addWalletUseCase = addWalletUseCase ?? AddWalletUseCase(repository),
        _updateWalletUseCase = updateWalletUseCase ?? UpdateWalletUseCase(repository),
        _deleteWalletUseCase = deleteWalletUseCase ?? DeleteWalletUseCase(repository),
        _toggleFavoriteWalletUseCase = toggleFavoriteWalletUseCase ?? ToggleFavoriteWalletUseCase(repository),
        super(WalletInitial()) {
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
    _walletSubscription = _getWalletsUseCase(event.userId).listen((wallets) {
      add(WalletsUpdatedInternalEvent(wallets));
    }, onError: (error) {
      add(WalletsErrorInternalEvent(error.toString()));
    });
  }

  void _onAddWallet(AddWalletEvent event, Emitter<WalletState> emit) async {
    try {
      await _addWalletUseCase(event.wallet);
    } catch (e) {
      add(WalletsErrorInternalEvent(e.toString()));
    }
  }

  void _onUpdateWallet(UpdateWalletEvent event, Emitter<WalletState> emit) async {
    try {
      await _updateWalletUseCase(event.wallet);
    } catch (e) {
      add(WalletsErrorInternalEvent(e.toString()));
    }
  }

  void _onDeleteWallet(DeleteWalletEvent event, Emitter<WalletState> emit) async {
    try {
      await _deleteWalletUseCase(event.userId, event.walletId);
    } catch (e) {
      add(WalletsErrorInternalEvent(e.toString()));
    }
  }

  void _onToggleFavoriteWallet(ToggleFavoriteWalletEvent event, Emitter<WalletState> emit) async {
    try {
      await _toggleFavoriteWalletUseCase(event.userId, event.walletId);
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
