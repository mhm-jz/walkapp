import 'package:flutter_test/flutter_test.dart';
import 'package:walkingapp/features/step_counter/service/final_snapshot_persistence.dart';

void main() {
  test('stop followed by destroy performs final persistence once', () async {
    final persistence = FinalSnapshotPersistence();
    var writes = 0;

    Future<void> writeFinalSnapshot() async {
      writes++;
    }

    await persistence.run(writeFinalSnapshot); // explicit stop
    await persistence.run(writeFinalSnapshot); // onDestroy

    expect(writes, 1);
    expect(persistence.hasStarted, isTrue);
  });
}
