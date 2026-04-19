package greet

import (
	"errors"
	"testing"
)

func TestGreet(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name    string
		input   string
		want    string
		wantErr error
	}{
		{name: "happy path", input: "world", want: "hello, world"},
		{name: "empty input", input: "", wantErr: ErrEmptyName},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			got, err := Greet(tc.input)
			if !errors.Is(err, tc.wantErr) {
				t.Fatalf("Greet(%q) err = %v, want %v", tc.input, err, tc.wantErr)
			}
			if got != tc.want {
				t.Errorf("Greet(%q) = %q, want %q", tc.input, got, tc.want)
			}
		})
	}
}
