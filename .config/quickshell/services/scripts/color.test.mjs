// color.test.mjs — node .config/quickshell/services/scripts/color.test.mjs
import { createRequire } from "module"
const require = createRequire(import.meta.url)
const assert = require("assert")
const { isDark } = require("./color.js")

assert.strictEqual(isDark(1, 1, 1), false)     // white -> light, needs dark ink
assert.strictEqual(isDark(0, 0, 0), true)      // black -> dark, needs light ink
assert.strictEqual(isDark(1, 0, 0), true)      // pure red, luminance 0.299 <= 0.5
assert.strictEqual(isDark(1, 1, 0), false)     // yellow, luminance 0.886 > 0.5
assert.strictEqual(isDark(0.5, 0.5, 0.5), true) // mid-gray, luminance 0.5 <= 0.5 (boundary is dark)

console.log("color.test.mjs: all assertions passed")
