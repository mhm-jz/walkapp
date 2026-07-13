# Walking App

An Android-first Flutter step counter using a foreground service, the hardware
pedometer stream, Activity Recognition, and confirmed-step persistence in Hive.

## Runtime diagnostics

The foreground service and Flutter UI emit stable `[STEP_*]` log tags. First
check every connected target:

```bash
adb devices
```

When more than one target is connected, always select the physical phone. For
the currently connected Samsung device:

```bash
adb -s "adb-RZCTB1BZ6WD-JCOVYK._adb-tls-connect._tcp." logcat -c

adb -s "adb-RZCTB1BZ6WD-JCOVYK._adb-tls-connect._tcp." logcat -v time \
  | grep "\[STEP_" \
  | tee step_counter_logs.txt
```

The reusable form is:

```bash
adb -s "<DEVICE_ID>" logcat -c

adb -s "<DEVICE_ID>" logcat -v time \
  | grep "\[STEP_" \
  | tee step_counter_logs.txt
```

If the filtered stream produces no output, use this broader fallback:

```bash
adb -s "<DEVICE_ID>" logcat -v time \
  | grep -iE "flutter|step|pedometer|activity|foreground"
```

For a single connected device, this shorter form also works:

```bash
adb logcat -c

adb logcat -v time \
  | grep "\[STEP_" \
  | tee step_counter_logs.txt
```

A normal walk should produce approximately this sequence:

```text
[STEP_ACTIVITY]
[STEP_SENSOR]
[STEP_ACTIVITY_APPLIED]
[STEP_SERVICE_SEND]
[STEP_UI_RECEIVE]
...
[STEP_TIMER_COMPLETE]
[STEP_VALIDATION]
[STEP_SERVICE_SEND]
[STEP_UI_RECEIVE]
```

Interpret delays by comparing adjacent timestamps:

- If `[STEP_SENSOR]` appears late, Android or the device is batching sensor
  delivery; the Flutter UI cannot make the event arrive earlier.
- If `[STEP_SENSOR]` is immediate but `[STEP_SERVICE_SEND]` is late, inspect the
  foreground handler.
- If `[STEP_SERVICE_SEND]` is immediate but `[STEP_UI_RECEIVE]` is late, inspect
  foreground-task isolate communication.
- If `[STEP_UI_RECEIVE]` is immediate but the number renders late, inspect the
  Flutter widget/rendering path.

Activity evidence is reusable for 30 seconds. `[STEP_ACTIVITY_STALE]` means the
last known activity was intentionally too old to validate a new step bucket.
