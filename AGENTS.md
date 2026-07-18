# WalkApp project rules

* Preserve all existing step counting, Pedometer, Activity Recognition, Foreground Service, validation buckets, Hive persistence, Start/Stop, background execution, and service-to-UI behavior.
* Keep business logic outside presentation widgets.
* Follow the existing architecture, state management, naming, and folder conventions.
* Use Material 3, centralized themes, design tokens, and reusable components.
* UI widgets must not subscribe directly to sensors or access the Foreground Service.
* Do not create, modify, delete, or run tests.
* Do not add dependencies unless necessary.
* After changes run only:

    * dart format lib
    * flutter analyze
