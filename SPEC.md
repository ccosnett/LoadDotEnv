# LoadDotEnv — Functional Specification

## Overview

LoadDotEnv is a Julia package for loading environment variables from `.env` files into the current process environment (`ENV`). It closely follows the behaviour of [python-dotenv](https://github.com/theskumar/python-dotenv) and the `.env` file conventions documented at [dotenv.org](https://www.dotenv.org/docs/security/env.html).

---

## File Format

### Basic syntax

A `.env` file contains one key-value pair per line:

```
KEY=VALUE
```

Rules:

- Keys and values are separated by `=`.
- Whitespace around the `=` is stripped.
- Keys must start with a letter or underscore, followed by letters, digits, or underscores (`[A-Za-z_][A-Za-z0-9_]*`).
- Lines that are empty or contain only whitespace are ignored.
- Lines whose first non-whitespace character is `#` are treated as comments and ignored.
- Inline comments (a `#` appearing after a value) are **not** supported unless the value is unquoted — in that case the `#` and everything after it is stripped.

### Export prefix

Lines may optionally begin with `export ` (matching shell syntax):

```
export KEY=VALUE
```

The `export` prefix is ignored during parsing; the key-value pair is treated the same as without it.

### Quoted values

Values may be wrapped in single (`'`) or double (`"`) quotes.

| Quote style | Behaviour |
|-------------|-----------|
| No quotes   | Leading and trailing whitespace is stripped. Inline `#` begins a comment. Variable expansion is **not** performed. |
| Double quotes `"…"` | Escape sequences are interpreted (`\n`, `\t`, `\\`, `\"`, `\r`). Variable expansion **is** performed (`$VAR`, `${VAR}`). Inline `#` is **not** treated as a comment. |
| Single quotes `'…'` | Content is treated literally — no escape sequences, no variable expansion. Inline `#` is **not** treated as a comment. |

### Multi-line values

Multi-line values are supported inside double or single quotes:

```
PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA...
-----END RSA PRIVATE KEY-----"
```

### Variable expansion

Inside double-quoted values, references to other variables are expanded:

- `$VAR` — expands to the current value of `VAR` in the environment or in previously parsed lines of the same file.
- `${VAR}` — same as above; braces are required when the variable name is followed immediately by alphanumeric characters.
- An undefined variable expands to an empty string.

Variable expansion is **not** performed in unquoted values or single-quoted values.

---

## Core Behaviour

### `load_dotenv`

```julia
load_dotenv(path=".env"; override=false, encoding="UTF-8") -> Bool
```

Reads the file at `path`, parses it, and for each key-value pair either sets or skips `ENV[key]`:

- If `override=false` (default): a key is only written to `ENV` if it is **not** already set. Existing environment variables are preserved.
- If `override=true`: every parsed key unconditionally overwrites any existing value in `ENV`.

Returns `true` if the file was found and loaded, `false` if the file does not exist (no error is raised for a missing file).

### `dotenv_values`

```julia
dotenv_values(path=".env"; encoding="UTF-8") -> Dict{String,String}
```

Parses the file at `path` and returns a `Dict` of the key-value pairs **without** modifying `ENV`. Useful for reading configuration without polluting the process environment.

### File discovery

When no `path` is given, LoadDotEnv searches for a `.env` file starting from the current working directory (`pwd()`) and walking up toward the filesystem root, stopping at the first `.env` file found. If no file is found, `load_dotenv` returns `false`.

---

## Encoding

- Files are read as UTF-8 by default.
- The `encoding` keyword argument accepts any encoding name accepted by Julia's standard I/O.
- A UTF-8 BOM at the start of the file is stripped if present.

---

## Error Handling

| Situation | Behaviour |
|-----------|-----------|
| File not found | `load_dotenv` returns `false`; no exception. |
| Malformed line (cannot be parsed) | The line is silently skipped; parsing continues. |
| Invalid key name | The line is silently skipped. |
| Unclosed quote | The remainder of the file (from the opening quote) is treated as the value. |

---

## Security Considerations

- `.env` files **must not** be committed to version control. A `.env` entry should be present in `.gitignore`.
- Secret values should be stored only in `.env` files and never hard-coded in source code.
- LoadDotEnv does not transmit values anywhere; it only writes to the in-process `ENV` dictionary.
- For production environments, prefer secrets management solutions (e.g. Vault, AWS Secrets Manager) over `.env` files.

---

## Non-Goals

- LoadDotEnv does not validate the semantic meaning of values.
- LoadDotEnv does not support multiple environment profiles (`.env.production`, `.env.test`, etc.) natively; callers pass the path explicitly.
- LoadDotEnv does not watch for file changes or reload automatically.

---

## Reference

- [dotenv.org — The .env File](https://www.dotenv.org/docs/security/env.html)
- [python-dotenv](https://github.com/theskumar/python-dotenv)
