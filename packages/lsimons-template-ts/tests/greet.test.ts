import { describe, expect, it } from "vitest";
import { greet } from "../src/index.ts";

describe("greet", () => {
    it("returns a greeting", () => {
        expect(greet("world")).toBe("hello, world");
    });

    it("throws on empty input", () => {
        expect(() => greet("")).toThrow(/name must not be empty/);
    });
});
