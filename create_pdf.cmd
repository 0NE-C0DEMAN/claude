@echo off
echo Creating pdf skill files...

mkdir "pdf" 2>nul

echo Writing pdf\FORMS.md...
(
echo **CRITICAL: You MUST complete these steps in order. Do not skip ahead to writing code.**
echo 
echo If you need to fill out a PDF form, first check to see if the PDF has fillable form fields. Run this script from this file's directory:
echo  `python scripts/check_fillable_fields ^<file.pdf^>`, and depending on the result go to either the ^"Fillable fields^" or ^"Non-fillable fields^" and follow those instructions.
echo 
echo # Fillable fields
echo If the PDF has fillable form fields:
echo - Run this script from this file's directory: `python scripts/extract_form_field_info.py ^<input.pdf^> ^<field_info.json^>`. It will create a JSON file with a list of fields in this format:
echo ```
echo [
echo   {
echo     ^"field_id^": ^(unique ID for the field^),
echo     ^"page^": ^(page number, 1-based^),
echo     ^"rect^": ^([left, bottom, right, top] bounding box in PDF coordinates, y=0 is the bottom of the page^),
echo     ^"type^": ^(^"text^", ^"checkbox^", ^"radio_group^", or ^"choice^"^),
echo   },
echo   // Checkboxes have ^"checked_value^" and ^"unchecked_value^" properties:
echo   {
echo     ^"field_id^": ^(unique ID for the field^),
echo     ^"page^": ^(page number, 1-based^),
echo     ^"type^": ^"checkbox^",
echo     ^"checked_value^": ^(Set the field to this value to check the checkbox^),
echo     ^"unchecked_value^": ^(Set the field to this value to uncheck the checkbox^),
echo   },
echo   // Radio groups have a ^"radio_options^" list with the possible choices.
echo   {
echo     ^"field_id^": ^(unique ID for the field^),
echo     ^"page^": ^(page number, 1-based^),
echo     ^"type^": ^"radio_group^",
echo     ^"radio_options^": [
echo       {
echo         ^"value^": ^(set the field to this value to select this radio option^),
echo         ^"rect^": ^(bounding box for the radio button for this option^)
echo       },
echo       // Other radio options
echo     ]
echo   },
echo   // Multiple choice fields have a ^"choice_options^" list with the possible choices:
echo   {
echo     ^"field_id^": ^(unique ID for the field^),
echo     ^"page^": ^(page number, 1-based^),
echo     ^"type^": ^"choice^",
echo     ^"choice_options^": [
echo       {
echo         ^"value^": ^(set the field to this value to select this option^),
echo         ^"text^": ^(display text of the option^)
echo       },
echo       // Other choice options
echo     ],
echo   }
echo ]
echo ```
echo - Convert the PDF to PNGs ^(one image for each page^) with this script ^(run from this file's directory^):
echo `python scripts/convert_pdf_to_images.py ^<file.pdf^> ^<output_directory^>`
echo Then analyze the images to determine the purpose of each form field ^(make sure to convert the bounding box PDF coordinates to image coordinates^).
echo - Create a `field_values.json` file in this format with the values to be entered for each field:
echo ```
echo [
echo   {
echo     ^"field_id^": ^"last_name^", // Must match the field_id from `extract_form_field_info.py`
echo     ^"description^": ^"The user's last name^",
echo     ^"page^": 1, // Must match the ^"page^" value in field_info.json
echo     ^"value^": ^"Simpson^"
echo   },
echo   {
echo     ^"field_id^": ^"Checkbox12^",
echo     ^"description^": ^"Checkbox to be checked if the user is 18 or over^",
echo     ^"page^": 1,
echo     ^"value^": ^"/On^" // If this is a checkbox, use its ^"checked_value^" value to check it. If it's a radio button group, use one of the ^"value^" values in ^"radio_options^".
echo   },
echo   // more fields
echo ]
echo ```
echo - Run the `fill_fillable_fields.py` script from this file's directory to create a filled-in PDF:
echo `python scripts/fill_fillable_fields.py ^<input pdf^> ^<field_values.json^> ^<output pdf^>`
echo This script will verify that the field IDs and values you provide are valid; if it prints error messages, correct the appropriate fields and try again.
echo 
echo # Non-fillable fields
echo If the PDF doesn't have fillable form fields, you'll add text annotations. First try to extract coordinates from the PDF structure ^(more accurate^), then fall back to visual estimation if needed.
echo 
echo ## Step 1: Try Structure Extraction First
echo 
echo Run this script to extract text labels, lines, and checkboxes with their exact PDF coordinates:
echo `python scripts/extract_form_structure.py ^<input.pdf^> form_structure.json`
echo 
echo This creates a JSON file containing:
echo - **labels**: Every text element with exact coordinates ^(x0, top, x1, bottom in PDF points^)
echo - **lines**: Horizontal lines that define row boundaries
echo - **checkboxes**: Small square rectangles that are checkboxes ^(with center coordinates^)
echo - **row_boundaries**: Row top/bottom positions calculated from horizontal lines
echo 
echo **Check the results**: If `form_structure.json` has meaningful labels ^(text elements that correspond to form fields^), use **Approach A: Structure-Based Coordinates**. If the PDF is scanned/image-based and has few or no labels, use **Approach B: Visual Estimation**.
echo 
echo ---
echo 
echo ## Approach A: Structure-Based Coordinates ^(Preferred^)
echo 
echo Use this when `extract_form_structure.py` found text labels in the PDF.
echo 
echo ### A.1: Analyze the Structure
echo 
echo Read form_structure.json and identify:
echo 
echo 1. **Label groups**: Adjacent text elements that form a single label ^(e.g., ^"Last^" + ^"Name^"^)
echo 2. **Row structure**: Labels with similar `top` values are in the same row
echo 3. **Field columns**: Entry areas start after label ends ^(x0 = label.x1 + gap^)
echo 4. **Checkboxes**: Use the checkbox coordinates directly from the structure
echo 
echo **Coordinate system**: PDF coordinates where y=0 is at TOP of page, y increases downward.
echo 
echo ### A.2: Check for Missing Elements
echo 
echo The structure extraction may not detect all form elements. Common cases:
echo - **Circular checkboxes**: Only square rectangles are detected as checkboxes
echo - **Complex graphics**: Decorative elements or non-standard form controls
echo - **Faded or light-colored elements**: May not be extracted
echo 
echo If you see form fields in the PDF images that aren't in form_structure.json, you'll need to use **visual analysis** for those specific fields ^(see ^"Hybrid Approach^" below^).
echo 
echo ### A.3: Create fields.json with PDF Coordinates
echo 
echo For each field, calculate entry coordinates from the extracted structure:
echo 
echo **Text fields:**
echo - entry x0 = label x1 + 5 ^(small gap after label^)
echo - entry x1 = next label's x0, or row boundary
echo - entry top = same as label top
echo - entry bottom = row boundary line below, or label bottom + row_height
echo 
echo **Checkboxes:**
echo - Use the checkbox rectangle coordinates directly from form_structure.json
echo - entry_bounding_box = [checkbox.x0, checkbox.top, checkbox.x1, checkbox.bottom]
echo 
echo Create fields.json using `pdf_width` and `pdf_height` ^(signals PDF coordinates^):
echo ```json
echo {
echo   ^"pages^": [
echo     {^"page_number^": 1, ^"pdf_width^": 612, ^"pdf_height^": 792}
echo   ],
echo   ^"form_fields^": [
echo     {
echo       ^"page_number^": 1,
echo       ^"description^": ^"Last name entry field^",
echo       ^"field_label^": ^"Last Name^",
echo       ^"label_bounding_box^": [43, 63, 87, 73],
echo       ^"entry_bounding_box^": [92, 63, 260, 79],
echo       ^"entry_text^": {^"text^": ^"Smith^", ^"font_size^": 10}
echo     },
echo     {
echo       ^"page_number^": 1,
echo       ^"description^": ^"US Citizen Yes checkbox^",
echo       ^"field_label^": ^"Yes^",
echo       ^"label_bounding_box^": [260, 200, 280, 210],
echo       ^"entry_bounding_box^": [285, 197, 292, 205],
echo       ^"entry_text^": {^"text^": ^"X^"}
echo     }
echo   ]
echo }
echo ```
echo 
echo **Important**: Use `pdf_width`/`pdf_height` and coordinates directly from form_structure.json.
echo 
echo ### A.4: Validate Bounding Boxes
echo 
echo Before filling, check your bounding boxes for errors:
echo `python scripts/check_bounding_boxes.py fields.json`
echo 
echo This checks for intersecting bounding boxes and entry boxes that are too small for the font size. Fix any reported errors before filling.
echo 
echo ---
echo 
echo ## Approach B: Visual Estimation ^(Fallback^)
echo 
echo Use this when the PDF is scanned/image-based and structure extraction found no usable text labels ^(e.g., all text shows as ^"^(cid:X^)^" patterns^).
echo 
echo ### B.1: Convert PDF to Images
echo 
echo `python scripts/convert_pdf_to_images.py ^<input.pdf^> ^<images_dir/^>`
echo 
echo ### B.2: Initial Field Identification
echo 
echo Examine each page image to identify form sections and get **rough estimates** of field locations:
echo - Form field labels and their approximate positions
echo - Entry areas ^(lines, boxes, or blank spaces for text input^)
echo - Checkboxes and their approximate locations
echo 
echo For each field, note approximate pixel coordinates ^(they don't need to be precise yet^).
echo 
echo ### B.3: Zoom Refinement ^(CRITICAL for accuracy^)
echo 
echo For each field, crop a region around the estimated position to refine coordinates precisely.
echo 
echo **Create a zoomed crop using ImageMagick:**
echo ```bash
echo magick ^<page_image^> -crop ^<width^>x^<height^>+^<x^>+^<y^> +repage ^<crop_output.png^>
echo ```
echo 
echo Where:
echo - `^<x^>, ^<y^>` = top-left corner of crop region ^(use your rough estimate minus padding^)
echo - `^<width^>, ^<height^>` = size of crop region ^(field area plus ~50px padding on each side^)
echo 
echo **Example:** To refine a ^"Name^" field estimated around ^(100, 150^):
echo ```bash
echo magick images_dir/page_1.png -crop 300x80+50+120 +repage crops/name_field.png
echo ```
echo 
echo ^(Note: if the `magick` command isn't available, try `convert` with the same arguments^).
echo 
echo **Examine the cropped image** to determine precise coordinates:
echo 1. Identify the exact pixel where the entry area begins ^(after the label^)
echo 2. Identify where the entry area ends ^(before next field or edge^)
echo 3. Identify the top and bottom of the entry line/box
echo 
echo **Convert crop coordinates back to full image coordinates:**
echo - full_x = crop_x + crop_offset_x
echo - full_y = crop_y + crop_offset_y
echo 
echo Example: If the crop started at ^(50, 120^) and the entry box starts at ^(52, 18^) within the crop:
echo - entry_x0 = 52 + 50 = 102
echo - entry_top = 18 + 120 = 138
echo 
echo **Repeat for each field**, grouping nearby fields into single crops when possible.
echo 
echo ### B.4: Create fields.json with Refined Coordinates
echo 
echo Create fields.json using `image_width` and `image_height` ^(signals image coordinates^):
echo ```json
echo {
echo   ^"pages^": [
echo     {^"page_number^": 1, ^"image_width^": 1700, ^"image_height^": 2200}
echo   ],
echo   ^"form_fields^": [
echo     {
echo       ^"page_number^": 1,
echo       ^"description^": ^"Last name entry field^",
echo       ^"field_label^": ^"Last Name^",
echo       ^"label_bounding_box^": [120, 175, 242, 198],
echo       ^"entry_bounding_box^": [255, 175, 720, 218],
echo       ^"entry_text^": {^"text^": ^"Smith^", ^"font_size^": 10}
echo     }
echo   ]
echo }
echo ```
echo 
echo **Important**: Use `image_width`/`image_height` and the refined pixel coordinates from the zoom analysis.
echo 
echo ### B.5: Validate Bounding Boxes
echo 
echo Before filling, check your bounding boxes for errors:
echo `python scripts/check_bounding_boxes.py fields.json`
echo 
echo This checks for intersecting bounding boxes and entry boxes that are too small for the font size. Fix any reported errors before filling.
echo 
echo ---
echo 
echo ## Hybrid Approach: Structure + Visual
echo 
echo Use this when structure extraction works for most fields but misses some elements ^(e.g., circular checkboxes, unusual form controls^).
echo 
echo 1. **Use Approach A** for fields that were detected in form_structure.json
echo 2. **Convert PDF to images** for visual analysis of missing fields
echo 3. **Use zoom refinement** ^(from Approach B^) for the missing fields
echo 4. **Combine coordinates**: For fields from structure extraction, use `pdf_width`/`pdf_height`. For visually-estimated fields, you must convert image coordinates to PDF coordinates:
echo    - pdf_x = image_x * ^(pdf_width / image_width^)
echo    - pdf_y = image_y * ^(pdf_height / image_height^)
echo 5. **Use a single coordinate system** in fields.json - convert all to PDF coordinates with `pdf_width`/`pdf_height`
echo 
echo ---
echo 
echo ## Step 2: Validate Before Filling
echo 
echo **Always validate bounding boxes before filling:**
echo `python scripts/check_bounding_boxes.py fields.json`
echo 
echo This checks for:
echo - Intersecting bounding boxes ^(which would cause overlapping text^)
echo - Entry boxes that are too small for the specified font size
echo 
echo Fix any reported errors in fields.json before proceeding.
echo 
echo ## Step 3: Fill the Form
echo 
echo The fill script auto-detects the coordinate system and handles conversion:
echo `python scripts/fill_pdf_form_with_annotations.py ^<input.pdf^> fields.json ^<output.pdf^>`
echo 
echo ## Step 4: Verify Output
echo 
echo Convert the filled PDF to images and verify text placement:
echo `python scripts/convert_pdf_to_images.py ^<output.pdf^> ^<verify_images/^>`
echo 
echo If text is mispositioned:
echo - **Approach A**: Check that you're using PDF coordinates from form_structure.json with `pdf_width`/`pdf_height`
echo - **Approach B**: Check that image dimensions match and coordinates are accurate pixels
echo - **Hybrid**: Ensure coordinate conversions are correct for visually-estimated fields
) > "pdf\FORMS.md"

echo Writing pdf\LICENSE.txt...
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
) > "pdf\LICENSE.txt"

echo Writing pdf\REFERENCE.md...
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
echo     text = page.get_text^(^)
echo     print^(f^"Page {i+1} text length: {len^(text^)} chars^"^)
echo ```
echo 
echo ## JavaScript Libraries
echo 
echo ### pdf-lib ^(MIT License^)
echo 
echo pdf-lib is a powerful JavaScript library for creating and modifying PDF documents in any JavaScript environment.
echo 
echo #### Load and Manipulate Existing PDF
echo ```javascript
echo import { PDFDocument } from 'pdf-lib';
echo import fs from 'fs';
echo 
echo async function manipulatePDF^(^) {
echo     // Load existing PDF
echo     const existingPdfBytes = fs.readFileSync^('input.pdf'^);
echo     const pdfDoc = await PDFDocument.load^(existingPdfBytes^);
echo 
echo     // Get page count
echo     const pageCount = pdfDoc.getPageCount^(^);
echo     console.log^(`Document has ${pageCount} pages`^);
echo 
echo     // Add new page
echo     const newPage = pdfDoc.addPage^([600, 400]^);
echo     newPage.drawText^('Added by pdf-lib', {
echo         x: 100,
echo         y: 300,
echo         size: 16
echo     }^);
echo 
echo     // Save modified PDF
echo     const pdfBytes = await pdfDoc.save^(^);
echo     fs.writeFileSync^('modified.pdf', pdfBytes^);
echo }
echo ```
echo 
echo #### Create Complex PDFs from Scratch
echo ```javascript
echo import { PDFDocument, rgb, StandardFonts } from 'pdf-lib';
echo import fs from 'fs';
echo 
echo async function createPDF^(^) {
echo     const pdfDoc = await PDFDocument.create^(^);
echo 
echo     // Add fonts
echo     const helveticaFont = await pdfDoc.embedFont^(StandardFonts.Helvetica^);
echo     const helveticaBold = await pdfDoc.embedFont^(StandardFonts.HelveticaBold^);
echo 
echo     // Add page
echo     const page = pdfDoc.addPage^([595, 842]^); // A4 size
echo     const { width, height } = page.getSize^(^);
echo 
echo     // Add text with styling
echo     page.drawText^('Invoice #12345', {
echo         x: 50,
echo         y: height - 50,
echo         size: 18,
echo         font: helveticaBold,
echo         color: rgb^(0.2, 0.2, 0.8^)
echo     }^);
echo 
echo     // Add rectangle ^(header background^)
echo     page.drawRectangle^({
echo         x: 40,
echo         y: height - 100,
echo         width: width - 80,
echo         height: 30,
echo         color: rgb^(0.9, 0.9, 0.9^)
echo     }^);
echo 
echo     // Add table-like content
echo     const items = [
echo         ['Item', 'Qty', 'Price', 'Total'],
echo         ['Widget', '2', '$50', '$100'],
echo         ['Gadget', '1', '$75', '$75']
echo     ];
echo 
echo     let yPos = height - 150;
echo     items.forEach^(row =^> {
echo         let xPos = 50;
echo         row.forEach^(cell =^> {
echo             page.drawText^(cell, {
echo                 x: xPos,
echo                 y: yPos,
echo                 size: 12,
echo                 font: helveticaFont
echo             }^);
echo             xPos += 120;
echo         }^);
echo         yPos -= 25;
echo     }^);
echo 
echo     const pdfBytes = await pdfDoc.save^(^);
echo     fs.writeFileSync^('created.pdf', pdfBytes^);
echo }
echo ```
echo 
echo #### Advanced Merge and Split Operations
echo ```javascript
echo import { PDFDocument } from 'pdf-lib';
echo import fs from 'fs';
echo 
echo async function mergePDFs^(^) {
echo     // Create new document
echo     const mergedPdf = await PDFDocument.create^(^);
echo 
echo     // Load source PDFs
echo     const pdf1Bytes = fs.readFileSync^('doc1.pdf'^);
echo     const pdf2Bytes = fs.readFileSync^('doc2.pdf'^);
echo 
echo     const pdf1 = await PDFDocument.load^(pdf1Bytes^);
echo     const pdf2 = await PDFDocument.load^(pdf2Bytes^);
echo 
echo     // Copy pages from first PDF
echo     const pdf1Pages = await mergedPdf.copyPages^(pdf1, pdf1.getPageIndices^(^)^);
echo     pdf1Pages.forEach^(page =^> mergedPdf.addPage^(page^)^);
echo 
echo     // Copy specific pages from second PDF ^(pages 0, 2, 4^)
echo     const pdf2Pages = await mergedPdf.copyPages^(pdf2, [0, 2, 4]^);
echo     pdf2Pages.forEach^(page =^> mergedPdf.addPage^(page^)^);
echo 
echo     const mergedPdfBytes = await mergedPdf.save^(^);
echo     fs.writeFileSync^('merged.pdf', mergedPdfBytes^);
echo }
echo ```
echo 
echo ### pdfjs-dist ^(Apache License^)
echo 
echo PDF.js is Mozilla's JavaScript library for rendering PDFs in the browser.
echo 
echo #### Basic PDF Loading and Rendering
echo ```javascript
echo import * as pdfjsLib from 'pdfjs-dist';
echo 
echo // Configure worker ^(important for performance^)
echo pdfjsLib.GlobalWorkerOptions.workerSrc = './pdf.worker.js';
echo 
echo async function renderPDF^(^) {
echo     // Load PDF
echo     const loadingTask = pdfjsLib.getDocument^('document.pdf'^);
echo     const pdf = await loadingTask.promise;
echo 
echo     console.log^(`Loaded PDF with ${pdf.numPages} pages`^);
echo 
echo     // Get first page
echo     const page = await pdf.getPage^(1^);
echo     const viewport = page.getViewport^({ scale: 1.5 }^);
echo 
echo     // Render to canvas
echo     const canvas = document.createElement^('canvas'^);
echo     const context = canvas.getContext^('2d'^);
echo     canvas.height = viewport.height;
echo     canvas.width = viewport.width;
echo 
echo     const renderContext = {
echo         canvasContext: context,
echo         viewport: viewport
echo     };
echo 
echo     await page.render^(renderContext^).promise;
echo     document.body.appendChild^(canvas^);
echo }
echo ```
echo 
echo #### Extract Text with Coordinates
echo ```javascript
echo import * as pdfjsLib from 'pdfjs-dist';
echo 
echo async function extractText^(^) {
echo     const loadingTask = pdfjsLib.getDocument^('document.pdf'^);
echo     const pdf = await loadingTask.promise;
echo 
echo     let fullText = '';
echo 
echo     // Extract text from all pages
echo     for ^(let i = 1; i ^<= pdf.numPages; i++^) {
echo         const page = await pdf.getPage^(i^);
echo         const textContent = await page.getTextContent^(^);
echo 
echo         const pageText = textContent.items
echo             .map^(item =^> item.str^)
echo             .join^(' '^);
echo 
echo         fullText += `\n--- Page ${i} ---\n${pageText}`;
echo 
echo         // Get text with coordinates for advanced processing
echo         const textWithCoords = textContent.items.map^(item =^> ^({
echo             text: item.str,
echo             x: item.transform[4],
echo             y: item.transform[5],
echo             width: item.width,
echo             height: item.height
echo         }^)^);
echo     }
echo 
echo     console.log^(fullText^);
echo     return fullText;
echo }
echo ```
echo 
echo #### Extract Annotations and Forms
echo ```javascript
echo import * as pdfjsLib from 'pdfjs-dist';
echo 
echo async function extractAnnotations^(^) {
echo     const loadingTask = pdfjsLib.getDocument^('annotated.pdf'^);
echo     const pdf = await loadingTask.promise;
echo 
echo     for ^(let i = 1; i ^<= pdf.numPages; i++^) {
echo         const page = await pdf.getPage^(i^);
echo         const annotations = await page.getAnnotations^(^);
echo 
echo         annotations.forEach^(annotation =^> {
echo             console.log^(`Annotation type: ${annotation.subtype}`^);
echo             console.log^(`Content: ${annotation.contents}`^);
echo             console.log^(`Coordinates: ${JSON.stringify^(annotation.rect^)}`^);
echo         }^);
echo     }
echo }
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
echo #### Complex Page Manipulation
echo ```bash
echo # Split PDF into groups of pages
echo qpdf --split-pages=3 input.pdf output_group_%%02d.pdf
echo 
echo # Extract specific pages with complex ranges
echo qpdf input.pdf --pages input.pdf 1,3-5,8,10-end -- extracted.pdf
echo 
echo # Merge specific pages from multiple PDFs
echo qpdf --empty --pages doc1.pdf 1-3 doc2.pdf 5-7 doc3.pdf 2,4 -- combined.pdf
echo ```
echo 
echo #### PDF Optimization and Repair
echo ```bash
echo # Optimize PDF for web ^(linearize for streaming^)
echo qpdf --linearize input.pdf optimized.pdf
echo 
echo # Remove unused objects and compress
echo qpdf --optimize-level=all input.pdf compressed.pdf
echo 
echo # Attempt to repair corrupted PDF structure
echo qpdf --check input.pdf
echo qpdf --fix-qdf damaged.pdf repaired.pdf
echo 
echo # Show detailed PDF structure for debugging
echo qpdf --show-all-pages input.pdf ^> structure.txt
echo ```
echo 
echo #### Advanced Encryption
echo ```bash
echo # Add password protection with specific permissions
echo qpdf --encrypt user_pass owner_pass 256 --print=none --modify=none -- input.pdf encrypted.pdf
echo 
echo # Check encryption status
echo qpdf --show-encryption encrypted.pdf
echo 
echo # Remove password protection ^(requires password^)
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
echo ### reportlab Advanced Features
echo 
echo #### Create Professional Reports with Tables
echo ```python
echo from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph
echo from reportlab.lib.styles import getSampleStyleSheet
echo from reportlab.lib import colors
echo 
echo # Sample data
echo data = [
echo     ['Product', 'Q1', 'Q2', 'Q3', 'Q4'],
echo     ['Widgets', '120', '135', '142', '158'],
echo     ['Gadgets', '85', '92', '98', '105']
echo ]
echo 
echo # Create PDF with table
echo doc = SimpleDocTemplate^(^"report.pdf^"^)
echo elements = []
echo 
echo # Add title
echo styles = getSampleStyleSheet^(^)
echo title = Paragraph^(^"Quarterly Sales Report^", styles['Title']^)
echo elements.append^(title^)
echo 
echo # Add table with advanced styling
echo table = Table^(data^)
echo table.setStyle^(TableStyle^([
echo     ^('BACKGROUND', ^(0, 0^), ^(-1, 0^), colors.grey^),
echo     ^('TEXTCOLOR', ^(0, 0^), ^(-1, 0^), colors.whitesmoke^),
echo     ^('ALIGN', ^(0, 0^), ^(-1, -1^), 'CENTER'^),
echo     ^('FONTNAME', ^(0, 0^), ^(-1, 0^), 'Helvetica-Bold'^),
echo     ^('FONTSIZE', ^(0, 0^), ^(-1, 0^), 14^),
echo     ^('BOTTOMPADDING', ^(0, 0^), ^(-1, 0^), 12^),
echo     ^('BACKGROUND', ^(0, 1^), ^(-1, -1^), colors.beige^),
echo     ^('GRID', ^(0, 0^), ^(-1, -1^), 1, colors.black^)
echo ]^)^)
echo elements.append^(table^)
echo 
echo doc.build^(elements^)
echo ```
echo 
echo ## Complex Workflows
echo 
echo ### Extract Figures/Images from PDF
echo 
echo #### Method 1: Using pdfimages ^(fastest^)
echo ```bash
echo # Extract all images with original quality
echo pdfimages -all document.pdf images/img
echo ```
echo 
echo #### Method 2: Using pypdfium2 + Image Processing
echo ```python
echo import pypdfium2 as pdfium
echo from PIL import Image
echo import numpy as np
echo 
echo def extract_figures^(pdf_path, output_dir^):
echo     pdf = pdfium.PdfDocument^(pdf_path^)
echo     
echo     for page_num, page in enumerate^(pdf^):
echo         # Render high-resolution page
echo         bitmap = page.render^(scale=3.0^)
echo         img = bitmap.to_pil^(^)
echo         
echo         # Convert to numpy for processing
echo         img_array = np.array^(img^)
echo         
echo         # Simple figure detection ^(non-white regions^)
echo         mask = np.any^(img_array != [255, 255, 255], axis=2^)
echo         
echo         # Find contours and extract bounding boxes
echo         # ^(This is simplified - real implementation would need more sophisticated detection^)
echo         
echo         # Save detected figures
echo         # ... implementation depends on specific needs
echo ```
echo 
echo ### Batch PDF Processing with Error Handling
echo ```python
echo import os
echo import glob
echo from pypdf import PdfReader, PdfWriter
echo import logging
echo 
echo logging.basicConfig^(level=logging.INFO^)
echo logger = logging.getLogger^(__name__^)
echo 
echo def batch_process_pdfs^(input_dir, operation='merge'^):
echo     pdf_files = glob.glob^(os.path.join^(input_dir, ^"*.pdf^"^)^)
echo     
echo     if operation == 'merge':
echo         writer = PdfWriter^(^)
echo         for pdf_file in pdf_files:
echo             try:
echo                 reader = PdfReader^(pdf_file^)
echo                 for page in reader.pages:
echo                     writer.add_page^(page^)
echo                 logger.info^(f^"Processed: {pdf_file}^"^)
echo             except Exception as e:
echo                 logger.error^(f^"Failed to process {pdf_file}: {e}^"^)
echo                 continue
echo         
echo         with open^(^"batch_merged.pdf^", ^"wb^"^) as output:
echo             writer.write^(output^)
echo     
echo     elif operation == 'extract_text':
echo         for pdf_file in pdf_files:
echo             try:
echo                 reader = PdfReader^(pdf_file^)
echo                 text = ^"^"
echo                 for page in reader.pages:
echo                     text += page.extract_text^(^)
echo                 
echo                 output_file = pdf_file.replace^('.pdf', '.txt'^)
echo                 with open^(output_file, 'w', encoding='utf-8'^) as f:
echo                     f.write^(text^)
echo                 logger.info^(f^"Extracted text from: {pdf_file}^"^)
echo                 
echo             except Exception as e:
echo                 logger.error^(f^"Failed to extract text from {pdf_file}: {e}^"^)
echo                 continue
echo ```
echo 
echo ### Advanced PDF Cropping
echo ```python
echo from pypdf import PdfWriter, PdfReader
echo 
echo reader = PdfReader^(^"input.pdf^"^)
echo writer = PdfWriter^(^)
echo 
echo # Crop page ^(left, bottom, right, top in points^)
echo page = reader.pages[0]
echo page.mediabox.left = 50
echo page.mediabox.bottom = 50
echo page.mediabox.right = 550
echo page.mediabox.top = 750
echo 
echo writer.add_page^(page^)
echo with open^(^"cropped.pdf^", ^"wb^"^) as output:
echo     writer.write^(output^)
echo ```
echo 
echo ## Performance Optimization Tips
echo 
echo ### 1. For Large PDFs
echo - Use streaming approaches instead of loading entire PDF in memory
echo - Use `qpdf --split-pages` for splitting large files
echo - Process pages individually with pypdfium2
echo 
echo ### 2. For Text Extraction
echo - `pdftotext -bbox-layout` is fastest for plain text extraction
echo - Use pdfplumber for structured data and tables
echo - Avoid `pypdf.extract_text^(^)` for very large documents
echo 
echo ### 3. For Image Extraction
echo - `pdfimages` is much faster than rendering pages
echo - Use low resolution for previews, high resolution for final output
echo 
echo ### 4. For Form Filling
echo - pdf-lib maintains form structure better than most alternatives
echo - Pre-validate form fields before processing
echo 
echo ### 5. Memory Management
echo ```python
echo # Process PDFs in chunks
echo def process_large_pdf^(pdf_path, chunk_size=10^):
echo     reader = PdfReader^(pdf_path^)
echo     total_pages = len^(reader.pages^)
echo     
echo     for start_idx in range^(0, total_pages, chunk_size^):
echo         end_idx = min^(start_idx + chunk_size, total_pages^)
echo         writer = PdfWriter^(^)
echo         
echo         for i in range^(start_idx, end_idx^):
echo             writer.add_page^(reader.pages[i]^)
echo         
echo         # Process chunk
echo         with open^(f^"chunk_{start_idx//chunk_size}.pdf^", ^"wb^"^) as output:
echo             writer.write^(output^)
echo ```
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
echo - **reportlab**: BSD License
echo - **poppler-utils**: GPL-2 License
echo - **qpdf**: Apache License
echo - **pdf-lib**: MIT License
echo - **pdfjs-dist**: Apache License
) > "pdf\REFERENCE.md"

echo Writing pdf\SKILL.md...
(
echo ---
echo name: pdf
echo description: Use this skill whenever the user wants to do anything with PDF files. This includes reading or extracting text/tables from PDFs, combining or merging multiple PDFs into one, splitting PDFs apart, rotating pages, adding watermarks, creating new PDFs, filling PDF forms, encrypting/decrypting PDFs, extracting images, and OCR on scanned PDFs to make them searchable. If the user mentions a .pdf file or asks to produce one, use this skill.
echo license: Proprietary. LICENSE.txt has complete terms
echo ---
echo 
echo # PDF Processing Guide
echo 
echo ## Overview
echo 
echo This guide covers essential PDF processing operations using Python libraries and command-line tools. For advanced features, JavaScript libraries, and detailed examples, see REFERENCE.md. If you need to fill out a PDF form, read FORMS.md and follow its instructions.
echo 
echo ## Quick Start
echo 
echo ```python
echo from pypdf import PdfReader, PdfWriter
echo 
echo # Read a PDF
echo reader = PdfReader^(^"document.pdf^"^)
echo print^(f^"Pages: {len^(reader.pages^)}^"^)
echo 
echo # Extract text
echo text = ^"^"
echo for page in reader.pages:
echo     text += page.extract_text^(^)
echo ```
echo 
echo ## Python Libraries
echo 
echo ### pypdf - Basic Operations
echo 
echo #### Merge PDFs
echo ```python
echo from pypdf import PdfWriter, PdfReader
echo 
echo writer = PdfWriter^(^)
echo for pdf_file in [^"doc1.pdf^", ^"doc2.pdf^", ^"doc3.pdf^"]:
echo     reader = PdfReader^(pdf_file^)
echo     for page in reader.pages:
echo         writer.add_page^(page^)
echo 
echo with open^(^"merged.pdf^", ^"wb^"^) as output:
echo     writer.write^(output^)
echo ```
echo 
echo #### Split PDF
echo ```python
echo reader = PdfReader^(^"input.pdf^"^)
echo for i, page in enumerate^(reader.pages^):
echo     writer = PdfWriter^(^)
echo     writer.add_page^(page^)
echo     with open^(f^"page_{i+1}.pdf^", ^"wb^"^) as output:
echo         writer.write^(output^)
echo ```
echo 
echo #### Extract Metadata
echo ```python
echo reader = PdfReader^(^"document.pdf^"^)
echo meta = reader.metadata
echo print^(f^"Title: {meta.title}^"^)
echo print^(f^"Author: {meta.author}^"^)
echo print^(f^"Subject: {meta.subject}^"^)
echo print^(f^"Creator: {meta.creator}^"^)
echo ```
echo 
echo #### Rotate Pages
echo ```python
echo reader = PdfReader^(^"input.pdf^"^)
echo writer = PdfWriter^(^)
echo 
echo page = reader.pages[0]
echo page.rotate^(90^)  # Rotate 90 degrees clockwise
echo writer.add_page^(page^)
echo 
echo with open^(^"rotated.pdf^", ^"wb^"^) as output:
echo     writer.write^(output^)
echo ```
echo 
echo ### pdfplumber - Text and Table Extraction
echo 
echo #### Extract Text with Layout
echo ```python
echo import pdfplumber
echo 
echo with pdfplumber.open^(^"document.pdf^"^) as pdf:
echo     for page in pdf.pages:
echo         text = page.extract_text^(^)
echo         print^(text^)
echo ```
echo 
echo #### Extract Tables
echo ```python
echo with pdfplumber.open^(^"document.pdf^"^) as pdf:
echo     for i, page in enumerate^(pdf.pages^):
echo         tables = page.extract_tables^(^)
echo         for j, table in enumerate^(tables^):
echo             print^(f^"Table {j+1} on page {i+1}:^"^)
echo             for row in table:
echo                 print^(row^)
echo ```
echo 
echo #### Advanced Table Extraction
echo ```python
echo import pandas as pd
echo 
echo with pdfplumber.open^(^"document.pdf^"^) as pdf:
echo     all_tables = []
echo     for page in pdf.pages:
echo         tables = page.extract_tables^(^)
echo         for table in tables:
echo             if table:  # Check if table is not empty
echo                 df = pd.DataFrame^(table[1:], columns=table[0]^)
echo                 all_tables.append^(df^)
echo 
echo # Combine all tables
echo if all_tables:
echo     combined_df = pd.concat^(all_tables, ignore_index=True^)
echo     combined_df.to_excel^(^"extracted_tables.xlsx^", index=False^)
echo ```
echo 
echo ### reportlab - Create PDFs
echo 
echo #### Basic PDF Creation
echo ```python
echo from reportlab.lib.pagesizes import letter
echo from reportlab.pdfgen import canvas
echo 
echo c = canvas.Canvas^(^"hello.pdf^", pagesize=letter^)
echo width, height = letter
echo 
echo # Add text
echo c.drawString^(100, height - 100, ^"Hello World!^"^)
echo c.drawString^(100, height - 120, ^"This is a PDF created with reportlab^"^)
echo 
echo # Add a line
echo c.line^(100, height - 140, 400, height - 140^)
echo 
echo # Save
echo c.save^(^)
echo ```
echo 
echo #### Create PDF with Multiple Pages
echo ```python
echo from reportlab.lib.pagesizes import letter
echo from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak
echo from reportlab.lib.styles import getSampleStyleSheet
echo 
echo doc = SimpleDocTemplate^(^"report.pdf^", pagesize=letter^)
echo styles = getSampleStyleSheet^(^)
echo story = []
echo 
echo # Add content
echo title = Paragraph^(^"Report Title^", styles['Title']^)
echo story.append^(title^)
echo story.append^(Spacer^(1, 12^)^)
echo 
echo body = Paragraph^(^"This is the body of the report. ^" * 20, styles['Normal']^)
echo story.append^(body^)
echo story.append^(PageBreak^(^)^)
echo 
echo # Page 2
echo story.append^(Paragraph^(^"Page 2^", styles['Heading1']^)^)
echo story.append^(Paragraph^(^"Content for page 2^", styles['Normal']^)^)
echo 
echo # Build PDF
echo doc.build^(story^)
echo ```
echo 
echo #### Subscripts and Superscripts
echo 
echo **IMPORTANT**: Never use Unicode subscript/superscript characters ^(₀₁₂₃₄₅₆₇₈₉, ⁰¹²³⁴⁵⁶⁷⁸⁹^) in ReportLab PDFs. The built-in fonts do not include these glyphs, causing them to render as solid black boxes.
echo 
echo Instead, use ReportLab's XML markup tags in Paragraph objects:
echo ```python
echo from reportlab.platypus import Paragraph
echo from reportlab.lib.styles import getSampleStyleSheet
echo 
echo styles = getSampleStyleSheet^(^)
echo 
echo # Subscripts: use ^<sub^> tag
echo chemical = Paragraph^(^"H^<sub^>2^</sub^>O^", styles['Normal']^)
echo 
echo # Superscripts: use ^<super^> tag
echo squared = Paragraph^(^"x^<super^>2^</super^> + y^<super^>2^</super^>^", styles['Normal']^)
echo ```
echo 
echo For canvas-drawn text ^(not Paragraph objects^), manually adjust font the size and position rather than using Unicode subscripts/superscripts.
echo 
echo ## Command-Line Tools
echo 
echo ### pdftotext ^(poppler-utils^)
echo ```bash
echo # Extract text
echo pdftotext input.pdf output.txt
echo 
echo # Extract text preserving layout
echo pdftotext -layout input.pdf output.txt
echo 
echo # Extract specific pages
echo pdftotext -f 1 -l 5 input.pdf output.txt  # Pages 1-5
echo ```
echo 
echo ### qpdf
echo ```bash
echo # Merge PDFs
echo qpdf --empty --pages file1.pdf file2.pdf -- merged.pdf
echo 
echo # Split pages
echo qpdf input.pdf --pages . 1-5 -- pages1-5.pdf
echo qpdf input.pdf --pages . 6-10 -- pages6-10.pdf
echo 
echo # Rotate pages
echo qpdf input.pdf output.pdf --rotate=+90:1  # Rotate page 1 by 90 degrees
echo 
echo # Remove password
echo qpdf --password=mypassword --decrypt encrypted.pdf decrypted.pdf
echo ```
echo 
echo ### pdftk ^(if available^)
echo ```bash
echo # Merge
echo pdftk file1.pdf file2.pdf cat output merged.pdf
echo 
echo # Split
echo pdftk input.pdf burst
echo 
echo # Rotate
echo pdftk input.pdf rotate 1east output rotated.pdf
echo ```
echo 
echo ## Common Tasks
echo 
echo ### Extract Text from Scanned PDFs
echo ```python
echo # Requires: pip install pytesseract pdf2image
echo import pytesseract
echo from pdf2image import convert_from_path
echo 
echo # Convert PDF to images
echo images = convert_from_path^('scanned.pdf'^)
echo 
echo # OCR each page
echo text = ^"^"
echo for i, image in enumerate^(images^):
echo     text += f^"Page {i+1}:\n^"
echo     text += pytesseract.image_to_string^(image^)
echo     text += ^"\n\n^"
echo 
echo print^(text^)
echo ```
echo 
echo ### Add Watermark
echo ```python
echo from pypdf import PdfReader, PdfWriter
echo 
echo # Create watermark ^(or load existing^)
echo watermark = PdfReader^(^"watermark.pdf^"^).pages[0]
echo 
echo # Apply to all pages
echo reader = PdfReader^(^"document.pdf^"^)
echo writer = PdfWriter^(^)
echo 
echo for page in reader.pages:
echo     page.merge_page^(watermark^)
echo     writer.add_page^(page^)
echo 
echo with open^(^"watermarked.pdf^", ^"wb^"^) as output:
echo     writer.write^(output^)
echo ```
echo 
echo ### Extract Images
echo ```bash
echo # Using pdfimages ^(poppler-utils^)
echo pdfimages -j input.pdf output_prefix
echo 
echo # This extracts all images as output_prefix-000.jpg, output_prefix-001.jpg, etc.
echo ```
echo 
echo ### Password Protection
echo ```python
echo from pypdf import PdfReader, PdfWriter
echo 
echo reader = PdfReader^(^"input.pdf^"^)
echo writer = PdfWriter^(^)
echo 
echo for page in reader.pages:
echo     writer.add_page^(page^)
echo 
echo # Add password
echo writer.encrypt^(^"userpassword^", ^"ownerpassword^"^)
echo 
echo with open^(^"encrypted.pdf^", ^"wb^"^) as output:
echo     writer.write^(output^)
echo ```
echo 
echo ## Quick Reference
echo 
echo ^| Task ^| Best Tool ^| Command/Code ^|
echo ^|------^|-----------^|--------------^|
echo ^| Merge PDFs ^| pypdf ^| `writer.add_page^(page^)` ^|
echo ^| Split PDFs ^| pypdf ^| One page per file ^|
echo ^| Extract text ^| pdfplumber ^| `page.extract_text^(^)` ^|
echo ^| Extract tables ^| pdfplumber ^| `page.extract_tables^(^)` ^|
echo ^| Create PDFs ^| reportlab ^| Canvas or Platypus ^|
echo ^| Command line merge ^| qpdf ^| `qpdf --empty --pages ...` ^|
echo ^| OCR scanned PDFs ^| pytesseract ^| Convert to image first ^|
echo ^| Fill PDF forms ^| pdf-lib or pypdf ^(see FORMS.md^) ^| See FORMS.md ^|
echo 
echo ## Next Steps
echo 
echo - For advanced pypdfium2 usage, see REFERENCE.md
echo - For JavaScript libraries ^(pdf-lib^), see REFERENCE.md
echo - If you need to fill out a PDF form, follow the instructions in FORMS.md
echo - For troubleshooting guides, see REFERENCE.md
) > "pdf\SKILL.md"
mkdir "pdf\scripts" 2>nul

echo Writing pdf\scripts\check_bounding_boxes.py...
(
echo from dataclasses import dataclass
echo import json
echo import sys
echo 
echo 
echo 
echo 
echo @dataclass
echo class RectAndField:
echo     rect: list[float]
echo     rect_type: str
echo     field: dict
echo 
echo 
echo def get_bounding_box_messages^(fields_json_stream^) -^> list[str]:
echo     messages = []
echo     fields = json.load^(fields_json_stream^)
echo     messages.append^(f^"Read {len^(fields['form_fields']^)} fields^"^)
echo 
echo     def rects_intersect^(r1, r2^):
echo         disjoint_horizontal = r1[0] ^>= r2[2] or r1[2] ^<= r2[0]
echo         disjoint_vertical = r1[1] ^>= r2[3] or r1[3] ^<= r2[1]
echo         return not ^(disjoint_horizontal or disjoint_vertical^)
echo 
echo     rects_and_fields = []
echo     for f in fields[^"form_fields^"]:
echo         rects_and_fields.append^(RectAndField^(f[^"label_bounding_box^"], ^"label^", f^)^)
echo         rects_and_fields.append^(RectAndField^(f[^"entry_bounding_box^"], ^"entry^", f^)^)
echo 
echo     has_error = False
echo     for i, ri in enumerate^(rects_and_fields^):
echo         for j in range^(i + 1, len^(rects_and_fields^)^):
echo             rj = rects_and_fields[j]
echo             if ri.field[^"page_number^"] == rj.field[^"page_number^"] and rects_intersect^(ri.rect, rj.rect^):
echo                 has_error = True
echo                 if ri.field is rj.field:
echo                     messages.append^(f^"FAILURE: intersection between label and entry bounding boxes for `{ri.field['description']}` ^({ri.rect}, {rj.rect}^)^"^)
echo                 else:
echo                     messages.append^(f^"FAILURE: intersection between {ri.rect_type} bounding box for `{ri.field['description']}` ^({ri.rect}^) and {rj.rect_type} bounding box for `{rj.field['description']}` ^({rj.rect}^)^"^)
echo                 if len^(messages^) ^>= 20:
echo                     messages.append^(^"Aborting further checks; fix bounding boxes and try again^"^)
echo                     return messages
echo         if ri.rect_type == ^"entry^":
echo             if ^"entry_text^" in ri.field:
echo                 font_size = ri.field[^"entry_text^"].get^(^"font_size^", 14^)
echo                 entry_height = ri.rect[3] - ri.rect[1]
echo                 if entry_height ^< font_size:
echo                     has_error = True
echo                     messages.append^(f^"FAILURE: entry bounding box height ^({entry_height}^) for `{ri.field['description']}` is too short for the text content ^(font size: {font_size}^). Increase the box height or decrease the font size.^"^)
echo                     if len^(messages^) ^>= 20:
echo                         messages.append^(^"Aborting further checks; fix bounding boxes and try again^"^)
echo                         return messages
echo 
echo     if not has_error:
echo         messages.append^(^"SUCCESS: All bounding boxes are valid^"^)
echo     return messages
echo 
echo if __name__ == ^"__main__^":
echo     if len^(sys.argv^) != 2:
echo         print^(^"Usage: check_bounding_boxes.py [fields.json]^"^)
echo         sys.exit^(1^)
echo     with open^(sys.argv[1]^) as f:
echo         messages = get_bounding_box_messages^(f^)
echo     for msg in messages:
echo         print^(msg^)
) > "pdf\scripts\check_bounding_boxes.py"

echo Writing pdf\scripts\check_fillable_fields.py...
(
echo import sys
echo from pypdf import PdfReader
echo 
echo 
echo 
echo 
echo reader = PdfReader^(sys.argv[1]^)
echo if ^(reader.get_fields^(^)^):
echo     print^(^"This PDF has fillable form fields^"^)
echo else:
echo     print^(^"This PDF does not have fillable form fields; you will need to visually determine where to enter data^"^)
) > "pdf\scripts\check_fillable_fields.py"

echo Writing pdf\scripts\convert_pdf_to_images.py...
(
echo import os
echo import sys
echo 
echo from pdf2image import convert_from_path
echo 
echo 
echo 
echo 
echo def convert^(pdf_path, output_dir, max_dim=1000^):
echo     images = convert_from_path^(pdf_path, dpi=200^)
echo 
echo     for i, image in enumerate^(images^):
echo         width, height = image.size
echo         if width ^> max_dim or height ^> max_dim:
echo             scale_factor = min^(max_dim / width, max_dim / height^)
echo             new_width = int^(width * scale_factor^)
echo             new_height = int^(height * scale_factor^)
echo             image = image.resize^(^(new_width, new_height^)^)
echo         
echo         image_path = os.path.join^(output_dir, f^"page_{i+1}.png^"^)
echo         image.save^(image_path^)
echo         print^(f^"Saved page {i+1} as {image_path} ^(size: {image.size}^)^"^)
echo 
echo     print^(f^"Converted {len^(images^)} pages to PNG images^"^)
echo 
echo 
echo if __name__ == ^"__main__^":
echo     if len^(sys.argv^) != 3:
echo         print^(^"Usage: convert_pdf_to_images.py [input pdf] [output directory]^"^)
echo         sys.exit^(1^)
echo     pdf_path = sys.argv[1]
echo     output_directory = sys.argv[2]
echo     convert^(pdf_path, output_directory^)
) > "pdf\scripts\convert_pdf_to_images.py"

echo Writing pdf\scripts\create_validation_image.py...
(
echo import json
echo import sys
echo 
echo from PIL import Image, ImageDraw
echo 
echo 
echo 
echo 
echo def create_validation_image^(page_number, fields_json_path, input_path, output_path^):
echo     with open^(fields_json_path, 'r'^) as f:
echo         data = json.load^(f^)
echo 
echo         img = Image.open^(input_path^)
echo         draw = ImageDraw.Draw^(img^)
echo         num_boxes = 0
echo         
echo         for field in data[^"form_fields^"]:
echo             if field[^"page_number^"] == page_number:
echo                 entry_box = field['entry_bounding_box']
echo                 label_box = field['label_bounding_box']
echo                 draw.rectangle^(entry_box, outline='red', width=2^)
echo                 draw.rectangle^(label_box, outline='blue', width=2^)
echo                 num_boxes += 2
echo         
echo         img.save^(output_path^)
echo         print^(f^"Created validation image at {output_path} with {num_boxes} bounding boxes^"^)
echo 
echo 
echo if __name__ == ^"__main__^":
echo     if len^(sys.argv^) != 5:
echo         print^(^"Usage: create_validation_image.py [page number] [fields.json file] [input image path] [output image path]^"^)
echo         sys.exit^(1^)
echo     page_number = int^(sys.argv[1]^)
echo     fields_json_path = sys.argv[2]
echo     input_image_path = sys.argv[3]
echo     output_image_path = sys.argv[4]
echo     create_validation_image^(page_number, fields_json_path, input_image_path, output_image_path^)
) > "pdf\scripts\create_validation_image.py"

echo Writing pdf\scripts\extract_form_field_info.py...
(
echo import json
echo import sys
echo 
echo from pypdf import PdfReader
echo 
echo 
echo 
echo 
echo def get_full_annotation_field_id^(annotation^):
echo     components = []
echo     while annotation:
echo         field_name = annotation.get^('/T'^)
echo         if field_name:
echo             components.append^(field_name^)
echo         annotation = annotation.get^('/Parent'^)
echo     return ^".^".join^(reversed^(components^)^) if components else None
echo 
echo 
echo def make_field_dict^(field, field_id^):
echo     field_dict = {^"field_id^": field_id}
echo     ft = field.get^('/FT'^)
echo     if ft == ^"/Tx^":
echo         field_dict[^"type^"] = ^"text^"
echo     elif ft == ^"/Btn^":
echo         field_dict[^"type^"] = ^"checkbox^"  
echo         states = field.get^(^"/_States_^", []^)
echo         if len^(states^) == 2:
echo             if ^"/Off^" in states:
echo                 field_dict[^"checked_value^"] = states[0] if states[0] != ^"/Off^" else states[1]
echo                 field_dict[^"unchecked_value^"] = ^"/Off^"
echo             else:
echo                 print^(f^"Unexpected state values for checkbox `${field_id}`. Its checked and unchecked values may not be correct; if you're trying to check it, visually verify the results.^"^)
echo                 field_dict[^"checked_value^"] = states[0]
echo                 field_dict[^"unchecked_value^"] = states[1]
echo     elif ft == ^"/Ch^":
echo         field_dict[^"type^"] = ^"choice^"
echo         states = field.get^(^"/_States_^", []^)
echo         field_dict[^"choice_options^"] = [{
echo             ^"value^": state[0],
echo             ^"text^": state[1],
echo         } for state in states]
echo     else:
echo         field_dict[^"type^"] = f^"unknown ^({ft}^)^"
echo     return field_dict
echo 
echo 
echo def get_field_info^(reader: PdfReader^):
echo     fields = reader.get_fields^(^)
echo 
echo     field_info_by_id = {}
echo     possible_radio_names = set^(^)
echo 
echo     for field_id, field in fields.items^(^):
echo         if field.get^(^"/Kids^"^):
echo             if field.get^(^"/FT^"^) == ^"/Btn^":
echo                 possible_radio_names.add^(field_id^)
echo             continue
echo         field_info_by_id[field_id] = make_field_dict^(field, field_id^)
echo 
echo 
echo     radio_fields_by_id = {}
echo 
echo     for page_index, page in enumerate^(reader.pages^):
echo         annotations = page.get^('/Annots', []^)
echo         for ann in annotations:
echo             field_id = get_full_annotation_field_id^(ann^)
echo             if field_id in field_info_by_id:
echo                 field_info_by_id[field_id][^"page^"] = page_index + 1
echo                 field_info_by_id[field_id][^"rect^"] = ann.get^('/Rect'^)
echo             elif field_id in possible_radio_names:
echo                 try:
echo                     on_values = [v for v in ann[^"/AP^"][^"/N^"] if v != ^"/Off^"]
echo                 except KeyError:
echo                     continue
echo                 if len^(on_values^) == 1:
echo                     rect = ann.get^(^"/Rect^"^)
echo                     if field_id not in radio_fields_by_id:
echo                         radio_fields_by_id[field_id] = {
echo                             ^"field_id^": field_id,
echo                             ^"type^": ^"radio_group^",
echo                             ^"page^": page_index + 1,
echo                             ^"radio_options^": [],
echo                         }
echo                     radio_fields_by_id[field_id][^"radio_options^"].append^({
echo                         ^"value^": on_values[0],
echo                         ^"rect^": rect,
echo                     }^)
echo 
echo     fields_with_location = []
echo     for field_info in field_info_by_id.values^(^):
echo         if ^"page^" in field_info:
echo             fields_with_location.append^(field_info^)
echo         else:
echo             print^(f^"Unable to determine location for field id: {field_info.get^('field_id'^)}, ignoring^"^)
echo 
echo     def sort_key^(f^):
echo         if ^"radio_options^" in f:
echo             rect = f[^"radio_options^"][0][^"rect^"] or [0, 0, 0, 0]
echo         else:
echo             rect = f.get^(^"rect^"^) or [0, 0, 0, 0]
echo         adjusted_position = [-rect[1], rect[0]]
echo         return [f.get^(^"page^"^), adjusted_position]
echo     
echo     sorted_fields = fields_with_location + list^(radio_fields_by_id.values^(^)^)
echo     sorted_fields.sort^(key=sort_key^)
echo 
echo     return sorted_fields
echo 
echo 
echo def write_field_info^(pdf_path: str, json_output_path: str^):
echo     reader = PdfReader^(pdf_path^)
echo     field_info = get_field_info^(reader^)
echo     with open^(json_output_path, ^"w^"^) as f:
echo         json.dump^(field_info, f, indent=2^)
echo     print^(f^"Wrote {len^(field_info^)} fields to {json_output_path}^"^)
echo 
echo 
echo if __name__ == ^"__main__^":
echo     if len^(sys.argv^) != 3:
echo         print^(^"Usage: extract_form_field_info.py [input pdf] [output json]^"^)
echo         sys.exit^(1^)
echo     write_field_info^(sys.argv[1], sys.argv[2]^)
) > "pdf\scripts\extract_form_field_info.py"

echo Writing pdf\scripts\extract_form_structure.py...
(
echo ^"^"^"
echo Extract form structure from a non-fillable PDF.
echo 
echo This script analyzes the PDF to find:
echo - Text labels with their exact coordinates
echo - Horizontal lines ^(row boundaries^)
echo - Checkboxes ^(small rectangles^)
echo 
echo Output: A JSON file with the form structure that can be used to generate
echo accurate field coordinates for filling.
echo 
echo Usage: python extract_form_structure.py ^<input.pdf^> ^<output.json^>
echo ^"^"^"
echo 
echo import json
echo import sys
echo import pdfplumber
echo 
echo 
echo def extract_form_structure^(pdf_path^):
echo     structure = {
echo         ^"pages^": [],
echo         ^"labels^": [],
echo         ^"lines^": [],
echo         ^"checkboxes^": [],
echo         ^"row_boundaries^": []
echo     }
echo 
echo     with pdfplumber.open^(pdf_path^) as pdf:
echo         for page_num, page in enumerate^(pdf.pages, 1^):
echo             structure[^"pages^"].append^({
echo                 ^"page_number^": page_num,
echo                 ^"width^": float^(page.width^),
echo                 ^"height^": float^(page.height^)
echo             }^)
echo 
echo             words = page.extract_words^(^)
echo             for word in words:
echo                 structure[^"labels^"].append^({
echo                     ^"page^": page_num,
echo                     ^"text^": word[^"text^"],
echo                     ^"x0^": round^(float^(word[^"x0^"]^), 1^),
echo                     ^"top^": round^(float^(word[^"top^"]^), 1^),
echo                     ^"x1^": round^(float^(word[^"x1^"]^), 1^),
echo                     ^"bottom^": round^(float^(word[^"bottom^"]^), 1^)
echo                 }^)
echo 
echo             for line in page.lines:
echo                 if abs^(float^(line[^"x1^"]^) - float^(line[^"x0^"]^)^) ^> page.width * 0.5:
echo                     structure[^"lines^"].append^({
echo                         ^"page^": page_num,
echo                         ^"y^": round^(float^(line[^"top^"]^), 1^),
echo                         ^"x0^": round^(float^(line[^"x0^"]^), 1^),
echo                         ^"x1^": round^(float^(line[^"x1^"]^), 1^)
echo                     }^)
echo 
echo             for rect in page.rects:
echo                 width = float^(rect[^"x1^"]^) - float^(rect[^"x0^"]^)
echo                 height = float^(rect[^"bottom^"]^) - float^(rect[^"top^"]^)
echo                 if 5 ^<= width ^<= 15 and 5 ^<= height ^<= 15 and abs^(width - height^) ^< 2:
echo                     structure[^"checkboxes^"].append^({
echo                         ^"page^": page_num,
echo                         ^"x0^": round^(float^(rect[^"x0^"]^), 1^),
echo                         ^"top^": round^(float^(rect[^"top^"]^), 1^),
echo                         ^"x1^": round^(float^(rect[^"x1^"]^), 1^),
echo                         ^"bottom^": round^(float^(rect[^"bottom^"]^), 1^),
echo                         ^"center_x^": round^(^(float^(rect[^"x0^"]^) + float^(rect[^"x1^"]^)^) / 2, 1^),
echo                         ^"center_y^": round^(^(float^(rect[^"top^"]^) + float^(rect[^"bottom^"]^)^) / 2, 1^)
echo                     }^)
echo 
echo     lines_by_page = {}
echo     for line in structure[^"lines^"]:
echo         page = line[^"page^"]
echo         if page not in lines_by_page:
echo             lines_by_page[page] = []
echo         lines_by_page[page].append^(line[^"y^"]^)
echo 
echo     for page, y_coords in lines_by_page.items^(^):
echo         y_coords = sorted^(set^(y_coords^)^)
echo         for i in range^(len^(y_coords^) - 1^):
echo             structure[^"row_boundaries^"].append^({
echo                 ^"page^": page,
echo                 ^"row_top^": y_coords[i],
echo                 ^"row_bottom^": y_coords[i + 1],
echo                 ^"row_height^": round^(y_coords[i + 1] - y_coords[i], 1^)
echo             }^)
echo 
echo     return structure
echo 
echo 
echo def main^(^):
echo     if len^(sys.argv^) != 3:
echo         print^(^"Usage: extract_form_structure.py ^<input.pdf^> ^<output.json^>^"^)
echo         sys.exit^(1^)
echo 
echo     pdf_path = sys.argv[1]
echo     output_path = sys.argv[2]
echo 
echo     print^(f^"Extracting structure from {pdf_path}...^"^)
echo     structure = extract_form_structure^(pdf_path^)
echo 
echo     with open^(output_path, ^"w^"^) as f:
echo         json.dump^(structure, f, indent=2^)
echo 
echo     print^(f^"Found:^"^)
echo     print^(f^"  - {len^(structure['pages']^)} pages^"^)
echo     print^(f^"  - {len^(structure['labels']^)} text labels^"^)
echo     print^(f^"  - {len^(structure['lines']^)} horizontal lines^"^)
echo     print^(f^"  - {len^(structure['checkboxes']^)} checkboxes^"^)
echo     print^(f^"  - {len^(structure['row_boundaries']^)} row boundaries^"^)
echo     print^(f^"Saved to {output_path}^"^)
echo 
echo 
echo if __name__ == ^"__main__^":
echo     main^(^)
) > "pdf\scripts\extract_form_structure.py"

echo Writing pdf\scripts\fill_fillable_fields.py...
(
echo import json
echo import sys
echo 
echo from pypdf import PdfReader, PdfWriter
echo 
echo from extract_form_field_info import get_field_info
echo 
echo 
echo 
echo 
echo def fill_pdf_fields^(input_pdf_path: str, fields_json_path: str, output_pdf_path: str^):
echo     with open^(fields_json_path^) as f:
echo         fields = json.load^(f^)
echo     fields_by_page = {}
echo     for field in fields:
echo         if ^"value^" in field:
echo             field_id = field[^"field_id^"]
echo             page = field[^"page^"]
echo             if page not in fields_by_page:
echo                 fields_by_page[page] = {}
echo             fields_by_page[page][field_id] = field[^"value^"]
echo     
echo     reader = PdfReader^(input_pdf_path^)
echo 
echo     has_error = False
echo     field_info = get_field_info^(reader^)
echo     fields_by_ids = {f[^"field_id^"]: f for f in field_info}
echo     for field in fields:
echo         existing_field = fields_by_ids.get^(field[^"field_id^"]^)
echo         if not existing_field:
echo             has_error = True
echo             print^(f^"ERROR: `{field['field_id']}` is not a valid field ID^"^)
echo         elif field[^"page^"] != existing_field[^"page^"]:
echo             has_error = True
echo             print^(f^"ERROR: Incorrect page number for `{field['field_id']}` ^(got {field['page']}, expected {existing_field['page']}^)^"^)
echo         else:
echo             if ^"value^" in field:
echo                 err = validation_error_for_field_value^(existing_field, field[^"value^"]^)
echo                 if err:
echo                     print^(err^)
echo                     has_error = True
echo     if has_error:
echo         sys.exit^(1^)
echo 
echo     writer = PdfWriter^(clone_from=reader^)
echo     for page, field_values in fields_by_page.items^(^):
echo         writer.update_page_form_field_values^(writer.pages[page - 1], field_values, auto_regenerate=False^)
echo 
echo     writer.set_need_appearances_writer^(True^)
echo     
echo     with open^(output_pdf_path, ^"wb^"^) as f:
echo         writer.write^(f^)
echo 
echo 
echo def validation_error_for_field_value^(field_info, field_value^):
echo     field_type = field_info[^"type^"]
echo     field_id = field_info[^"field_id^"]
echo     if field_type == ^"checkbox^":
echo         checked_val = field_info[^"checked_value^"]
echo         unchecked_val = field_info[^"unchecked_value^"]
echo         if field_value != checked_val and field_value != unchecked_val:
echo             return f'ERROR: Invalid value ^"{field_value}^" for checkbox field ^"{field_id}^". The checked value is ^"{checked_val}^" and the unchecked value is ^"{unchecked_val}^"'
echo     elif field_type == ^"radio_group^":
echo         option_values = [opt[^"value^"] for opt in field_info[^"radio_options^"]]
echo         if field_value not in option_values:
echo             return f'ERROR: Invalid value ^"{field_value}^" for radio group field ^"{field_id}^". Valid values are: {option_values}' 
echo     elif field_type == ^"choice^":
echo         choice_values = [opt[^"value^"] for opt in field_info[^"choice_options^"]]
echo         if field_value not in choice_values:
echo             return f'ERROR: Invalid value ^"{field_value}^" for choice field ^"{field_id}^". Valid values are: {choice_values}'
echo     return None
echo 
echo 
echo def monkeypatch_pydpf_method^(^):
echo     from pypdf.generic import DictionaryObject
echo     from pypdf.constants import FieldDictionaryAttributes
echo 
echo     original_get_inherited = DictionaryObject.get_inherited
echo 
echo     def patched_get_inherited^(self, key: str, default = None^):
echo         result = original_get_inherited^(self, key, default^)
echo         if key == FieldDictionaryAttributes.Opt:
echo             if isinstance^(result, list^) and all^(isinstance^(v, list^) and len^(v^) == 2 for v in result^):
echo                 result = [r[0] for r in result]
echo         return result
echo 
echo     DictionaryObject.get_inherited = patched_get_inherited
echo 
echo 
echo if __name__ == ^"__main__^":
echo     if len^(sys.argv^) != 4:
echo         print^(^"Usage: fill_fillable_fields.py [input pdf] [field_values.json] [output pdf]^"^)
echo         sys.exit^(1^)
echo     monkeypatch_pydpf_method^(^)
echo     input_pdf = sys.argv[1]
echo     fields_json = sys.argv[2]
echo     output_pdf = sys.argv[3]
echo     fill_pdf_fields^(input_pdf, fields_json, output_pdf^)
) > "pdf\scripts\fill_fillable_fields.py"

echo Writing pdf\scripts\fill_pdf_form_with_annotations.py...
(
echo import json
echo import sys
echo 
echo from pypdf import PdfReader, PdfWriter
echo from pypdf.annotations import FreeText
echo 
echo 
echo 
echo 
echo def transform_from_image_coords^(bbox, image_width, image_height, pdf_width, pdf_height^):
echo     x_scale = pdf_width / image_width
echo     y_scale = pdf_height / image_height
echo 
echo     left = bbox[0] * x_scale
echo     right = bbox[2] * x_scale
echo 
echo     top = pdf_height - ^(bbox[1] * y_scale^)
echo     bottom = pdf_height - ^(bbox[3] * y_scale^)
echo 
echo     return left, bottom, right, top
echo 
echo 
echo def transform_from_pdf_coords^(bbox, pdf_height^):
echo     left = bbox[0]
echo     right = bbox[2]
echo 
echo     pypdf_top = pdf_height - bbox[1]      
echo     pypdf_bottom = pdf_height - bbox[3]   
echo 
echo     return left, pypdf_bottom, right, pypdf_top
echo 
echo 
echo def fill_pdf_form^(input_pdf_path, fields_json_path, output_pdf_path^):
echo     
echo     with open^(fields_json_path, ^"r^"^) as f:
echo         fields_data = json.load^(f^)
echo     
echo     reader = PdfReader^(input_pdf_path^)
echo     writer = PdfWriter^(^)
echo     
echo     writer.append^(reader^)
echo     
echo     pdf_dimensions = {}
echo     for i, page in enumerate^(reader.pages^):
echo         mediabox = page.mediabox
echo         pdf_dimensions[i + 1] = [mediabox.width, mediabox.height]
echo     
echo     annotations = []
echo     for field in fields_data[^"form_fields^"]:
echo         page_num = field[^"page_number^"]
echo 
echo         page_info = next^(p for p in fields_data[^"pages^"] if p[^"page_number^"] == page_num^)
echo         pdf_width, pdf_height = pdf_dimensions[page_num]
echo 
echo         if ^"pdf_width^" in page_info:
echo             transformed_entry_box = transform_from_pdf_coords^(
echo                 field[^"entry_bounding_box^"],
echo                 float^(pdf_height^)
echo             ^)
echo         else:
echo             image_width = page_info[^"image_width^"]
echo             image_height = page_info[^"image_height^"]
echo             transformed_entry_box = transform_from_image_coords^(
echo                 field[^"entry_bounding_box^"],
echo                 image_width, image_height,
echo                 float^(pdf_width^), float^(pdf_height^)
echo             ^)
echo         
echo         if ^"entry_text^" not in field or ^"text^" not in field[^"entry_text^"]:
echo             continue
echo         entry_text = field[^"entry_text^"]
echo         text = entry_text[^"text^"]
echo         if not text:
echo             continue
echo         
echo         font_name = entry_text.get^(^"font^", ^"Arial^"^)
echo         font_size = str^(entry_text.get^(^"font_size^", 14^)^) + ^"pt^"
echo         font_color = entry_text.get^(^"font_color^", ^"000000^"^)
echo 
echo         annotation = FreeText^(
echo             text=text,
echo             rect=transformed_entry_box,
echo             font=font_name,
echo             font_size=font_size,
echo             font_color=font_color,
echo             border_color=None,
echo             background_color=None,
echo         ^)
echo         annotations.append^(annotation^)
echo         writer.add_annotation^(page_number=page_num - 1, annotation=annotation^)
echo         
echo     with open^(output_pdf_path, ^"wb^"^) as output:
echo         writer.write^(output^)
echo     
echo     print^(f^"Successfully filled PDF form and saved to {output_pdf_path}^"^)
echo     print^(f^"Added {len^(annotations^)} text annotations^"^)
echo 
echo 
echo if __name__ == ^"__main__^":
echo     if len^(sys.argv^) != 4:
echo         print^(^"Usage: fill_pdf_form_with_annotations.py [input pdf] [fields.json] [output pdf]^"^)
echo         sys.exit^(1^)
echo     input_pdf = sys.argv[1]
echo     fields_json = sys.argv[2]
echo     output_pdf = sys.argv[3]
echo     
echo     fill_pdf_form^(input_pdf, fields_json, output_pdf^)
) > "pdf\scripts\fill_pdf_form_with_annotations.py"

echo.
echo Done! pdf files created.
pause