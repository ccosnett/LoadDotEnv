# LoadDotEnv — Functional Specification

## Overview

`LoadDotEnv` is a Mathematica function (`.wl`) that reads a `.env` file and loads the key-value pairs into the process environment, making them accessible via Mathematica's `Environment["KEY"]` built-in. It closely follows the behaviour of [python-dotenv](https://github.com/theskumar/python-dotenv).

---

## Functions

### `LoadDotEnv[]`

Finds the nearest `.env` file (searching upward from `Directory[]`) and loads its contents into the process environment via `SetEnvironment`.

Returns `True` if a file was found and loaded, `False` if no file was found.

By default, does **not** override variables that are already set in the environment.

### `LoadDotEnv[path]`

Loads the `.env` file at the given path. Returns `False` silently if the file does not exist.

### `LoadDotEnv[path, "Override" -> True]`

Loads the file and overwrites any existing environment variables that share the same key.

### `DotEnvValues[]` / `DotEnvValues[path]`

Parses the `.env` file and returns an `Association` of key-value pairs **without** modifying the process environment. Useful for reading configuration without side-effects.

---

## .env File Format

The `.env` file is a plain-text file with one key-value pair per line.

### Basic syntax

```
KEY=value
```

### Comments

Lines beginning with `#` are comments and are ignored. Inline comments (after a value) are also stripped for unquoted and double-quoted values.

```
# This is a comment
KEY=value  # this part is ignored
```

### Blank lines

Blank lines are ignored.

### `export` prefix

An optional `export` prefix is accepted and ignored, for shell compatibility.

```
export KEY=value
```

### Quoting

Three quoting styles are supported:

| Style | Example | Behaviour |
|---|---|---|
| Unquoted | `KEY=hello world` | Leading/trailing whitespace trimmed; inline `#` comments stripped |
| Double-quoted | `KEY="hello world"` | Escape sequences processed (`\n`, `\t`, `\\`, `\"`); inline `#` comments stripped |
| Single-quoted | `KEY='hello world'` | Value taken literally; no escape processing; no inline comments |

### Escape sequences (double-quoted values only)

| Sequence | Meaning |
|---|---|
| `\n` | newline |
| `\t` | tab |
| `\\` | literal backslash |
| `\"` | literal double-quote |

### Multi-line values

Multi-line values are supported inside double quotes:

```
KEY="line one
line two"
```

### Variable expansion

Variable references of the form `$VAR` or `${VAR}` are expanded using the **current process environment** (not other values in the same file). Expansion applies to unquoted and double-quoted values. Single-quoted values are never expanded.

```
BASE=/home/user
PATH=$BASE/bin   # expands to /home/user/bin
```

To include a literal `$`, escape it: `\$`.

---

## File Discovery

When no path is supplied, `LoadDotEnv` walks upward from `Directory[]` until it finds a `.env` file or reaches the filesystem root. If no file is found, the function returns `False` without error.

---

## Encoding

Files are read as UTF-8. A UTF-8 BOM at the start of the file is silently stripped.

---

## Error Handling

- Missing file: returns `False`, no exception.
- Malformed lines (lines that do not match `KEY=VALUE` syntax): silently skipped.
- Duplicate keys: last value wins (consistent with python-dotenv behaviour).

---

## Security Considerations

- `.env` files should never be committed to version control. Add `.env` to `.gitignore`.
- `LoadDotEnv` does not validate or sanitise values; consumers are responsible for validating any value they use.
- Do not store highly sensitive secrets (private keys, payment credentials) in `.env` files on shared systems.
- See [dotenv.org security guidance](https://www.dotenv.org/docs/security/env.html) for further recommendations.

---

## Non-Goals

- No support for multiple named environments (e.g. `.env.production`).
- No file watching or automatic reload.
- No value type coercion or schema validation.
- No encryption of `.env` files.
