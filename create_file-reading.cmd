@echo off
echo Creating file-reading skill files...

mkdir "file-reading" 2>nul

echo Writing file-reading\LICENSE.txt...
(
echo © 2025 Anthropic, PBC. All rights reserved.
echo 
echo LICENSE: Use of these materials ^(including all code, prompts, assets, files,
echo and other components of this Skill^) is governed by your agreement with
echo Anthropic regarding use of Anthropic's services. If no separate agreement
echo exists, use is governed by Anthropic's Consumer Terms of Service or
echo Commercial Terms of Service, as applicable:
echo https://www.anthropic.com/legal/consumer-terms
echo https://www.anthropic.com/legal/commercial-terms
echo Your applicable agreement is referred to as the ^"Agreement.^" ^"Services^" are
echo as defined in the Agreement.
echo 
echo ADDITIONAL RESTRICTIONS: Notwithstanding anything in the Agreement to the
echo contrary, users may not:
echo 
echo - Extract these materials from the Services or retain copies of these
echo   materials outside the Services
echo - Reproduce or copy these materials, except for temporary copies created
echo   automatically during authorized use of the Services
echo - Create derivative works based on these materials
echo - Distribute, sublicense, or transfer these materials to any third party
echo - Make, offer to sell, sell, or import any inventions embodied in these
echo   materials
echo - Reverse engineer, decompile, or disassemble these materials
echo 
echo The receipt, viewing, or possession of these materials does not convey or
echo imply any license or right beyond those expressly granted above.
echo 
echo Anthropic retains all right, title, and interest in these materials,
echo including all copyrights, patents, and other intellectual property rights.
) > "file-reading\LICENSE.txt"

