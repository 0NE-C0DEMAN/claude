@echo off
echo Creating frontend-design skill files...

mkdir "frontend-design" 2>nul

echo Writing frontend-design\LICENSE.txt...
(
echo 
echo                                  Apache License
echo                            Version 2.0, January 2004
echo                         http://www.apache.org/licenses/
echo 
echo    TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION
echo 
echo    1. Definitions.
echo 
echo       ^"License^" shall mean the terms and conditions for use, reproduction,
echo       and distribution as defined by Sections 1 through 9 of this document.
echo 
echo       ^"Licensor^" shall mean the copyright owner or entity authorized by
echo       the copyright owner that is granting the License.
echo 
echo       ^"Legal Entity^" shall mean the union of the acting entity and all
echo       other entities that control, are controlled by, or are under common
echo       control with that entity. For the purposes of this definition,
echo       ^"control^" means ^(i^) the power, direct or indirect, to cause the
echo       direction or management of such entity, whether by contract or
echo       otherwise, or ^(ii^) ownership of fifty percent ^(50%%^) or more of the
echo       outstanding shares, or ^(iii^) beneficial ownership of such entity.
echo 
echo       ^"You^" ^(or ^"Your^"^) shall mean an individual or Legal Entity
echo       exercising permissions granted by this License.
echo 
echo       ^"Source^" form shall mean the preferred form for making modifications,
echo       including but not limited to software source code, documentation
echo       source, and configuration files.
echo 
echo       ^"Object^" form shall mean any form resulting from mechanical
echo       transformation or translation of a Source form, including but
echo       not limited to compiled object code, generated documentation,
echo       and conversions to other media types.
echo 
echo       ^"Work^" shall mean the work of authorship, whether in Source or
echo       Object form, made available under the License, as indicated by a
echo       copyright notice that is included in or attached to the work
echo       ^(an example is provided in the Appendix below^).
echo 
echo       ^"Derivative Works^" shall mean any work, whether in Source or Object
echo       form, that is based on ^(or derived from^) the Work and for which the
echo       editorial revisions, annotations, elaborations, or other modifications
echo       represent, as a whole, an original work of authorship. For the purposes
echo       of this License, Derivative Works shall not include works that remain
echo       separable from, or merely link ^(or bind by name^) to the interfaces of,
echo       the Work and Derivative Works thereof.
echo 
echo       ^"Contribution^" shall mean any work of authorship, including
echo       the original version of the Work and any modifications or additions
echo       to that Work or Derivative Works thereof, that is intentionally
echo       submitted to Licensor for inclusion in the Work by the copyright owner
echo       or by an individual or Legal Entity authorized to submit on behalf of
echo       the copyright owner. For the purposes of this definition, ^"submitted^"
echo       means any form of electronic, verbal, or written communication sent
echo       to the Licensor or its representatives, including but not limited to
echo       communication on electronic mailing lists, source code control systems,
echo       and issue tracking systems that are managed by, or on behalf of, the
echo       Licensor for the purpose of discussing and improving the Work, but
echo       excluding communication that is conspicuously marked or otherwise
echo       designated in writing by the copyright owner as ^"Not a Contribution.^"
echo 
echo       ^"Contributor^" shall mean Licensor and any individual or Legal Entity
echo       on behalf of whom a Contribution has been received by Licensor and
echo       subsequently incorporated within the Work.
echo 
echo    2. Grant of Copyright License. Subject to the terms and conditions of
echo       this License, each Contributor hereby grants to You a perpetual,
echo       worldwide, non-exclusive, no-charge, royalty-free, irrevocable
echo       copyright license to reproduce, prepare Derivative Works of,
echo       publicly display, publicly perform, sublicense, and distribute the
echo       Work and such Derivative Works in Source or Object form.
echo 
echo    3. Grant of Patent License. Subject to the terms and conditions of
echo       this License, each Contributor hereby grants to You a perpetual,
echo       worldwide, non-exclusive, no-charge, royalty-free, irrevocable
echo       ^(except as stated in this section^) patent license to make, have made,
echo       use, offer to sell, sell, import, and otherwise transfer the Work,
echo       where such license applies only to those patent claims licensable
echo       by such Contributor that are necessarily infringed by their
echo       Contribution^(s^) alone or by combination of their Contribution^(s^)
echo       with the Work to which such Contribution^(s^) was submitted. If You
echo       institute patent litigation against any entity ^(including a
echo       cross-claim or counterclaim in a lawsuit^) alleging that the Work
echo       or a Contribution incorporated within the Work constitutes direct
echo       or contributory patent infringement, then any patent licenses
echo       granted to You under this License for that Work shall terminate
echo       as of the date such litigation is filed.
echo 
echo    4. Redistribution. You may reproduce and distribute copies of the
echo       Work or Derivative Works thereof in any medium, with or without
echo       modifications, and in Source or Object form, provided that You
echo       meet the following conditions:
echo 
echo       ^(a^) You must give any other recipients of the Work or
echo           Derivative Works a copy of this License; and
echo 
echo       ^(b^) You must cause any modified files to carry prominent notices
echo           stating that You changed the files; and
echo 
echo       ^(c^) You must retain, in the Source form of any Derivative Works
echo           that You distribute, all copyright, patent, trademark, and
echo           attribution notices from the Source form of the Work,
echo           excluding those notices that do not pertain to any part of
echo           the Derivative Works; and
echo 
echo       ^(d^) If the Work includes a ^"NOTICE^" text file as part of its
echo           distribution, then any Derivative Works that You distribute must
echo           include a readable copy of the attribution notices contained
echo           within such NOTICE file, excluding those notices that do not
echo           pertain to any part of the Derivative Works, in at least one
echo           of the following places: within a NOTICE text file distributed
echo           as part of the Derivative Works; within the Source form or
echo           documentation, if provided along with the Derivative Works; or,
echo           within a display generated by the Derivative Works, if and
echo           wherever such third-party notices normally appear. The contents
echo           of the NOTICE file are for informational purposes only and
echo           do not modify the License. You may add Your own attribution
echo           notices within Derivative Works that You distribute, alongside
echo           or as an addendum to the NOTICE text from the Work, provided
echo           that such additional attribution notices cannot be construed
echo           as modifying the License.
echo 
echo       You may add Your own copyright statement to Your modifications and
echo       may provide additional or different license terms and conditions
echo       for use, reproduction, or distribution of Your modifications, or
echo       for any such Derivative Works as a whole, provided Your use,
echo       reproduction, and distribution of the Work otherwise complies with
echo       the conditions stated in this License.
echo 
echo    5. Submission of Contributions. Unless You explicitly state otherwise,
echo       any Contribution intentionally submitted for inclusion in the Work
echo       by You to the Licensor shall be under the terms and conditions of
echo       this License, without any additional terms or conditions.
echo       Notwithstanding the above, nothing herein shall supersede or modify
echo       the terms of any separate license agreement you may have executed
echo       with Licensor regarding such Contributions.
echo 
echo    6. Trademarks. This License does not grant permission to use the trade
echo       names, trademarks, service marks, or product names of the Licensor,
echo       except as required for reasonable and customary use in describing the
echo       origin of the Work and reproducing the content of the NOTICE file.
echo 
echo    7. Disclaimer of Warranty. Unless required by applicable law or
echo       agreed to in writing, Licensor provides the Work ^(and each
echo       Contributor provides its Contributions^) on an ^"AS IS^" BASIS,
echo       WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
echo       implied, including, without limitation, any warranties or conditions
echo       of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
echo       PARTICULAR PURPOSE. You are solely responsible for determining the
echo       appropriateness of using or redistributing the Work and assume any
echo       risks associated with Your exercise of permissions under this License.
echo 
echo    8. Limitation of Liability. In no event and under no legal theory,
echo       whether in tort ^(including negligence^), contract, or otherwise,
echo       unless required by applicable law ^(such as deliberate and grossly
echo       negligent acts^) or agreed to in writing, shall any Contributor be
echo       liable to You for damages, including any direct, indirect, special,
echo       incidental, or consequential damages of any character arising as a
echo       result of this License or out of the use or inability to use the
echo       Work ^(including but not limited to damages for loss of goodwill,
echo       work stoppage, computer failure or malfunction, or any and all
echo       other commercial damages or losses^), even if such Contributor
echo       has been advised of the possibility of such damages.
echo 
echo    9. Accepting Warranty or Additional Liability. While redistributing
echo       the Work or Derivative Works thereof, You may choose to offer,
echo       and charge a fee for, acceptance of support, warranty, indemnity,
echo       or other liability obligations and/or rights consistent with this
echo       License. However, in accepting such obligations, You may act only
echo       on Your own behalf and on Your sole responsibility, not on behalf
echo       of any other Contributor, and only if You agree to indemnify,
echo       defend, and hold each Contributor harmless for any liability
echo       incurred by, or claims asserted against, such Contributor by reason
echo       of your accepting any such warranty or additional liability.
echo 
echo    END OF TERMS AND CONDITIONS
) > "frontend-design\LICENSE.txt"

