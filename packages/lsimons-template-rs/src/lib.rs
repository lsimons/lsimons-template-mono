//! Library crate for `lsimons-template-rs`.

/// Error returned by [`greet`] when the input is invalid.
#[derive(Debug, PartialEq, Eq)]
pub struct EmptyNameError;

impl std::fmt::Display for EmptyNameError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str("name must not be empty")
    }
}

impl std::error::Error for EmptyNameError {}

/// Returns `hello, {name}`.
///
/// # Errors
///
/// Returns [`EmptyNameError`] if `name` is empty.
pub fn greet(name: &str) -> Result<String, EmptyNameError> {
    if name.is_empty() {
        return Err(EmptyNameError);
    }
    Ok(format!("hello, {name}"))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn greet_returns_greeting() {
        assert_eq!(greet("world").unwrap(), "hello, world");
    }

    #[test]
    fn greet_rejects_empty() {
        assert_eq!(greet(""), Err(EmptyNameError));
    }
}
