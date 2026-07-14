/// Lightweight stdout logging used by both Flutter's main isolate and the
/// foreground-task isolate. Flutter forwards stdout from either isolate to
/// Android Logcat in debug/profile runs.
void logStepDiagnostic(String message) {
  // Kept in one place so diagnostic logging can be disabled or redirected
  // without touching step-counting code.
  // ignore: avoid_print
  print(message);
}
