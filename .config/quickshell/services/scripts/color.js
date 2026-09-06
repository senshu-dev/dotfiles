// Pure color helpers, shared by Theme.qml and Node tests.
// r/g/b are floats in [0, 1] — matches QML's color.r/.g/.b directly, no
// hex round-tripping needed on the QML side.
function isDark(r, g, b) {
    return (r * 0.299 + g * 0.587 + b * 0.114) <= 0.5
}

if (typeof module !== "undefined") module.exports = { isDark }
