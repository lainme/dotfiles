\ProvidesClass{slides}
\NeedsTeXFormat{LaTeX2e}
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

%  ----  Defined colors  ----------------------------
\colorlet{lightblue}{blue!12}

%  ----  Presenter mode  ----------------------------
\@ifundefined{shownotes}{}{
    \def\pgfsysdriver{pgfsys-dvipdfm.def}
    \RequirePackage{pgfpages}
    \setbeameroption{show notes on second screen=right}
}

%  ----  Language style  ----------------------------
\@ifundefined{showchinese}{}{
    \RequirePackage[BoldFont,SlantFont,CJKchecksingle]{xeCJK}
    \setCJKmainfont{SimSun}
}

%  ----  Slides style  ------------------------------
\usetheme{Singapore}
\usecolortheme{rose}
\usefonttheme[onlymath]{serif}
\setbeamertemplate{caption}[numbered]
\setbeamerfont*{itemize/enumerate subbody}
{parent=itemize/enumerate body}

\setbeamercolor{alerted text}{fg=blue}
\setbeamercolor{box}{fg=black,bg=lightblue}
\let\oldalert\alert
\renewcommand{\alert}[1]{\oldalert{\bf #1}}

%  ----  Paragraph style  ---------------------------
\linespread{1.2}
\setlength{\parindent}{0em}
\setlength{\parskip}{1em}
\setlength{\tabcolsep}{1em}
\setlength{\jot}{1em}

% vim: set ft=tex ff=unix tw=70:
