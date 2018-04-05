const apacheCreate = require("./apache-conf-create");

test('creates apache config', () => {
    let config = apacheCreate(["www.example.com", "example.com"]);
    expect(config).toMatch(/ServerName www.example.com/);
    expect(config).toMatch(/ServerAlias example.com/);
    expect(config).toMatch(/443/);
});
