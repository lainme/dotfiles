\def\pgfsysdriver{pgfsys-dvipdfm.def}
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{beamerslides}
\DeclareOption{zh}{\newcommand{\showchinese}{}}
\DeclareOption{notes}{\newcommand{\shownotes}{}}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{beamer}}
\ProcessOptions
\LoadClass{beamer}
\RequirePackage[T1]{fontenc}
\RequirePackage[sc]{mathpazo}
\RequirePackage{multirow}
\RequirePackage{amsmath,amsthm,amssymb}
\RequirePackage{graphicx}
\RequirePackage{subcaption}
\RequirePackage[compatibility=false]{caption}
\RequirePackage{xcolor}
\RequirePackage{pgfplots}

%  ----  Presenter mode  ----------------------------
\@ifundefined{shownotes}{}{
    \RequirePackage{pgfpages}
    \setbeameroption{show notes on second screen=right}
}

%  ----  Language style  ----------------------------
\@ifundefined{showchinese}{}{
    \RequirePackage[BoldFont,SlantFont,CJKchecksingle]{xeCJK}
    \setCJKmainfont{SimSun}
}

%  ----  Plot settings  -----------------------------
\pgfplotsset{compat=1.12}

%  ----  Slides style  ------------------------------
\usefonttheme[onlymath]{serif}
\setbeamertemplate{caption}[numbered]
\setbeamerfont*{itemize/enumerate subbody}
{parent=itemize/enumerate body}

%  ----  Macros  ------------------------------
\let\oldalert\alert
\renewcommand{\alert}[1]{\oldalert{\bf #1}}

\let\@@magyar@captionfix\relax

% vim: set ft=tex ff=unix tw=70:
