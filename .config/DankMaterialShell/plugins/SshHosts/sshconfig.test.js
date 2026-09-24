// node sshconfig.test.js
const fs = require("fs");
const assert = require("assert");
eval(fs.readFileSync(__dirname + "/sshconfig.js", "utf8").replace(".pragma library", ""));

const res = parse(`
# comment
Include config.d/*.conf ~/extra/ssh.conf
Host github
    HostName github.com
    User git
Host laptop lap2   # two aliases
    HostName 192.168.31.26
    User senshu_
    User ignored
Host *.internal !bad prod-? "q x"
    User wildcard
Host=eqsyntax
    HostName=10.0.0.1
    include=/abs/path.conf
Match host foo
    User nope
`, "/home/u");
assert.deepStrictEqual(res.hosts, [
    { alias: "github", hostname: "github.com", user: "git" },
    { alias: "laptop", hostname: "192.168.31.26", user: "senshu_" },
    { alias: "lap2", hostname: "192.168.31.26", user: "senshu_" },
    { alias: "eqsyntax", hostname: "10.0.0.1", user: "" },
]);
assert.deepStrictEqual(res.includes, ["/home/u/.ssh/config.d/*.conf", "/home/u/extra/ssh.conf", "/abs/path.conf"]);
console.log("ok");
