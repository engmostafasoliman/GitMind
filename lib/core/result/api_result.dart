sealed class ApiResult<T> {
  const ApiResult();
}

final class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

final class ApiFailure<T> extends ApiResult<T> {
  final String message;
  const ApiFailure(this.message);
}

/// Distinct from ApiFailure — signals a recoverable rate-limit (HTTP 429)
/// so callers can auto-retry with a countdown rather than surfacing an error.
final class ApiRateLimit<T> extends ApiResult<T> {
  const ApiRateLimit();
}
