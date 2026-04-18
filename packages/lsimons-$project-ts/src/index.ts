export function greet(name: string): string {
    if (name.length === 0) {
        throw new Error("name must not be empty");
    }
    return `hello, ${name}`;
}