echo Writing file-reading\SKILL.md...
(
echo ---
echo name: file-reading
echo description: ^"Use this skill when a file has been uploaded but its content is NOT in your context — only its path at /mnt/user-data/uploads/ is listed in an uploaded_files block. This skill is a router: it tells you which tool to use for each file type ^(pdf, docx, xlsx, csv, json, images, archives, ebooks^) so you read the right amount the right way instead of blindly running cat on a binary. Triggers: any mention of /mnt/user-data/uploads/, an uploaded_files section, a file_path tag, or a user asking about an uploaded file you have not yet read. Do NOT use this skill if the file content is already visible in your context inside a documents block — you already have it.^"
echo compatibility: ^"claude.ai, Claude Desktop, Cowork — any surface where uploads land at /mnt/user-data/uploads/^"
echo license: Proprietary. LICENSE.txt has complete terms
echo ---
echo 
echo # Reading Uploaded Files
echo 
echo ## Why this skill exists
echo 
echo When a user uploads a file in claude.ai, Claude Desktop, or Cowork,
echo the file is written to `/mnt/user-data/uploads/^<filename^>` and you are told the path
echo in an `^<uploaded_files^>` block. **The content is not in your context.**
echo You must go read it.
echo 
echo The naive thing — `cat /mnt/user-data/uploads/whatever` — is wrong for
echo most files:
echo 
echo - On a PDF it prints binary garbage.
echo - On a 100MB CSV it floods your context with rows you will never use.
echo - On a DOCX it prints the raw ZIP bytes.
echo - On an image it does nothing useful at all.
echo 
echo This skill tells you the right first move for each type, and when to
echo hand off to a deeper skill.
echo 
echo ## General protocol
echo 
echo 1. **Look at the extension.** That is your dispatch key.
echo 2. **Stat before you read.** Large files need sampling, not slurping.
echo    ```bash
echo    stat -c '%%s bytes, %%y' /mnt/user-data/uploads/report.pdf
echo    file /mnt/user-data/uploads/report.pdf
echo    ```
echo 3. **Read just enough to answer the user's question.** If they asked
echo    ^"how many rows are in this CSV^", don't load the whole thing into
echo    pandas — `wc -l` gives a fast approximation ^(it counts newlines,
echo    not CSV records, so it may over-count if quoted fields contain
echo    embedded newlines^).
echo 4. **If a dedicated skill exists, go read it.** The table below tells
echo    you when. The dedicated skills cover editing, creating, and advanced
echo    operations that this skill does not.
echo 
echo ## Dispatch table
echo 
echo ^| Extension                         ^| First move                                           ^| Dedicated skill                           ^|
echo ^| --------------------------------- ^| ---------------------------------------------------- ^| ----------------------------------------- ^|
echo ^| `.pdf`                            ^| Content inventory ^(see PDF section^)                  ^| `/mnt/skills/public/pdf-reading/SKILL.md` ^|
echo ^| `.docx`                           ^| `pandoc` to markdown                                 ^| `/mnt/skills/public/docx/SKILL.md`        ^|
echo ^| `.doc` ^(legacy^)                   ^| Convert to `.docx` first — pandoc cannot read it     ^| `/mnt/skills/public/docx/SKILL.md`        ^|
echo ^| `.xlsx`, `.xlsm`                  ^| `openpyxl` sheet names + head                        ^| `/mnt/skills/public/xlsx/SKILL.md`        ^|
echo ^| `.xls` ^(legacy^)                   ^| `pd.read_excel^(engine=^"xlrd^"^)` — openpyxl rejects it ^| `/mnt/skills/public/xlsx/SKILL.md`        ^|
echo ^| `.ods`                            ^| `pd.read_excel^(engine=^"odf^"^)` — openpyxl rejects it  ^| `/mnt/skills/public/xlsx/SKILL.md`        ^|
echo ^| `.pptx`                           ^| `python-pptx` slide count                            ^| `/mnt/skills/public/pptx/SKILL.md`        ^|
echo ^| `.ppt` ^(legacy^)                   ^| Convert to `.pptx` first — python-pptx rejects it    ^| `/mnt/skills/public/pptx/SKILL.md`        ^|
echo ^| `.csv`, `.tsv`                    ^| `pandas` with `nrows`                                ^| — ^(below^)                                 ^|
echo ^| `.json`, `.jsonl`                 ^| `jq` for structure                                   ^| — ^(below^)                                 ^|
echo ^| `.jpg`, `.png`, `.gif`, `.webp`   ^| Already in your context as vision input              ^| — ^(below^)                                 ^|
echo ^| `.zip`, `.tar`, `.tar.gz`         ^| List contents, do **not** auto-extract               ^| — ^(below^)                                 ^|
echo ^| `.gz` ^(single file^)               ^| `zcat \^| head` — no manifest to list                 ^| — ^(below^)                                 ^|
echo ^| `.epub`, `.odt`                   ^| `pandoc` to plain text                               ^| — ^(below^)                                 ^|
echo ^| `.rtf`                            ^| `pandoc` ^(needs 3.1.7+^) or soffice via docx skill    ^| — ^(below^)                                 ^|
echo ^| `.txt`, `.md`, `.log`, code files ^| `wc -c` then `head` or full `cat`                    ^| — ^(below^)                                 ^|
echo ^| Unknown                           ^| `file` then decide                                   ^| —                                         ^|
echo 
echo ---
echo 
echo ## PDF
echo 
echo **Never** `cat` a PDF — it prints binary garbage.
echo 
echo Quick first move — get the page count and check if text is extractable:
echo 
echo ```bash
echo pdfinfo /mnt/user-data/uploads/report.pdf
echo pdftotext -f 1 -l 1 /mnt/user-data/uploads/report.pdf - ^| head -20
echo ```
echo 
echo Then peek at the text content:
echo 
echo ```python
echo from pypdf import PdfReader
echo r = PdfReader^(^"/mnt/user-data/uploads/report.pdf^"^)
echo print^(f^"{len^(r.pages^)} pages^"^)
echo print^(r.pages[0].extract_text^(^)[:2000]^)
echo ```
echo 
echo For anything beyond a quick peek — figures, tables, attachments,
echo forms, scanned PDFs, visual inspection, or choosing a reading strategy
echo — go read `/mnt/skills/public/pdf-reading/SKILL.md`. It covers
echo content inventory, text extraction vs. page rasterization, embedded
echo content extraction, and document-type-aware reading strategies.
echo 
echo For PDF form filling, creation, merging, splitting, or watermarking,
echo go read `/mnt/skills/public/pdf/SKILL.md`.
echo 
echo ---
echo 
echo ## DOCX / DOC
echo 
echo The `docx` skill covers editing, creating, tracked changes, images.
echo Read it if you need any of those. For a quick look:
echo 
echo ```bash
echo pandoc /mnt/user-data/uploads/memo.docx -t markdown ^| head -200
echo ```
echo 
echo Legacy `.doc` ^(not `.docx`^) must be converted first — see the `docx`
echo skill.
echo 
echo ---
echo 
echo ## XLSX / XLS / spreadsheets
echo 
echo The `xlsx` skill covers formulas, formatting, charts, creating. Read
echo it if you need any of those. For a quick look at `.xlsx` / `.xlsm`:
echo 
echo ```python
echo from openpyxl import load_workbook
echo wb = load_workbook^(^"/mnt/user-data/uploads/data.xlsx^", read_only=True^)
echo print^(^"Sheets:^", wb.sheetnames^)
echo ws = wb.active
echo for row in ws.iter_rows^(max_row=5, values_only=True^):
echo     print^(row^)
echo ```
echo 
echo `read_only=True` matters — without it, openpyxl loads the entire
echo workbook into memory, which breaks on large files. Do not trust
echo `ws.max_row` in read-only mode: many non-Excel writers omit the
echo dimension record, so it comes back `None` or wrong. If you need a row
echo count, iterate or use pandas.
echo 
echo **Legacy `.xls`** — openpyxl raises `InvalidFileException`. Use:
echo 
echo ```python
echo import pandas as pd
echo df = pd.read_excel^(^"/mnt/user-data/uploads/old.xls^", engine=^"xlrd^", nrows=5^)
echo ```
echo 
echo **`.ods` ^(OpenDocument^)** — openpyxl also rejects this. Use:
echo 
echo ```python
echo import pandas as pd
echo df = pd.read_excel^(^"/mnt/user-data/uploads/data.ods^", engine=^"odf^", nrows=5^)
echo ```
echo 
echo ---
echo 
echo ## PPTX
echo 
echo ```python
echo from itertools import islice
echo from pptx import Presentation
echo p = Presentation^(^"/mnt/user-data/uploads/deck.pptx^"^)
echo print^(f^"{len^(p.slides^)} slides^"^)
echo for i, slide in enumerate^(islice^(p.slides, 3^), 1^):
echo     texts = [s.text for s in slide.shapes if s.has_text_frame]
echo     print^(f^"Slide {i}:^", ^" ^| ^".join^(t for t in texts if t^)^)
echo ```
echo 
echo `p.slides` is not subscriptable — `p.slides[:3]` raises
echo `AttributeError`. Use `islice` or `list^(p.slides^)[:3]`.
echo 
echo **Legacy `.ppt`** — python-pptx only reads OOXML. Convert to `.pptx`
echo first via LibreOffice; see `/mnt/skills/public/pptx/SKILL.md` for the
echo sandbox-safe `scripts/office/soffice.py` wrapper ^(bare `soffice` hangs
echo here because the seccomp filter blocks the `AF_UNIX` sockets
echo LibreOffice uses for instance management^).
echo 
echo For anything beyond reading, go to `/mnt/skills/public/pptx/SKILL.md`.
echo 
echo ---
echo 
echo ## CSV / TSV
echo 
echo **Do not** `cat` or `head` these blindly. A CSV with a 50KB quoted cell
echo in row 1 will wreck your `head -5`. Use pandas with `nrows`:
echo 
echo ```python
echo import pandas as pd
echo df = pd.read_csv^(^"/mnt/user-data/uploads/data.csv^", nrows=5^)
echo print^(df^)
echo print^(^)
echo print^(df.dtypes^)
echo ```
echo 
echo Approximate row count without loading ^(over-counts if the file has
echo RFC-4180 quoted newlines — the same quoted-cell case this section
echo warned about above^):
echo 
echo ```bash
echo wc -l /mnt/user-data/uploads/data.csv
echo ```
echo 
echo Full analysis only after you know the shape:
echo 
echo ```python
echo df = pd.read_csv^(^"/mnt/user-data/uploads/data.csv^"^)
echo print^(df.describe^(^)^)
echo ```
echo 
echo TSV: same, with `sep=^"\t^"`.
echo 
echo ---
echo 
echo ## JSON / JSONL
echo 
echo Structure first, content second:
echo 
echo ```bash
echo jq 'type' /mnt/user-data/uploads/data.json
echo jq 'if type == ^"array^" then length elif type == ^"object^" then keys else . end' /mnt/user-data/uploads/data.json
echo ```
echo 
echo ^(`keys` errors on scalar JSON roots — a bare `^"hello^"` or `42` is valid
echo JSON per RFC 7159 — so guard the branch.^)
echo 
echo Then drill into what the user actually asked about.
echo 
echo JSONL ^(one object per line^) — do **not** `jq` the whole file; work line
echo by line:
echo 
echo ```bash
echo head -3 /mnt/user-data/uploads/data.jsonl ^| jq .
echo wc -l /mnt/user-data/uploads/data.jsonl
echo ```
echo 
echo ---
echo 
echo ## Images ^(JPG / PNG / GIF / WEBP^)
echo 
echo **You can already see uploaded images.** They are injected into your
echo context as vision inputs alongside the `^<uploaded_files^>` pointer. You
echo do not need to read them from disk to describe them.
echo 
echo The disk copy is only needed if you are going to **process** the image
echo programmatically:
echo 
echo ```python
echo from PIL import Image
echo img = Image.open^(^"/mnt/user-data/uploads/photo.jpg^"^)
echo print^(img.size, img.mode, img.format^)
echo ```
echo 
echo For OCR on an image ^(text extraction, not description^):
echo 
echo ```python
echo import pytesseract
echo print^(pytesseract.image_to_string^(img^)^)
echo ```
echo 
echo Note: the client resizes images larger than 2000×2000 down to that
echo bound and re-encodes as JPEG before upload, so the disk copy may not
echo be the user's original bytes. For most processing this doesn't matter;
echo if the user is asking about original-resolution pixel data, flag it.
echo 
echo ---
echo 
echo ## Archives ^(ZIP / TAR / TAR.GZ^)
echo 
echo **List first. Extract never — unless the user explicitly asks.**
echo Archives can be huge, contain path traversal, or nest forever.
echo 
echo ```bash
echo unzip -l /mnt/user-data/uploads/bundle.zip
echo tar -tf /mnt/user-data/uploads/bundle.tar
echo ```
echo 
echo GNU tar auto-detects compression — `tar -tf` works on `.tar`,
echo `.tar.gz`, `.tar.bz2`, `.tar.xz` alike. Don't hard-code `-z`.
echo 
echo If the user wants one file from inside, extract just that one:
echo 
echo ```bash
echo unzip -p /mnt/user-data/uploads/bundle.zip path/inside/file.txt
echo ```
echo 
echo **Standalone `.gz`** ^(not a tar^) compresses a single file — there is
echo no manifest to list. Just peek at the decompressed content:
echo 
echo ```bash
echo zcat /mnt/user-data/uploads/data.json.gz ^| head -50
echo ```
echo 
echo ---
echo 
echo ## EPUB / ODT
echo 
echo ```bash
echo pandoc /mnt/user-data/uploads/book.epub -t plain ^| head -200
echo ```
echo 
echo For long ebooks, pipe through `head` — you rarely need the whole thing
echo to answer a question.
echo 
echo ---
echo 
echo ## RTF
echo 
echo Pandoc's RTF reader was added in 3.1.7 ^(Oct 2023^). Debian Bookworm
echo ships 2.17, so try pandoc first but expect it may fail:
echo 
echo ```bash
echo pandoc /mnt/user-data/uploads/notes.rtf -t plain ^| head -200
echo ```
echo 
echo If you see `Unknown input format rtf`, convert via LibreOffice using
echo the sandbox-safe wrapper — see `/mnt/skills/public/docx/SKILL.md` for
echo `scripts/office/soffice.py` ^(do not call bare `soffice`; see the PPTX
echo section above for why^).
echo 
echo ---
echo 
echo ## Plain text / code / logs
echo 
echo Check the size first:
echo 
echo ```bash
echo wc -c /mnt/user-data/uploads/app.log
echo ```
echo 
echo - **Under ~20KB**: `cat` is fine.
echo - **Over ~20KB**: `head -100` and `tail -100` to orient. If the user
echo   asked about something specific, `grep` for it. Load the whole thing
echo   only if you genuinely need all of it.
echo 
echo For log files, the user almost always cares about the end:
echo 
echo ```bash
echo tail -200 /mnt/user-data/uploads/app.log
echo ```
echo 
echo ---
echo 
echo ## Unknown extension
echo 
echo ```bash
echo file /mnt/user-data/uploads/mystery.bin
echo xxd /mnt/user-data/uploads/mystery.bin ^| head -5
echo ```
echo 
echo `file` identifies most things. `xxd` head shows magic bytes. If `file`
echo says ^"data^" and the hex doesn't match anything you recognize, ask the
echo user what it is instead of guessing.
) > "file-reading\SKILL.md"

echo.
echo Done! file-reading files created.
pause