import 'package:chaty_ai_agent/core/result/api_result.dart';
import 'package:chaty_ai_agent/features/profile/domain/entities/user_entity.dart';
import 'package:chaty_ai_agent/features/profile/domain/repositories/profile_repository.dart';
import 'package:chaty_ai_agent/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

const _tUser = UserEntity(
  name: 'Ada Lovelace',
  handle: 'ada',
  initials: 'AL',
  bio: '',
  location: '',
  company: '',
  joined: '',
  followers: 0,
  following: 0,
  publicRepos: 0,
  stars: 0,
);

void main() {
  late MockProfileRepository mockRepo;
  late GetProfileUseCase useCase;

  setUp(() {
    mockRepo = MockProfileRepository();
    useCase = GetProfileUseCase(mockRepo);
  });

  test('delegates call to repository', () async {
    when(() => mockRepo.getProfile())
        .thenAnswer((_) async => const ApiSuccess(_tUser));

    final result = await useCase();

    verify(() => mockRepo.getProfile()).called(1);
    expect(result, isA<ApiSuccess<UserEntity>>());
  });
}
