.pragma library

function resolveInclude(path, home) {
    if (path.startsWith("~/"))
        return home + path.slice(1);
    if (path.startsWith("/"))
        return path;
    return home + "/.ssh/" + path;
}

// Include inside a Host/Match block is conditional in ssh; for listing aliases it's treated as unconditional.
function parse(text, home) {
    const hosts = [];
    const includes = [];
    let current = [];
    for (const raw of text.split("\n")) {
        const line = raw.replace(/#.*/, "").trim();
        const m = line.match(/^(\S+?)\s*[=\s]\s*(.+)$/);
        if (!m)
            continue;
        const key = m[1].toLowerCase();
        const value = m[2].trim();
        if (key === "include") {
            includes.push(...value.split(/\s+/).map(p => resolveInclude(p, home)));
            continue;
        }
        if (key === "match") {
            current = [];
            continue;
        }
        if (key === "host") {
            current = value.split(/\s+/).filter(a => !/[*?!"]/.test(a) && !a.startsWith("-")).map(alias => ({ alias: alias, hostname: "", user: "" }));
            hosts.push(...current);
            continue;
        }
        for (const h of current) {
            if (key === "hostname" && !h.hostname)
                h.hostname = value;
            else if (key === "user" && !h.user)
                h.user = value;
        }
    }
    return { hosts: hosts, includes: includes };
}
