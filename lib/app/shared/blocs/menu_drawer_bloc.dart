import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ts_controle_ponto/app/shared/components/zoom_scaffold.dart';

class MenuDrawerBloc extends BlocBase {
  final BehaviorSubject<MenuState> _state = BehaviorSubject<MenuState>();

  // Streams
  Stream<MenuState> get googleAccount => _state.stream;

  state(MenuState state) {
    _state.sink.add(state);
  }

  @override
  void dispose() {
    _state.close();
    super.dispose();
  }
}
