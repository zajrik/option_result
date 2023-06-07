part of result_option;

/// Compares the runtime types of the given objects.
bool _compareRuntimeTypes(Object a, Object b) => a.runtimeType.hashCode == b.runtimeType.hashCode;
