(* LoadDotEnv.wl
   Loads environment variables from .env files into a Wolfram Language session.
   Handles the basic case: unquoted key=value pairs, comment lines, blank lines.
   No support yet for: quoted values, multi-line values, variable expansion,
   the `export` prefix, or UTF-8 BOM stripping. *)

LoadDotEnv::usage = "LoadDotEnv[] loads the .env file in the current working directory and returns an Association of key-value pairs.\n LoadDotEnv[path] loads the .env file at the given path."

LoadDotEnv[] := LoadDotEnv[FileNameJoin[{Directory[], ".env"}]]

LoadDotEnv[path_String] :=
  Module[{lines, pairs},
    If[!FileExistsQ[path],
      Message[LoadDotEnv::nofile, path];
      Return[$Failed]
    ];
    lines = ReadList[path, String];
    pairs = DeleteCases[parseLine /@ lines, None];
    Association[pairs]
  ]

LoadDotEnv::nofile = "File not found: `1`."

(* Returns a Rule or None *)
parseLine[line_String] :=
  Module[{stripped, eqPos, key, value},
    stripped = StringTrim[line];
    If[stripped === "" || StringStartsQ[stripped, "#"], Return[None]];
    eqPos = First[StringPosition[stripped, "=", 1], None];
    If[eqPos === None, Return[None]];
    key   = StringTrim[StringTake[stripped, eqPos[[1]] - 1]];
    value = StringTrim[StringDrop[stripped, eqPos[[2]]]];
    If[key === "", Return[None]];
    key -> value
  ]
