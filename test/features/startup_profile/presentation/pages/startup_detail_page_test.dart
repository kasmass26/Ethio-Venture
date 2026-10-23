import 'package:ethioventure/core/di/injection_container.dart';
import 'package:ethioventure/core/theme/app_theme.dart';
import 'package:ethioventure/features/pitch_deck/domain/entities/document_entity.dart';
import 'package:ethioventure/features/pitch_deck/domain/repositories/document_repository.dart';
import 'package:ethioventure/features/pitch_deck/domain/usecases/delete_document_use_case.dart';
import 'package:ethioventure/features/pitch_deck/domain/usecases/get_startup_documents_use_case.dart';
import 'package:ethioventure/features/pitch_deck/domain/usecases/toggle_document_visibility_use_case.dart';
import 'package:ethioventure/features/pitch_deck/domain/usecases/upload_document_use_case.dart';
import 'package:ethioventure/features/pitch_deck/presentation/cubit/document_cubit.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';
import 'package:ethioventure/features/startup_profile/presentation/pages/startup_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeDocumentRepository implements DocumentRepository {
  @override
  Future<void> deleteDocument({required String documentId, required String startupId}) async {}

  @override
  Future<List<DocumentEntity>> getStartupDocuments({required String startupId}) async => [];

  @override
  Future<DocumentEntity> toggleVisibility({required String documentId, required bool isPrivate}) async {
    throw UnimplementedError();
  }

  @override
  Future<DocumentEntity> uploadDocument({required String startupId, required String title, required String filePath, required String fileName, bool isPrivate = false}) async {
    throw UnimplementedError();
  }
}

void main() {
  setUp(() async {
    await sl.reset();
    sl.registerLazySingleton<DocumentRepository>(FakeDocumentRepository.new);
    sl.registerLazySingleton(() => UploadDocumentUseCase(sl()));
    sl.registerLazySingleton(() => GetStartupDocumentsUseCase(sl()));
    sl.registerLazySingleton(() => DeleteDocumentUseCase(sl()));
    sl.registerLazySingleton(() => ToggleDocumentVisibilityUseCase(sl()));
    sl.registerFactory<DocumentCubit>(() => DocumentCubit(
          uploadDocumentUseCase: sl(),
          getStartupDocumentsUseCase: sl(),
          deleteDocumentUseCase: sl(),
          toggleDocumentVisibilityUseCase: sl(),
        ),);
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('startup detail does not show an unverified status badge',
      (tester) async {
    final startup = StartupProfileEntity(
      id: 'startup-1',
      userId: 'user-1',
      startupName: 'Unknown Venture',
      description: 'A startup detail without verification data.',
      industry: 'Fintech',
      fundingStage: 'Seed',
      fundingAmountNeeded: 100000,
      location: 'Addis Ababa',
      teamInformation: 'Test team',
      contactInformation: 'contact@example.com',
      createdAt: DateTime(2026, 10, 23),
      updatedAt: DateTime(2026, 10, 23),
      approvalStatus: 'pending',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: StartupDetailPage(startup: startup),
      ),
    );
    await tester.pump();

    expect(find.text('Unknown Venture'), findsWidgets);
    expect(find.text('Fintech'), findsWidgets);
    expect(find.text('Seed'), findsWidgets);
    expect(find.text('Verified Profile'), findsNothing);
    expect(find.text('Verified Venture'), findsNothing);
  });
}
