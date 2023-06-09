part of option;

/// Represents an error thrown by a mishandled [Option] type value
class OptionError extends Error {
	final dynamic message;

	OptionError([this.message]);

	@override
	String toString() => switch (message) {
		null => 'OptionError',
		_ => 'OptionError: $message'
	};
}
