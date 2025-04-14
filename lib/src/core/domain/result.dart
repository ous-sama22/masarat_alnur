// Defines a generic result type
sealed class Result<T> {
  const Result();
}

// Success case holds the data
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data); // Use positional argument
}

// Failure case holds the exception
class Failure<T> extends Result<T> {
  final Exception exception;
  const Failure(this.exception); // Use positional argument
}