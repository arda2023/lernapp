// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(libraryTree)
final libraryTreeProvider = LibraryTreeProvider._();

final class LibraryTreeProvider
    extends $FunctionalProvider<LibraryTree?, LibraryTree?, LibraryTree?>
    with $Provider<LibraryTree?> {
  LibraryTreeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryTreeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryTreeHash();

  @$internal
  @override
  $ProviderElement<LibraryTree?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LibraryTree? create(Ref ref) {
    return libraryTree(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LibraryTree? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LibraryTree?>(value),
    );
  }
}

String _$libraryTreeHash() => r'e1b38bff141fc1555ff9f4808016a9dca991482f';

/// Id of the row currently highlighted in the sidebar (folder or document).
///
/// keepAlive: without it this is autoDispose, and setting it right after
/// creating the very first root item (before any row exists to watch it)
/// gets silently reset once the write's listener-free moment disposes it.

@ProviderFor(SelectedItemId)
final selectedItemIdProvider = SelectedItemIdProvider._();

/// Id of the row currently highlighted in the sidebar (folder or document).
///
/// keepAlive: without it this is autoDispose, and setting it right after
/// creating the very first root item (before any row exists to watch it)
/// gets silently reset once the write's listener-free moment disposes it.
final class SelectedItemIdProvider
    extends $NotifierProvider<SelectedItemId, String?> {
  /// Id of the row currently highlighted in the sidebar (folder or document).
  ///
  /// keepAlive: without it this is autoDispose, and setting it right after
  /// creating the very first root item (before any row exists to watch it)
  /// gets silently reset once the write's listener-free moment disposes it.
  SelectedItemIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedItemIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedItemIdHash();

  @$internal
  @override
  SelectedItemId create() => SelectedItemId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedItemIdHash() => r'7cee385b1b9379d8d71bc0cbc9f2dff9d795d91f';

/// Id of the row currently highlighted in the sidebar (folder or document).
///
/// keepAlive: without it this is autoDispose, and setting it right after
/// creating the very first root item (before any row exists to watch it)
/// gets silently reset once the write's listener-free moment disposes it.

abstract class _$SelectedItemId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Id of the row currently showing its inline rename text field. See
/// [SelectedItemId] for why this must be keepAlive too.

@ProviderFor(EditingItemId)
final editingItemIdProvider = EditingItemIdProvider._();

/// Id of the row currently showing its inline rename text field. See
/// [SelectedItemId] for why this must be keepAlive too.
final class EditingItemIdProvider
    extends $NotifierProvider<EditingItemId, String?> {
  /// Id of the row currently showing its inline rename text field. See
  /// [SelectedItemId] for why this must be keepAlive too.
  EditingItemIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'editingItemIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$editingItemIdHash();

  @$internal
  @override
  EditingItemId create() => EditingItemId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$editingItemIdHash() => r'c6901dd8792ea1ae0f110efa7c79ca88411d0426';

/// Id of the row currently showing its inline rename text field. See
/// [SelectedItemId] for why this must be keepAlive too.

abstract class _$EditingItemId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
