## 0.1.0-beta.3

- ci
  - add tests for flutter version 3.3.0 [\#85](https://github.com/LoveCommunity/flutter_scope/pull/85)
- refactor
  - update sdk constrain to "\>=2.18.0 \<4.0.0" [\#84](https://github.com/LoveCommunity/flutter_scope/pull/84)
- include changes made from dart\_scope 0.1.0-beta.4 [\#86](https://github.com/LoveCommunity/flutter_scope/pull/86)
  - feature 
    - export class `Observation` [\#195](https://github.com/LoveCommunity/dart_scope.dart/pull/195)

## 0.1.0-beta.2

- refactor 
  - add `StatesBuilder` child parameter [\#81](https://github.com/LoveCommunity/flutter_scope/pull/81)
- test
  - simplify test description [\#80](https://github.com/LoveCommunity/flutter_scope/pull/80)
- include changes made from dart\_scope 0.1.0-beta.3 [\#79](https://github.com/LoveCommunity/flutter_scope/pull/79)
  - feature
    - add configurables `Computed{4~9}` [\#192](https://github.com/LoveCommunity/dart_scope.dart/pull/192)
    - add operators `States.computed{4~9}` [\#191](https://github.com/LoveCommunity/dart_scope.dart/pull/191)
    - add operators `Observable.combine{4~9}` [\#190](https://github.com/LoveCommunity/dart_scope.dart/pull/190)
  - refactor
    - replace `States.combine` with `States.computed` [\#188](https://github.com/LoveCommunity/dart_scope.dart/pull/188)

## 0.1.0-beta.1

- feature 
  - add widget `StatesWidgetBase` [\#64](https://github.com/LoveCommunity/flutter_scope/pull/64)
- refactor 
  - remove unused type `FlutterEqual` [\#73](https://github.com/LoveCommunity/flutter_scope/pull/73)
  - reimplement widget `FlutterScope` [\#71](https://github.com/LoveCommunity/flutter_scope/pull/71)
  - add equality `configurableListEquality` [\#70](https://github.com/LoveCommunity/flutter_scope/pull/70)
  - add equality `RuntimeTypeEquality` [\#69](https://github.com/LoveCommunity/flutter_scope/pull/69)
  - reimplement widget `StatesListener` [\#66](https://github.com/LoveCommunity/flutter_scope/pull/66)
  - reimplement widget `StatesBuilder` [\#65](https://github.com/LoveCommunity/flutter_scope/pull/65)
  - remove unnecessary annotation `visibleForTesting` [\#63](https://github.com/LoveCommunity/flutter_scope/pull/63)
  - add equality `deepObservableEquality` [\#62](https://github.com/LoveCommunity/flutter_scope/pull/62)
  - add equality `InstanceAsObservableEquality` [\#61](https://github.com/LoveCommunity/flutter_scope/pull/61)
  - add equality `MultiSourcePipeObservableEquality` [\#60](https://github.com/LoveCommunity/flutter_scope/pull/60)
  - add equality `PipeObservableEquality` [\#59](https://github.com/LoveCommunity/flutter_scope/pull/59)
  - add equality `FallbackObservableEquality` [\#58](https://github.com/LoveCommunity/flutter_scope/pull/58)
  - migrate with `InstanceAsObservable` [\#56](https://github.com/LoveCommunity/flutter_scope/pull/56)
  - upgrade dart-sdk\(^2.18\) and dependencies [\#55](https://github.com/LoveCommunity/flutter_scope/pull/55)
- docs 
  - add api documentation [\#75](https://github.com/LoveCommunity/flutter_scope/pull/75)
  - add `README` [\#72](https://github.com/LoveCommunity/flutter_scope/pull/72)
- example 
  - adjust todo example according to readme [\#76](https://github.com/LoveCommunity/flutter_scope/pull/76)
  - migrate with new `States{Builder|Listener}` [\#67](https://github.com/LoveCommunity/flutter_scope/pull/67)
  - add `todo` example [\#52](https://github.com/LoveCommunity/flutter_scope/pull/52)
  - add `counter` example [\#50](https://github.com/LoveCommunity/flutter_scope/pull/50)
- include changes made from dart\_scope 0.1.0-beta.1 [\#53](https://github.com/LoveCommunity/flutter_scope/pull/53)
  - feature
    - add convenience methods `scope.getStates{orNull}` [\#182](https://github.com/LoveCommunity/dart_scope.dart/pull/182)
    - add observable `InstanceAsObservable` [\#181](https://github.com/LoveCommunity/dart_scope.dart/pull/181)
  - refactor
    - introduce observable `MultiSourcePipeObservable` [\#180](https://github.com/LoveCommunity/dart_scope.dart/pull/180)
    - introduce observable `PipeObservable` [\#179](https://github.com/LoveCommunity/dart_scope.dart/pull/179)
    - add `observation.configuration` field [\#178](https://github.com/LoveCommunity/dart_scope.dart/pull/178)
    - prefer `source` over `observable` to name input observable [\#177](https://github.com/LoveCommunity/dart_scope.dart/pull/177)
    - upgrade dart-sdk\(^2.18\) and dependencies [\#176](https://github.com/LoveCommunity/dart_scope.dart/pull/176)
    
## 0.1.0-alpha.2

- refactor 
  - rename `StatesXxxSelect` to `StatesXxxConvert` [\#45](https://github.com/LoveCommunity/flutter_scope/pull/45)
- include changes made from `dart_scope` 0.1.0-alpha.7 [\#44](https://github.com/LoveCommunity/flutter_scope/pull/44)
  - refactor 
    - rename operator `states.select` to `states.convert` [\#147](https://github.com/LoveCommunity/dart_scope.dart/pull/147)

## 0.1.0-alpha.1

- feature 
  - add widget `StatesListenerSelect` [\#33](https://github.com/LoveCommunity/flutter_scope/pull/33)
  - add `StatesListener.default` [\#32](https://github.com/LoveCommunity/flutter_scope/pull/32)
  - add widget `StatesListener` [\#31](https://github.com/LoveCommunity/flutter_scope/pull/31)
  - add widget `StatesBuilderSelect` [\#28](https://github.com/LoveCommunity/flutter_scope/pull/28)
  - add `StatesBuilder` default construct [\#25](https://github.com/LoveCommunity/flutter_scope/pull/25)
  - add method `context.scope` [\#23](https://github.com/LoveCommunity/flutter_scope/pull/23)
  - add  method `context.scopeOrNull` [\#22](https://github.com/LoveCommunity/flutter_scope/pull/22)
  - add method `FlutterScope.of` [\#21](https://github.com/LoveCommunity/flutter_scope/pull/21)
  - add widget `StatesBuilder` [\#19](https://github.com/LoveCommunity/flutter_scope/pull/19)
  - add `FlutterScope.async` [\#15](https://github.com/LoveCommunity/flutter_scope/pull/15)
  - add `FlutterScope` default construct `parentScope` parameter [\#14](https://github.com/LoveCommunity/flutter_scope/pull/14)
  - add `FlutterScope.using` [\#13](https://github.com/LoveCommunity/flutter_scope/pull/13)
  - add `FlutterScope` default construct [\#12](https://github.com/LoveCommunity/flutter_scope/pull/12)
  - add widget`FlutterScope` [\#11](https://github.com/LoveCommunity/flutter_scope/pull/11)
  - add configurable `FinalValueNotifier` [\#7](https://github.com/LoveCommunity/flutter_scope/pull/7)
  - add configurable `FinalChangeNotifier` [\#5](https://github.com/LoveCommunity/flutter_scope/pull/5)
- refactor 
  - make `FlutterScopeState` private [\#39](https://github.com/LoveCommunity/flutter_scope/pull/39)  
  - explicitly export `flutter_scope` [\#38](https://github.com/LoveCommunity/flutter_scope/pull/38)
  - upgrade `dart_scope` as ^0.1.0-alpha.5 [\#37](https://github.com/LoveCommunity/flutter_scope/pull/37)
  - improve `StatesBuilder` code readability [\#36](https://github.com/LoveCommunity/flutter_scope/pull/36)
  - improve test description [\#35](https://github.com/LoveCommunity/flutter_scope/pull/35)
  - add `experimental` annotation to `StatesListener` [\#34](https://github.com/LoveCommunity/flutter_scope/pull/34)
  - extract function `contextGetStates` [\#29](https://github.com/LoveCommunity/flutter_scope/pull/29)
  - add lints [\#27](https://github.com/LoveCommunity/flutter_scope/pull/27)
  - simplify implementation of `StatesBuilder` [\#24](https://github.com/LoveCommunity/flutter_scope/pull/24)
  - remove usage of `Completer.sync` in test [\#17](https://github.com/LoveCommunity/flutter_scope/pull/17)
  - upgrade dart\_scope as ^0.1.0-alpha.4 [\#16](https://github.com/LoveCommunity/flutter_scope/pull/16)
  - upgrade dart\_scope as ^0.1.0-alpha.3 [\#8](https://github.com/LoveCommunity/flutter_scope/pull/8)
  - merge `FinalChangeNotifier`, `LateFinalChangeNotifier`, `FinalChangeNotifierBase` into `FinalChangeNotifier [\#6](https://github.com/LoveCommunity/flutter_scope/pull/6)
  - add dependencies [\#4](https://github.com/LoveCommunity/flutter_scope/pull/4)
- fix 
  - fix typos [\#41](https://github.com/LoveCommunity/flutter_scope/pull/41)
- ci 
  - add ci tests [\#1](https://github.com/LoveCommunity/flutter_scope/pull/1)
- include changes made from `dart_scope` 0.1.0 alpha.6 [\#40](https://github.com/LoveCommunity/flutter_scope/pull/40)
  - refactor 
    - rename `ValueSubject` to `Variable` [\#143](https://github.com/LoveCommunity/dart_scope.dart/pull/143)
    - rename `ReplaySubject` to `Replayer` [\#142](https://github.com/LoveCommunity/dart_scope.dart/pull/142)
    - rename `PublishSubject` to `Publisher` [\#141](https://github.com/LoveCommunity/dart_scope.dart/pull/141)
    - rename `ScopeConfigure` to `ConfigureScope` [\#136](https://github.com/LoveCommunity/dart_scope.dart/pull/136)
    - rename `StatesConvertibleExpose` to `ExposeStatesConvertible` [\#135](https://github.com/LoveCommunity/dart_scope.dart/pull/135)
    - rename `ValueExpose` to `ExposeValue` [\#134](https://github.com/LoveCommunity/dart_scope.dart/pull/134)
    - rename `ValueDispose` to `DisposeValue` [\#133](https://github.com/LoveCommunity/dart_scope.dart/pull/133)
