# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal study/work repository for `@studyworm` (이승용, studyworm@sicc.co.kr). It is not a conventional software project — it mixes personal notes, project documentation, analysis artifacts, and standalone utility code related to legacy COBOL-to-Java migration work at Hyundai Mobis (현대모비스).

The only executable code lives in `05_parser/`. Everything else (MDT/, IBM AI/, 250*/ directories) is documentation and analysis output in Korean.

## 05_parser — Static Analysis Tools

Three standalone Java programs for analyzing legacy IBM AS/400 COBOL and Java codebases. They have **no build system in this repo** — they are meant to be run directly from an IDE (e.g., Eclipse or IntelliJ) with `jsqlparser` and `commons-lang3`/`commons-io` on the classpath.

### What each class does

| Class | Purpose | Input | Output |
|---|---|---|---|
| `TestParser.java` | Extracts CRUD matrix from COBOL `.cob` files | Directory of `.cob` files | TSV: `filename TAB tableName TAB C TAB R TAB U TAB D TAB filePath` |
| `TestCallParser.java` | Extracts inter-program CALL relationships from COBOL | Directory of `.cob` files | TSV: `filename TAB calledProgram TAB filePath` |
| `TestJavaParser.java` | Extracts `.invoke()` calls from Java files (Java→COBOL bridge) | Directory of `.java` files | TSV: `filename TAB lib.programName TAB filePath` |

All three hardcode Windows source paths like `C:\DES_old\workspace\asisdbsrc` — update the `basePath` variable in `main()` before running.

### COBOL SQL parsing logic (TestParser)

SQL is embedded in COBOL between `EXEC SQL` and `END-EXEC` markers. The parser:
1. Strips comment lines (lines starting with `*` after leading whitespace)
2. Collapses multiple spaces and normalizes COBOL-specific syntax (`INTO :var`, `DECLARE ... CURSOR`)
3. Applies a keyword-match strategy (not full SQL parsing) against a hardcoded list of known AS/400 library/table names (e.g., `UPARTFLE`, `KPTDB09`, `APARTFLE`)
4. Determines CRUD type from the leading keyword of the first occurrence; subsequent table references are assumed reads (`R`)

`jsqlparser` (`CCJSqlParserUtil`) is present in `TestParser.java` in the `selectTableList` method but is **not used in the main execution path** — the production flow uses the keyword-match approach in `selectTableList2`/`getTable` instead.

### CALL extraction logic (TestCallParser)

Finds `\nCALL ` … `\n` substrings after comment removal. Extracts the called program name from single-quoted strings or the first space-delimited token.

### Java invoke extraction logic (TestJavaParser)

Finds `.invoke(` patterns in Java source; extracts the first two comma-separated arguments (library and program name) to build a `library.programName` key. This corresponds to an AS/400 program call bridge pattern.

### Output files (05_parser/output/)

Pre-generated result files from a prior run against the MPCA/AMOS codebase:

- `ALL_COBOL_CALL.sql` — COBOL→COBOL call graph
- `ALL_COBOL_CL_CALL.sql` / `ALL_COBOL_CL_SBMJOB_CALL.sql` — CL program call graph
- `ALL_CALL_TRANS.sql` — transition/mapping table
- `JAVA_CRUD.sql` / `JAVA_ALL_TABLE.sql` — Java-side CRUD results
- `ALL_ERROR_*` — files that failed to parse

`sbmjob_cobol_add.csv` is a supplemental call graph (columns: `cobol, call_cobol, cobol_file, file`) extracted from SBMJOB CL commands.

## Domain Context

The project background is a COBOL→Java migration (MPCA scheduler, Hyundai Mobis parts system). Key terminology:
- **MPCA** — legacy IBM AS/400 scheduler subsystem
- **UPARTFLE / KPTDB** — AS/400 library/table naming conventions
- **MDT** (Migration Data Transfer) — a sub-project for validating migrated data by replaying transactions
- **WCA** (Watson Code Assistant) — IBM's AI tool used to assist the COBOL→Java conversion
- **Nexacro** — the UI framework used in the Java replacement system

## 220828 draggable/

Standalone HTML/CSS/JS experiment for a native-JS draggable `<div>`, written as a learning exercise. No dependencies, no build step.
