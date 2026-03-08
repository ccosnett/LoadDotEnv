# LoadDotEnv

A Mathematica/Wolfram Language utility for loading `.env` files into your notebook session.

## Usage

### Loading

To use `LoadDotEnv`, load the file with `<<` (assumes `LoadDotEnv.wl` is in the same directory as your notebook):

```mathematica
<<LoadDotEnv.wl
```

### Running LoadDotEnv

Once loaded, call `LoadDotEnv[]` to read the `.env` file in the current working directory:

```mathematica
env = LoadDotEnv[]
```

This returns an `Association` of key-value pairs, e.g.:

```mathematica
<| "DATABASE_URL" -> "postgres://localhost/mydb", "API_KEY" -> "secret" |>
```

To load a `.env` file at a specific path:

```mathematica
env = LoadDotEnv["/path/to/project/.env"]
```

You can then access individual values with normal `Association` lookup:

```mathematica
env["API_KEY"]
```

### Viewing Documentation

After loading the file, call `?LoadDotEnv` to see the usage string:

```mathematica
?LoadDotEnv
```

## Limitations

This is a zeroth-order approximation. It handles:
- Unquoted `key=value` pairs
- Comment lines (starting with `#`)
- Blank lines

Not yet supported: quoted values, multi-line values, variable expansion, the `export` prefix, or UTF-8 BOM stripping.
