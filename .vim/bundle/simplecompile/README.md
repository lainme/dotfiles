Simple Compile
=============

A simple compling plugin for VIM

Currently support:

    fortran:    gfortran
    c:          gcc
    python:     python
    latex:      rubber

Options:

    g:simplecompile_debug = 0
        Value: 0 or 1
        Description: whether to add -g -Wall option or not
    g:simplecompile_terminal = "xterm"
        Value: any string representing a terminal command
        Description: define the terminal to use
    g:simplecompile_pdf = "xdg-open"
        Value: any string representing a pdf reader command
        Description: define the pdf reader to use

Commands:

    SimpleCompile: compile the file
    SimpleRun: run the file
