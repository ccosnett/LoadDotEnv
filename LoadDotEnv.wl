(* LoadDotEnv.wl
   Loads environment variables from .env files into a Wolfram Language session.
   Handles the basic case: key=value pairs (quoted or unquoted), comment lines, blank lines.
   No support yet for: multi-line values, variable expansion,
   the `export` prefix, or UTF-8 BOM stripping.

   Parsing strategy: strip comment lines (starting with #) and blank lines,
   then delegate key=value parsing to ImportString[..., "Ini"], which treats
   the content as an INI-style file. This avoids reimplementing what the
   built-in importer already does correctly. *)

LoadDotEnv::usage = "LoadDotEnv[] loads the .env file in the current working directory and returns an Association of key-value pairs.\n LoadDotEnv[path] loads the .env file at the given path."

LoadDotEnv[] := LoadDotEnv[FileNameJoin[{Directory[], ".env"}]]

LoadDotEnv[path_String] := Module[{lines1, lines2, lines3, stripped, content, parsed},
  If[!FileExistsQ[path],
    Message[LoadDotEnv::nofile, path];
    Return[$Failed]
  ];
  (* Read all lines from the file *)
  lines1 = ReadList[path, String];
  (* Trim leading and trailing whitespace from each line *)
  lines2 = StringTrim /@ lines1;
  (* Remove double-quote characters from each line *)
  lines3 = StringDelete[#, "\""] & /@ lines2;
  (* Strip comment lines (starting with #) and blank lines *)
  stripped = DeleteCases[lines3, line_ /; StringStartsQ[line, "#"]];
  If[stripped === {}, Return[<||>]];
  content = StringRiffle[stripped, "\n"];
  (* ImportString[..., "Ini"] parses key=value pairs, returning
     { sectionName -> { key -> val, ... }, ... }.
     A .env file has no section headers, so everything lands in the
     default ("") section: { "" -> { "KEY" -> "val", ... } }. *)
  parsed = ImportString[content, "Ini"]
]

LoadDotEnv::nofile = "File not found: `1`."
