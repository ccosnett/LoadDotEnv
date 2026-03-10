# CLAUDE.md — LoadDotEnv Paclet

## Project Goal

Convert `LoadDotEnv` from a single `.wl` file into a proper **Wolfram Language paclet** — a structured, installable, distributable package following Wolfram's standard paclet format.

---

## What is a Paclet?

A paclet is Wolfram's package management format. It is a directory (or `.paclet` ZIP archive) with a defined layout that Mathematica can install, version, and load automatically. Paclets integrate with the Documentation Center, autocomplete, and the Wolfram Paclet Repository.

---

## Target Directory Structure

```
LoadDotEnv/
├── PacletInfo.wl                  ← required manifest file
├── Kernel/
│   └── LoadDotEnv.wl              ← main source code (moved here)
├── Documentation/
│   └── English/
│       ├── Guides/
│       │   └── LoadDotEnv.nb
│       └── ReferencePages/
│           └── Symbols/
│               └── LoadDotEnv.nb
├── docs/                          ← dev docs (not part of paclet)
├── .env.example
├── README.md
└── LICENSE
```

---

## PacletInfo.wl

The root `PacletInfo.wl` must contain a single `PacletObject` expression:

```wolfram
PacletObject[<|
  "Name"               -> "LoadDotEnv",
  "Version"            -> "1.0.0",
  "MathematicaVersion" -> "13+",
  "Description"        -> "Load environment variables from .env files into a Wolfram Language session.",
  "Creator"            -> "ccosnett",
  "URL"                -> "https://github.com/ccosnett/LoadDotEnv",
  "License"            -> "MIT",
  "Extensions"         -> {
    {
      "Kernel",
      "Root"    -> "Kernel",
      "Context" -> {"LoadDotEnv`"}
    },
    {
      "Documentation",
      "Root"     -> "Documentation",
      "Language" -> "English"
    }
  }
|>]
```

---

## Kernel Code Conventions

- All source code lives in `Kernel/LoadDotEnv.wl`.
- Use `BeginPackage`/`EndPackage` to define the public context:

```wolfram
BeginPackage["LoadDotEnv`"]

LoadDotEnv::usage = "..."

Begin["LoadDotEnv`Private`"]

(* implementation *)

End[]
EndPackage[]
```

- The context is `LoadDotEnv\`` — matches the paclet `Name` exactly.
- Private symbols go in `LoadDotEnv\`Private\`` and must NOT be exported.
- Users load the paclet with `Needs["LoadDotEnv\`"]` or `<<LoadDotEnv\``.

---

## Versioning

- Follow semantic versioning: `major.minor.patch` (e.g. `"1.0.0"`).
- `MathematicaVersion` uses `+` suffix meaning "or later" (e.g. `"13+"`).
- The `Version` field in `PacletInfo.wl` drives the `.paclet` archive filename (e.g. `LoadDotEnv-1.0.0.paclet`).

---

## Building and Installing

```wolfram
(* Pack the paclet directory into a .paclet archive *)
CreatePacletArchive["/path/to/LoadDotEnv/"]

(* Install locally for testing *)
PacletInstall["/path/to/LoadDotEnv/"]

(* Or install from the archive *)
PacletInstall["/path/to/LoadDotEnv-1.0.0.paclet"]

(* Rebuild paclet database after manual placement *)
PacletManager`PacletDataRebuild[]

(* Verify install *)
PacletFind["LoadDotEnv"]
```

---

## What LoadDotEnv Does

Reads a `.env` file and returns its contents as a Wolfram `Association` of string keys to string values. See `docs/SPEC.md` for the full specification.

```wolfram
Needs["LoadDotEnv`"]

env = LoadDotEnv[]
(* <| "API_KEY" -> "abc123", "DB_HOST" -> "localhost" |> *)

env = LoadDotEnv["/path/to/project/.env"]
```

Key behaviours:
- Strips comment lines (`#`) and blank lines.
- Supports quoted and unquoted values.
- Supports the `export` prefix (ignored).
- Supports variable expansion (`${VAR}`) in unquoted and double-quoted values.
- Duplicate keys: last occurrence wins.
- Returns `$Failed` if the file does not exist.
- Does **not** call `SetEnvironment` — returns an `Association` only.