echo Writing frontend-design\SKILL.md...
(
echo ---
echo name: frontend-design
echo description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, artifacts, posters, or applications ^(examples include websites, landing pages, dashboards, React components, HTML/CSS layouts, or when styling/beautifying any web UI^). Generates creative, polished code and UI design that avoids generic AI aesthetics.
echo license: Complete terms in LICENSE.txt
echo ---
echo 
echo This skill guides creation of distinctive, production-grade frontend interfaces that avoid generic ^"AI slop^" aesthetics. Implement real working code with exceptional attention to aesthetic details and creative choices.
echo 
echo The user provides frontend requirements: a component, page, application, or interface to build. They may include context about the purpose, audience, or technical constraints.
echo 
echo ## Design Thinking
echo 
echo Before coding, understand the context and commit to a BOLD aesthetic direction:
echo - **Purpose**: What problem does this interface solve? Who uses it?
echo - **Tone**: Pick an extreme: brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel, industrial/utilitarian, etc. There are so many flavors to choose from. Use these for inspiration but design one that is true to the aesthetic direction.
echo - **Constraints**: Technical requirements ^(framework, performance, accessibility^).
echo - **Differentiation**: What makes this UNFORGETTABLE? What's the one thing someone will remember?
echo 
echo **CRITICAL**: Choose a clear conceptual direction and execute it with precision. Bold maximalism and refined minimalism both work - the key is intentionality, not intensity.
echo 
echo Then implement working code ^(HTML/CSS/JS, React, Vue, etc.^) that is:
echo - Production-grade and functional
echo - Visually striking and memorable
echo - Cohesive with a clear aesthetic point-of-view
echo - Meticulously refined in every detail
echo 
echo ## Frontend Aesthetics Guidelines
echo 
echo Focus on:
echo - **Typography**: Choose fonts that are beautiful, unique, and interesting. Avoid generic fonts like Arial and Inter; opt instead for distinctive choices that elevate the frontend's aesthetics; unexpected, characterful font choices. Pair a distinctive display font with a refined body font.
echo - **Color ^& Theme**: Commit to a cohesive aesthetic. Use CSS variables for consistency. Dominant colors with sharp accents outperform timid, evenly-distributed palettes.
echo - **Motion**: Use animations for effects and micro-interactions. Prioritize CSS-only solutions for HTML. Use Motion library for React when available. Focus on high-impact moments: one well-orchestrated page load with staggered reveals ^(animation-delay^) creates more delight than scattered micro-interactions. Use scroll-triggering and hover states that surprise.
echo - **Spatial Composition**: Unexpected layouts. Asymmetry. Overlap. Diagonal flow. Grid-breaking elements. Generous negative space OR controlled density.
echo - **Backgrounds ^& Visual Details**: Create atmosphere and depth rather than defaulting to solid colors. Add contextual effects and textures that match the overall aesthetic. Apply creative forms like gradient meshes, noise textures, geometric patterns, layered transparencies, dramatic shadows, decorative borders, custom cursors, and grain overlays.
echo 
echo NEVER use generic AI-generated aesthetics like overused font families ^(Inter, Roboto, Arial, system fonts^), cliched color schemes ^(particularly purple gradients on white backgrounds^), predictable layouts and component patterns, and cookie-cutter design that lacks context-specific character.
echo 
echo Interpret creatively and make unexpected choices that feel genuinely designed for the context. No design should be the same. Vary between light and dark themes, different fonts, different aesthetics. NEVER converge on common choices ^(Space Grotesk, for example^) across generations.
echo 
echo **IMPORTANT**: Match implementation complexity to the aesthetic vision. Maximalist designs need elaborate code with extensive animations and effects. Minimalist or refined designs need restraint, precision, and careful attention to spacing, typography, and subtle details. Elegance comes from executing the vision well.
echo 
echo Remember: Claude is capable of extraordinary creative work. Don't hold back, show what can truly be created when thinking outside the box and committing fully to a distinctive vision.
) > "frontend-design\SKILL.md"

echo.
echo Done! frontend-design files created.
pause