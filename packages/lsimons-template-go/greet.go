// Package greet is the Go implementation of the shared greet library.
package greet

import "errors"

// ErrEmptyName is returned by Greet when name is empty.
var ErrEmptyName = errors.New("name must not be empty")

// Greet returns "hello, <name>".
func Greet(name string) (string, error) {
	if name == "" {
		return "", ErrEmptyName
	}
	return "hello, " + name, nil
}
