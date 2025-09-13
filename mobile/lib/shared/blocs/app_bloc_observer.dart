import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class AppBlocObserver extends BlocObserver {
  final Logger _logger = Logger();

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    _logger.d('BLoC Created: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    _logger.d('BLoC Event: ${bloc.runtimeType} - $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    _logger.d('BLoC Change: ${bloc.runtimeType} - $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    _logger.d('BLoC Transition: ${bloc.runtimeType} - $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _logger.e('BLoC Error: ${bloc.runtimeType}', error: error, stackTrace: stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    _logger.d('BLoC Closed: ${bloc.runtimeType}');
  }
}