use assert_cmd::Command;
use predicates::str::contains;

#[test]
fn greets_named_arg() {
    Command::cargo_bin("lsimons-template-rs")
        .unwrap()
        .arg("Rust")
        .assert()
        .success()
        .stdout(contains("hello, Rust"));
}

#[test]
fn greets_default() {
    Command::cargo_bin("lsimons-template-rs")
        .unwrap()
        .assert()
        .success()
        .stdout(contains("hello, world"));
}

#[test]
fn rejects_empty_name() {
    Command::cargo_bin("lsimons-template-rs")
        .unwrap()
        .arg("")
        .assert()
        .failure()
        .stderr(contains("name must not be empty"));
}
