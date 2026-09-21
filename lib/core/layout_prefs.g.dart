// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layout_prefs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(layoutPrefs)
final layoutPrefsProvider = LayoutPrefsProvider._();

final class LayoutPrefsProvider
    extends $FunctionalProvider<LayoutPrefs, LayoutPrefs, LayoutPrefs>
    with $Provider<LayoutPrefs> {
  LayoutPrefsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'layoutPrefsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$layoutPrefsHash();

  @$internal
  @override
  $ProviderElement<LayoutPrefs> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LayoutPrefs create(Ref ref) {
    return layoutPrefs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LayoutPrefs value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LayoutPrefs>(value),
    );
  }
}

String _$layoutPrefsHash() => r'2edf6ab139234153557e235ee7aff7c71e9d9928';
