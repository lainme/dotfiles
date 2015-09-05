\ProvidesClass{manuscript}
\NeedsTeXFormat{LaTeX2e}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions
\LoadClass[12pt]{article}
\RequirePackage[a4paper,margin=25mm]{geometry}
\RequirePackage[T1]{fontenc}
\RequirePackage[sc]{mathpazo}
\RequirePackage[ocgcolorlinks,
                colorlinks,
                linkcolor=blue,
                citecolor=blue,
                urlcolor=blue]{hyperref}
\RequirePackage{enumitem}
\RequirePackage{multirow}
\RequirePackage{amsmath,amsthm,amssymb}
\RequirePackage{graphicx}
\RequirePackage[justification=raggedright]{subcaption}
\RequirePackage[norefs,nocites,ignoreunlbld]{refcheck}

%  ----  Paragraph style  ---------------------------
\linespread{1.3}
\setlength{\parindent}{0em}
\setlength{\parskip}{1.3em}
\setlength{\tabcolsep}{1em}
\setlength{\jot}{1em}

%  ----  List style  --------------------------------
\setitemize{nosep, before={\vspace*{-0.5\parskip}}}
\setenumerate{nosep, before={\vspace*{-0.5\parskip}}}
\setdescription{
    topsep=0em,
    leftmargin=0em,
    before={\vspace*{-0.5\parskip}}
}

%  ----  Front matters  ------------------------------
\renewcommand{\maketitle}{
    \begin{center}
        {\LARGE\bf\@title}
        \@ifundefined{author}{}{{\par\large\@author}}
        \@ifundefined{date}{}{{\par\@date}}
    \end{center}
}

% vim: set ft=tex ff=unix tw=70:
