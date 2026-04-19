import pytest

from lsimons_template import greet


def test_greet_returns_greeting() -> None:
    assert greet("world") == "hello, world"


def test_greet_rejects_empty() -> None:
    with pytest.raises(ValueError, match="name must not be empty"):
        greet("")
