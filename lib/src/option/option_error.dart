part of option;

/// Represents an error thrown by a mishandled [Option] type value.
final class OptionError extends Error {
	/// The message this `OptionError` was created with.
	final dynamic message;

	/// Whether or not this `OptionError` was thrown by [Option.expect()].
	final bool isExpected;

	OptionError(this.message, {this.isExpected = false});

	@override
	String toString() => switch (message) {
		null => 'OptionError',
		_ => 'OptionError: $message'
	};
}
