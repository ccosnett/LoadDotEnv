(* LoadDotEnv.wl
   Loads environment variables from .env files into a Wolfram Language session.
   Handles the basic case: unquoted key=value pairs, comment lines, blank lines.
   No support yet for: quoted values, multi-line values, variable expansion,
   the `export` prefix, or UTF-8 BOM stripping.

   Parsing strategy: strip comment lines (starting with #) and blank lines,
   then delegate key=value parsing to ImportString[..., "Ini"], which treats
   the content as an INI-style file. This avoids reimplementing what the
   built-in importer already does correctly. *)

LoadDotEnv::usage = "LoadDotEnv[] loads the .env file in the current working directory and returns an Association of key-value pairs.\n LoadDotEnv[path] loads the .env file at the given path."

LoadDotEnv[] := LoadDotEnv[FileNameJoin[{Directory[], ".env"}]]

LoadDotEnv[path_String] :=
  Module[{lines, stripped, content, parsed},
    If[!FileExistsQ[path],
      Message[LoadDotEnv::nofile, path];
      Return[$Failed]
    ];
    lines = ReadList[path, String];
    (* Strip comment lines (starting with #) and blank lines *)
    stripped = Select[lines,
      With[{s = StringTrim[#]}, s =!= "" && !StringStartsQ[s, "#"]] &
    ];
    If[stripped === {}, Return[<||>]];
    content = StringRiffle[stripped, "\n"];
    (* ImportString[..., "Ini"] parses key=value pairs, returning
       { sectionName -> { key -> val, ... }, ... }.
       A .env file has no section headers, so everything lands in the
       default ("") section: { "" -> { "KEY" -> "val", ... } }. *)
    parsed = ImportString[content, "Ini"];
    Association[Flatten[Values /@ parsed]]
  ]

LoadDotEnv::nofile = "File not found: `1`."
