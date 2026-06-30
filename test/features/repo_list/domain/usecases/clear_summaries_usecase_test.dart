import 'package:chaty_ai_agent/features/repo_list/domain/repositories/repo_repository.dart';
import 'package:chaty_ai_agent/features/repo_list/domain/usecases/clear_summaries_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepoRepository extends Mock implements RepoRepository {}

void main() {
  late MockRepoRepository mockRepo;
  late ClearSummariesUseCase useCase;

  setUp(() {
    mockRepo = MockRepoRepository();
    useCase = ClearSummariesUseCase(mockRepo);
    when(() => mockRepo.clearSummaries()).thenAnswer((_) async {});
  });

  test('delegates call to RepoRepository.clearSummaries()', () async {
    await useCase();
    verify(() => mockRepo.clearSummaries()).called(1);
  });

  test('completes without error when repo succeeds', () async {
    await expectLater(useCase(), completes);
  });
}
