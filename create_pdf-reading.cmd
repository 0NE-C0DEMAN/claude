@echo off
echo Creating pdf-reading skill files...

mkdir "pdf-reading" 2>nul

echo Writing pdf-reading\LICENSE.txt...
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
) > "pdf-reading\LICENSE.txt"

echo Writing pdf-reading\REFERENCE.md...
(
echo # PDF Processing Advanced Reference
echo 
echo This document contains advanced PDF processing features, detailed examples, and additional libraries not covered in the main skill instructions.
echo 
echo ## pypdfium2 Library ^(Apache/BSD License^)
echo 
echo ### Overview
echo pypdfium2 is a Python binding for PDFium ^(Chromium's PDF library^). It's excellent for fast PDF rendering, image generation, and serves as a PyMuPDF replacement.
echo 
echo ### Render PDF to Images
echo ```python
echo import pypdfium2 as pdfium
echo from PIL import Image
echo 
echo # Load PDF
echo pdf = pdfium.PdfDocument^(^"document.pdf^"^)
echo 
echo # Render page to image
echo page = pdf[0]  # First page
echo bitmap = page.render^(
echo     scale=2.0,  # Higher resolution
echo     rotation=0  # No rotation
echo ^)
echo 
echo # Convert to PIL Image
echo img = bitmap.to_pil^(^)
echo img.save^(^"page_1.png^", ^"PNG^"^)
echo 
echo # Process multiple pages
echo for i, page in enumerate^(pdf^):
echo     bitmap = page.render^(scale=1.5^)
echo     img = bitmap.to_pil^(^)
echo     img.save^(f^"page_{i+1}.jpg^", ^"JPEG^", quality=90^)
echo ```
echo 
echo ### Extract Text with pypdfium2
echo ```python
echo import pypdfium2 as pdfium
echo 
echo pdf = pdfium.PdfDocument^(^"document.pdf^"^)
echo for i, page in enumerate^(pdf^):
echo     textpage = page.get_textpage^(^)
echo     text = textpage.get_text_range^(^)
echo     print^(f^"Page {i+1} text length: {len^(text^)} chars^"^)
echo ```
echo 
echo ## Advanced Command-Line Operations
echo 
echo ### poppler-utils Advanced Features
echo 
echo #### Extract Text with Bounding Box Coordinates
echo ```bash
echo # Extract text with bounding box coordinates ^(essential for structured data^)
echo pdftotext -bbox-layout document.pdf output.xml
echo 
echo # The XML output contains precise coordinates for each text element
echo ```
echo 
echo #### Advanced Image Conversion
echo ```bash
echo # Convert to PNG images with specific resolution
echo pdftoppm -png -r 300 document.pdf output_prefix
echo 
echo # Convert specific page range with high resolution
echo pdftoppm -png -r 600 -f 1 -l 3 document.pdf high_res_pages
echo 
echo # Convert to JPEG with quality setting
echo pdftoppm -jpeg -jpegopt quality=85 -r 200 document.pdf jpeg_output
echo ```
echo 
echo #### Extract Embedded Images
echo ```bash
echo # Extract all embedded images with metadata
echo pdfimages -j -p document.pdf page_images
echo 
echo # List image info without extracting
echo pdfimages -list document.pdf
echo 
echo # Extract images in their original format
echo pdfimages -all document.pdf images/img
echo ```
echo 
echo ### qpdf Advanced Features
echo 
echo For qpdf page manipulation, optimization, encryption, and repair,
echo see `/mnt/skills/public/pdf/SKILL.md`.
echo 
echo Useful qpdf reading/inspection commands:
echo ```bash
echo # Check PDF structure for errors
echo qpdf --check input.pdf
echo 
echo # Show detailed PDF structure for debugging
echo qpdf --show-pages input.pdf ^> structure.txt
echo 
echo # Check encryption status
echo qpdf --show-encryption encrypted.pdf
echo 
echo # Remove password protection ^(requires password^) for reading
echo qpdf --password=secret123 --decrypt encrypted.pdf decrypted.pdf
echo ```
echo 
echo ## Advanced Python Techniques
echo 
echo ### pdfplumber Advanced Features
echo 
echo #### Extract Text with Precise Coordinates
echo ```python
echo import pdfplumber
echo 
echo with pdfplumber.open^(^"document.pdf^"^) as pdf:
echo     page = pdf.pages[0]
echo     
echo     # Extract all text with coordinates
echo     chars = page.chars
echo     for char in chars[:10]:  # First 10 characters
echo         print^(f^"Char: '{char['text']}' at x:{char['x0']:.1f} y:{char['y0']:.1f}^"^)
echo     
echo     # Extract text by bounding box ^(left, top, right, bottom^)
echo     bbox_text = page.within_bbox^(^(100, 100, 400, 200^)^).extract_text^(^)
echo ```
echo 
echo #### Advanced Table Extraction with Custom Settings
echo ```python
echo import pdfplumber
echo import pandas as pd
echo 
echo with pdfplumber.open^(^"complex_table.pdf^"^) as pdf:
echo     page = pdf.pages[0]
echo     
echo     # Extract tables with custom settings for complex layouts
echo     table_settings = {
echo         ^"vertical_strategy^": ^"lines^",
echo         ^"horizontal_strategy^": ^"lines^",
echo         ^"snap_tolerance^": 3,
echo         ^"intersection_tolerance^": 15
echo     }
echo     tables = page.extract_tables^(table_settings^)
echo     
echo     # Visual debugging for table extraction
echo     img = page.to_image^(resolution=150^)
echo     img.save^(^"debug_layout.png^"^)
echo ```
echo 
echo ## Performance Optimization Tips
echo 
echo - `pdftotext` ^(CLI^) is fastest for plain text extraction ^(`-layout` for spatial positioning^)
echo - Use pdfplumber for structured data and tables; avoid `pypdf.extract_text^(^)` on very large documents
echo - `pdfimages` is much faster than rendering pages for image extraction
echo - For large PDFs, process pages individually rather than loading everything into memory
echo 
echo ## Troubleshooting Common Issues
echo 
echo ### Encrypted PDFs
echo ```python
echo # Handle password-protected PDFs
echo from pypdf import PdfReader
echo 
echo try:
echo     reader = PdfReader^(^"encrypted.pdf^"^)
echo     if reader.is_encrypted:
echo         reader.decrypt^(^"password^"^)
echo except Exception as e:
echo     print^(f^"Failed to decrypt: {e}^"^)
echo ```
echo 
echo ### Corrupted PDFs
echo ```bash
echo # Use qpdf to repair
echo qpdf --check corrupted.pdf
echo qpdf --replace-input corrupted.pdf
echo ```
echo 
echo ### Text Extraction Issues
echo ```python
echo # Fallback to OCR for scanned PDFs
echo import pytesseract
echo from pdf2image import convert_from_path
echo 
echo def extract_text_with_ocr^(pdf_path^):
echo     images = convert_from_path^(pdf_path^)
echo     text = ^"^"
echo     for i, image in enumerate^(images^):
echo         text += pytesseract.image_to_string^(image^)
echo     return text
echo ```
echo 
echo ## License Information
echo 
echo - **pypdf**: BSD License
echo - **pdfplumber**: MIT License
echo - **pypdfium2**: Apache/BSD License
echo - **PyMuPDF ^(fitz^)**: AGPL-3.0 License — copyleft; commercial licenses available from Artifex
echo - **poppler-utils**: GPL-2 License
echo - **qpdf**: Apache License
echo - **pytesseract**: Apache License ^(Tesseract engine: Apache License^)
) > "pdf-reading\REFERENCE.md"

echo Writing pdf-reading\SKILL.md...
(
echo ---
echo name: pdf-reading
echo description: ^"Use this skill when you need to read, inspect, or extract content from PDF files — especially when file content is NOT in your context and you need to read it from disk. Covers content inventory, text extraction, page rasterization for visual inspection, embedded image/attachment/table/form-field extraction, and choosing the right reading strategy for different document types ^(text-heavy, scanned, slide-decks, forms, data-heavy^). Do NOT use this skill for PDF creation, form filling, merging, splitting, watermarking, or encryption — use the pdf skill instead.^"
echo license: Proprietary. LICENSE.txt has complete terms
echo ---
echo 
echo # PDF Processing Guide
echo 
echo ## Overview
echo 
echo This guide covers essential PDF reading operations using Python libraries and command-line tools. For advanced features ^(pypdfium2 rendering, pdfplumber table settings, OCR fallback, encrypted/corrupted PDF handling^), see REFERENCE.md.
echo 
echo ## Reading ^& Inspecting PDFs
echo 
echo Before doing anything with a PDF, understand what you're working with.
echo 
echo ### Content inventory
echo 
echo Run a quick diagnostic first. For simple tasks ^(^"summarize this
echo document^"^), `pdfinfo` + a text sample may suffice. For anything
echo involving figures, attachments, or extraction issues, run the full set:
echo 
echo ```bash
echo # Always: page count, file size, PDF version, metadata
echo pdfinfo document.pdf
echo 
echo # Always: quick text extraction check — is this a text PDF or a scan?
echo pdftotext -f 1 -l 1 document.pdf - ^| head -20
echo 
echo # If figures/charts may matter:
echo pdfimages -list document.pdf
echo 
echo # If the PDF might contain embedded files ^(reports, portfolios^):
echo pdfdetach -list document.pdf
echo 
echo # If text extraction looks garbled:
echo pdffonts document.pdf
echo ```
echo 
echo This tells you:
echo - **Page count and size** — how big is the job?
echo - **Text extractability** — does `pdftotext` return real text, or is
echo   it empty ^(scanned^) or garbled ^(broken font encoding^)?
echo - **Embedded raster images** — are there photos or raster figures?
echo   ^(Note: vector-drawn charts from matplotlib/Excel won't appear — see
echo   ^"Extracting embedded images^" below^)
echo - **Attachments** — are there embedded spreadsheets, data files, etc.?
echo - **Font status** — are fonts embedded? If not, text extraction may
echo   produce wrong characters.
echo 
echo ### Text extraction
echo 
echo **pypdf** for basic text:
echo ```python
echo from pypdf import PdfReader
echo 
echo reader = PdfReader^(^"document.pdf^"^)
echo print^(f^"Pages: {len^(reader.pages^)}^"^)
echo 
echo # Extract text
echo text = ^"^"
echo for page in reader.pages:
echo     text += page.extract_text^(^)
echo ```
echo 
echo **pdftotext** preserving layout ^(better for multi-column docs^):
echo ```bash
echo # Layout mode preserves spatial positioning
echo pdftotext -layout document.pdf output.txt
echo 
echo # Specific page range
echo pdftotext -f 1 -l 5 document.pdf output.txt
echo ```
echo 
echo **pdfplumber** for layout-aware extraction with positioning data:
echo ```python
echo import pdfplumber
echo 
echo with pdfplumber.open^(^"document.pdf^"^) as pdf:
echo     for page in pdf.pages:
echo         text = page.extract_text^(^)
echo         print^(text^)
echo ```
echo 
echo ### Visual inspection ^(rasterize pages^)
echo 
echo Text extraction is **blind** to charts, diagrams, figures, equations,
echo multi-column layout, and form structures. When any of these matter,
echo rasterize the relevant page and Read the image:
echo 
echo ```bash
echo # Rasterize a single page ^(page 3 here^) at 150 DPI
echo pdftoppm -jpeg -r 150 -f 3 -l 3 document.pdf /tmp/page
echo 
echo # pdftoppm zero-pads the output filename based on TOTAL page count
echo # ^(e.g., page-03.jpg for a 50-page PDF, page-003.jpg for 200+ pages^)
echo # Don't guess the filename — find it:
echo ls /tmp/page-*.jpg
echo ```
echo 
echo Then Read the resulting image file. This gives you full visual
echo understanding of that page — layout, charts, equations, everything.
echo 
echo **When to rasterize vs. text-extract:**
echo - **Content/data questions → text extraction** ^(cheaper, searchable^)
echo - **Figures, charts, visual layout → rasterize the page**
echo - **Tables → try text extraction first, rasterize if garbled**
echo - **Precision matters → do both** ^(extract text AND rasterize; use text
echo   for data, image for context — this is what Claude's API does natively
echo   with PDF uploads^)
echo 
echo **Token cost awareness:**
echo - Text extraction: ~200–400 tokens per page
echo - Rasterized image: ~1,600 tokens per page ^(at 150 DPI^)
echo - Both together: ~2,000–2,400 tokens per page
echo 
echo For a 100-page PDF, rasterizing everything would consume ~160K tokens.
echo Only rasterize pages that matter for the question at hand.
echo 
echo ### Choosing your reading strategy
echo 
echo **Text-heavy documents** ^(reports, articles, books^):
echo → Text extraction is primary. Rasterize only for specific figures or
echo   pages where layout matters.
echo 
echo **Scanned documents** ^(no extractable text^):
echo → Rasterize pages at 150 DPI and Read them visually. For bulk text
echo   extraction, use OCR ^(pytesseract after converting pages to images —
echo   see REFERENCE.md for a complete example^).
echo 
echo **Slide-deck PDFs** ^(exported presentations^):
echo → Every page is primarily visual. Rasterize individual pages on demand.
echo   Text extraction gives you bullet-point text but loses all layout.
echo 
echo **Form-heavy documents**:
echo → Extract form field values programmatically first ^(see below^). Rasterize
echo   the form page for visual context if needed.
echo 
echo **Data-heavy documents** ^(tables, charts, figures^):
echo → Use pdfplumber for tables. Rasterize pages with charts/figures.
echo   Extract text for surrounding narrative. Consider both text AND image
echo   for the same page when precision matters.
echo 
echo ### Extracting embedded images
echo 
echo ```bash
echo # List all embedded images with metadata ^(size, color, compression^)
echo pdfimages -list document.pdf
echo 
echo # Extract all images as PNG
echo pdfimages -png document.pdf /tmp/img
echo 
echo # Extract from specific pages only ^(pages 3-5^)
echo pdfimages -png -f 3 -l 5 document.pdf /tmp/img
echo 
echo # Extract in original format ^(JPEG stays JPEG, etc.^)
echo pdfimages -all document.pdf /tmp/img
echo ```
echo 
echo Then Read `/tmp/img-000.png` ^(etc.^) to see each extracted image.
echo 
echo **Gotcha — vector graphics:** `pdfimages` extracts only raster image
echo data. Charts and diagrams drawn as vector graphics ^(common in
echo matplotlib, Excel, and R exports^) will NOT appear — they are page
echo content operators, not image objects. For these, rasterize the whole
echo page with `pdftoppm` instead.
echo 
echo **Gotcha — empty images:** `pdfimages` sometimes produces many tiny or
echo empty image files — these are typically background masks, transparency
echo layers, or decorative elements. Filter by file size to find the real
echo content images.
echo 
echo Programmatic extraction with position data:
echo ```python
echo import fitz  # PyMuPDF
echo 
echo doc = fitz.open^(^"document.pdf^"^)
echo for page in doc:
echo     for img in page.get_images^(^):
echo         xref = img[0]
echo         pix = fitz.Pixmap^(doc, xref^)
echo         if pix.n - pix.alpha ^> 3:  # CMYK or other non-RGB
echo             pix = fitz.Pixmap^(fitz.csRGB, pix^)
echo         pix.save^(f^"/tmp/img_{xref}.png^"^)
echo ```
echo 
echo ### Extracting file attachments
echo 
echo PDFs can contain embedded files — spreadsheets, data files, other
echo documents. Common in business reports, PDF portfolios, and PDF/A-3
echo compliance documents.
echo 
echo ```bash
echo # List all attachments
echo pdfdetach -list document.pdf
echo 
echo # Extract all attachments to a directory
echo mkdir -p /tmp/attachments
echo pdfdetach -saveall -o /tmp/attachments/ document.pdf
echo 
echo # Extract a specific attachment by number ^(1-based index from -list output^)
echo pdfdetach -save 1 -o /tmp/attachment.pdf document.pdf
echo ```
echo 
echo In Python:
echo ```python
echo import os
echo from pypdf import PdfReader
echo 
echo reader = PdfReader^(^"document.pdf^"^)
echo for name, content_list in reader.attachments.items^(^):
echo     safe_name = os.path.basename^(name^)  # sanitize — name comes from the PDF
echo     for content in content_list:
echo         with open^(f^"/tmp/{safe_name}^", ^"wb^"^) as f:
echo             f.write^(content^)
echo ```
echo 
echo **Two attachment mechanisms exist in PDFs:** page-level file annotation
echo attachments ^(shown as paperclip icons in viewers^) and document-level
echo embedded files ^(in the EmbeddedFiles name tree^). Both `pdfdetach` and
echo pypdf handle the common cases. Rich media assets ^(3D, video^) embedded
echo as annotations may not appear in the attachment list — use PyMuPDF to
echo iterate page annotations for those.
echo 
echo ### Extracting form field data
echo 
echo PDFs with interactive forms ^(government forms, applications, contracts^)
echo have fillable fields whose values can be read programmatically:
echo 
echo ```python
echo from pypdf import PdfReader
echo 
echo reader = PdfReader^(^"form.pdf^"^)
echo 
echo # Text input fields only:
echo fields = reader.get_form_text_fields^(^)
echo for name, value in fields.items^(^):
echo     print^(f^"{name}: {value}^"^)
echo 
echo # All field types ^(checkboxes, radio buttons, dropdowns too^):
echo all_fields = reader.get_fields^(^) or {}
echo for name, field in all_fields.items^(^):
echo     print^(f^"{name}: {field.get^('/V', ''^)} ^(type: {field.get^('/FT', ''^)}^)^"^)
echo ```
echo 
echo `get_form_text_fields^(^)` returns only text input fields. For
echo government forms and contracts that use checkboxes, radio buttons,
echo and dropdowns, use `get_fields^(^)` instead to see all field types.
echo 
echo For comprehensive field info ^(types, options, defaults^):
echo ```bash
echo pdftk form.pdf dump_data_fields
echo ```
echo 
echo For anything beyond reading form data — filling forms, creating forms —
echo use the pdf skill at `/mnt/skills/public/pdf/SKILL.md`.
echo 
echo ### Audio, video, and other rare embedded content
echo 
echo PDFs can occasionally embed audio, video, or 3D models. Check
echo `pdfdetach -list` first — if the media appears as an attachment,
echo extract with `pdfdetach -saveall`. If not, it may be a Rich Media
echo annotation ^(harder to extract; requires PyMuPDF to iterate page
echo annotations^). This is very rare in practice. Most PDF viewers outside
echo Adobe Acrobat do not support media playback.
echo 
echo ### Font diagnostics
echo 
echo If text extraction produces garbled output ^(wrong characters, missing
echo text, mojibake^), check the font situation:
echo 
echo ```bash
echo pdffonts document.pdf
echo ```
echo 
echo Look at the ^"emb^" column — if fonts show ^"no^" ^(not embedded^) with
echo custom encodings, the PDF's character mapping may be broken for text
echo extraction. In that case, rasterize the page and use vision instead.
echo 
echo Also check encoding: fonts with ^"Custom^" or ^"Identity-H^" encoding
echo without embedded CIDToGID maps can cause character substitution issues
echo even when the font is technically embedded.
echo 
echo ---
echo 
echo ## Quick Reference
echo 
echo ^| Task ^| Best Tool ^| Command/Code ^|
echo ^|------^|-----------^|--------------^|
echo ^| Inspect PDF ^| poppler-utils ^| `pdfinfo`, `pdfimages -list`, `pdfdetach -list`, `pdffonts` ^|
echo ^| Extract text ^| pdfplumber ^| `page.extract_text^(^)` ^|
echo ^| Extract text ^(CLI^) ^| pdftotext ^| `pdftotext -layout input.pdf output.txt` ^|
echo ^| Extract tables ^| pdfplumber ^| `page.extract_tables^(^)` ^|
echo ^| See page visually ^| pdftoppm ^| `pdftoppm -jpeg -r 150 -f N -l N` ^|
echo ^| Extract images ^| pdfimages ^| `pdfimages -png input.pdf prefix` ^|
echo ^| Extract attachments ^| pdfdetach ^| `pdfdetach -saveall -o /tmp/` ^|
echo ^| Read form fields ^| pypdf ^| `reader.get_fields^(^)` ^|
echo ^| OCR scanned PDFs ^| pytesseract ^| Convert to image first ^|
echo 
echo ## PDF Form Filling, Creation, Merging, Splitting, and Other Operations
echo 
echo This skill covers **reading and inspection** only. For filling forms,
echo creating, merging, splitting, rotating, watermarking, encrypting, or
echo other PDF manipulation tasks, use the public pdf skill at
echo `/mnt/skills/public/pdf/SKILL.md`.
) > "pdf-reading\SKILL.md"

echo.
echo Done! pdf-reading files created.
pause