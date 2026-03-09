# Plan: Create `LoadDotEnv` Function Repository Submission Notebook

## Goal

Create a Wolfram Function Repository submission notebook (`LoadDotEnv.nb`) that passes review, following all [official style guidelines](https://resources.wolframcloud.com/FunctionRepository/style-guidelines).

---

## 1. Create the Notebook Structure

Use **File > New > Repository Item > Function Repository Item** template structure. The notebook must contain these sections in order:

1. Title
2. Description
3. Definition (code)
4. Usage (input patterns + text)
5. Details & Options
6. Basic Examples
7. Scope
8. Possible Issues
9. Author Notes *(optional)*
10. Submission Notes *(optional)*

---

## 2. Title

- **Name:** `LoadDotEnv`
- Follows naming guidelines: specific, camelCase, no single common word, clearly reflects functionality.

---

## 3. Description

Must begin with an imperative verb, be brief, stand-alone, and **not** end with punctuation.

> Load environment variables from a .env file and return them as an Association

---

## 4. Definition (Code)

Embed the full self-contained implementation from `LoadDotEnv.wl`. Key compliance checks:

- [x] Uses `SetDelayed` (`:=`) for definitions
- [x] Self-contained — no external code sources (no GitHub/cloud fetches)
- [x] Only one user-facing symbol (`LoadDotEnv`)
- [x] No undocumented side effects (returns data, does not set env vars)
### Definition

See `LoadDotEnv.wl` for the canonical implementation. The code below mirrors it exactly:

```wolfram
(*
LoadDotEnv[] Loads environment variables from.env files into a Wolfram Language session. Handles the basic case: key=value pairs (quoted or unquoted),comment lines,blank lines. No support yet for: multi-line values,variable expansion,the `export` prefix,or UTF-8 BOM stripping. Parsing strategy: strip comment lines (starting with #) and blank lines,then delegate key=value parsing to ImportString[...,"Ini"],which treats the content as an INI-style file.This avoids reimplementing what the built-in importer already does correctly.
*)
ClearAll[LoadDotEnv];
LoadDotEnv::usage = "LoadDotEnv[] loads the .env file in the current working directory and returns an Association of key-value pairs.
LoadDotEnv[path] loads the .env file at the given path.";

LoadDotEnv[] := LoadDotEnv[FileNameJoin[{Directory[], ".env"}]]

LoadDotEnv[path_String] := Module[{lines, stripped, content, parsed}, If[! FileExistsQ[path], Message[LoadDotEnv::nofile, path];
   Return[$Failed]];
  lines = StringTrim /@ ReadList[path, String];
  lines = StringDelete[#, "\""] & /@ lines;
  stripped = Select[lines, ! StringStartsQ[#, "#"] && # =!= "" &];
  If[stripped === {}, Return[<||>]];
  content = StringRiffle[stripped, "\n"];
  parsed = ImportString[content, "Ini"]
  ]

LoadDotEnv::nofile = "File not found: `1`.";
```

---

## 5. Usage Patterns

Each usage must form a sentence ending with a period. Use template variable formatting for `path`.

| Pattern | Text |
|---|---|
| `LoadDotEnv[]` | Loads the `.env` file in the current working directory and returns an Association of key-value pairs. |
| `LoadDotEnv[path]` | Loads the `.env` file at the given *path*. |

---

## 6. Details & Options

- State that the function parses `KEY=VALUE` pairs, ignoring comment lines (starting with `#`) and blank lines.
- Note: double-quote characters around values are stripped.
- Note: the function returns `$Failed` with a message if the file is not found, and an empty `<||>` if the file contains no valid entries.
- No options to document (the function takes none).

---

## 7. Examples

All examples must be **runnable and reproducible**. Since `.env` files are local, examples must create temp files inline. Separate groups with "Insert Delimiter". Each group starts with descriptive text ending in a colon.

### 7a. Basic Examples

1. **Write and load a simple .env file:**
   ```wolfram
   file = Export[FileNameJoin[{$TemporaryDirectory, ".env"}],
     "API_KEY=abc123\nDB_HOST=localhost", "Text"];
   LoadDotEnv[file]
   (* <|"API_KEY" -> "abc123", "DB_HOST" -> "localhost"|> *)
   ```

2. **Load a file with comments and blank lines:**
   ```wolfram
   file = Export[FileNameJoin[{$TemporaryDirectory, ".env"}],
     "# database config\nDB_HOST=localhost\n\nDB_PORT=5432", "Text"];
   LoadDotEnv[file]
   (* <|"DB_HOST" -> "localhost", "DB_PORT" -> "5432"|> *)
   ```

3. **Quoted values have quotes stripped:**
   ```wolfram
   file = Export[FileNameJoin[{$TemporaryDirectory, ".env"}],
     "SECRET=\"my secret value\"", "Text"];
   LoadDotEnv[file]
   (* <|"SECRET" -> "my secret value"|> *)
   ```

### 7b. Scope

4. **Use the zero-argument form (loads `.env` from current directory):**
   ```wolfram
   SetDirectory[$TemporaryDirectory];
   Export[".env", "FOO=bar", "Text"];
   LoadDotEnv[]
   (* <|"FOO" -> "bar"|> *)
   ResetDirectory[];
   ```

5. **Access individual values from the result:**
   ```wolfram
   env = LoadDotEnv[file];
   env["API_KEY"]
   (* "abc123" *)
   ```

### 7c. Possible Issues

6. **File not found returns `$Failed`:**
   ```wolfram
   LoadDotEnv["/nonexistent/path/.env"]
   (* LoadDotEnv::nofile: File not found: /nonexistent/path/.env. *)
   (* $Failed *)
   ```

7. **Empty or comment-only file returns empty Association:**
   ```wolfram
   file = Export[FileNameJoin[{$TemporaryDirectory, ".env"}],
     "# just a comment", "Text"];
   LoadDotEnv[file]
   (* <||> *)
   ```

---

## 8. Author Notes

Include brief background:

> LoadDotEnv brings the common "dotenv" pattern from languages like Python, Ruby, and Node.js to the Wolfram Language. It is intentionally minimal: it handles the most common .env format (unquoted and double-quoted KEY=VALUE pairs with # comments) and delegates parsing to the built-in INI importer. Multi-line values, variable expansion, and the `export` prefix are not supported.

---

## 9. Submission Notes

> First submission. Inspired by python-dotenv. Uses ImportString with the "Ini" format for parsing.

---

## 10. Pre-Submission Checklist

- [ ] Create notebook using Function Repository Item template
- [ ] Populate all sections above
- [ ] Run **Check** (built into the template) — fix any flagged issues
- [ ] Run **Preview** — verify the documentation page renders correctly
- [ ] Confirm all examples produce the shown output
- [ ] Verify no external dependencies (no `Get`, `CloudGet`, etc.)
- [ ] Verify only one public symbol (`LoadDotEnv`)
- [ ] Review naming: specific enough, no overlap with built-in functions
- [ ] Submit via **Submit to Function Repository** button (calls `ResourceSubmit`)

---

## Files to Create

| File | Purpose |
|---|---|
| `LoadDotEnv.nb` | The Function Repository submission notebook (created from template in Mathematica) |

**Note:** The `.nb` notebook must be created interactively in Mathematica using **File > New > Repository Item > Function Repository Item**, since the template includes special cell types and metadata that cannot be replicated in plain text. This plan provides all the content to paste into each section.
