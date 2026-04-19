"""Core library logic. Kept separate from any CLI so it is reusable."""


def greet(name: str) -> str:
    """Return ``hello, {name}``. Raises ``ValueError`` if ``name`` is empty."""
    if not name:
        raise ValueError("name must not be empty")
    return f"hello, {name}"
