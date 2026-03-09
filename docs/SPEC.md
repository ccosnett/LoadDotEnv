# LoadDotEnv — Functional Specification

## Overview

`LoadDotEnv` is a Wolfram Language function that reads a `.env` file and returns its contents as a Wolfram `Association`. It is intended for loading secrets, API keys, and other configuration values into a Mathematica session without hardcoding them.

This document defines the expected behaviour of `LoadDotEnv`. It closely follows the behaviour of [python-dotenv](https://github.com/theskumar/python-dotenv) and the [.env file format](https://www.dotenv.org/docs/security/env.html).

---

## API

### `LoadDotEnv[]`

Reads the `.env` file in the current working directory (`Directory[]`) and returns its contents as an `Association` mapping string keys to string values.

```wolfram
LoadDotEnv[]
(* <| "API_KEY" -> "abc123", "DB_HOST" -> "localhost" |> *)
```

### `LoadDotEnv[path]`

Reads the `.env` file at the specified file path.

```wolfram
LoadDotEnv["/path/to/project/.env"]
(* <| "API_KEY" -> "abc123" |> *)
```

### Return value

- Returns an `Association` of string keys to string values.
- Returns an empty `Association` (`<||>`) if the file exists but contains no valid entries.
- Returns `$Failed` if the file cannot be read (e.g. permissions error).
- Returns `$Failed` and issues a message if the file does not exist.

---

## .env File Format

### Basic key-value pairs

Each line in a `.env` file is a key-value pair separated by `=`:

```
KEY=value
ANOTHER_KEY=another value
```

Keys are unquoted identifiers. Values extend to the end of the line.

### Comments

Lines beginning with `#` are comments and are ignored. Inline comments (after a value) are **not** supported — a `#` after a value is treated as part of the value.

```
# This is a comment
KEY=value   # this is NOT a comment — the value is "value   # this is NOT a comment"
```

### Whitespace

Leading and trailing whitespace around the key and around unquoted values is stripped:

```
  KEY  =  value
# key is "KEY", value is "value"
```

### The `export` prefix

Lines may optionally begin with `export `, which is ignored (for compatibility with shell scripts):

```
export API_KEY=abc123
# key is "API_KEY", value is "abc123"
```

### Quoted values

Values may be enclosed in double quotes or single quotes.

**Double-quoted values** support escape sequences:

| Sequence | Meaning        |
|----------|----------------|
| `\n`     | Newline        |
| `\r`     | Carriage return|
| `\t`     | Tab            |
| `\\`     | Backslash      |
| `\"`     | Double quote   |

```
GREETING="Hello\nWorld"
# value is "Hello" followed by a newline, then "World"
```

**Single-quoted values** are treated as literals — no escape processing is performed:

```
GREETING='Hello\nWorld'
# value is the literal string: Hello\nWorld
```

Quoted values may span multiple lines:

```
MULTI="line one
line two"
# value is "line one\nline two"
```

### Variable expansion

Variable expansion is supported inside unquoted and double-quoted values using `${VARIABLE}` syntax. The variable is looked up in the values already parsed in the current file.

```
BASE_URL=https://example.com
API_URL=${BASE_URL}/api
# API_URL is "https://example.com/api"
```

Variable expansion is **not** performed inside single-quoted values.

### Invalid lines

Lines that cannot be parsed (e.g. missing `=`, malformed quotes) are silently skipped. No exception or message is raised for individual bad lines.

---

## Behaviour Details

### File discovery

When called as `LoadDotEnv[]` (no argument), the function looks for `.env` in `Directory[]` (the current working directory). It does **not** walk up the directory tree.

### Existing environment variables

`LoadDotEnv` does **not** modify `$EnvironmentVariables` or call `SetEnvironment`. It only reads the file and returns an `Association`. The caller is responsible for deciding how to use the returned values.

Typical usage for loading an API key:

```wolfram
env = LoadDotEnv[];
apiKey = env["API_KEY"];
```

### Duplicate keys

If a key appears more than once in the file, the **last** occurrence wins.

### Encoding

The file is read as UTF-8. A UTF-8 BOM at the start of the file is stripped and ignored.

### Empty values

An empty value is valid:

```
KEY=
# value is ""
```

---

## Non-Goals

The following are explicitly out of scope:

- Setting process environment variables (`SetEnvironment`) — callers can do this themselves if needed.
- Multiple environment profiles (e.g. `.env.production`, `.env.test`).
- File watching or reloading on change.
- Value validation or type coercion — all values are strings.
- Walking up the directory tree to find a `.env` file.
