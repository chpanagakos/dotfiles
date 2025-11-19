# .latexmkrc

# 1. Aux directory: Where intermediate files (log, aux, fls) go
$aux_dir = 'build';

# 2. Output directory: Where the final PDF goes
$out_dir = 'build';

# 3. PDF mode: Auto-detect (1=pdf via pdflatex, 4=pdf via lualatex/xelatex)
$pdf_mode = 1; 

# 4. SyncTeX: Ensure inverse search works even with the split directories
$pdflatex = 'pdflatex -file-line-error -synctex=1 -interaction=nonstopmode %O %S';
$xelatex  = 'xelatex -file-line-error -synctex=1 -interaction=nonstopmode %O %S';
