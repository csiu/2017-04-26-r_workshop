# 03 Seeking Help
csiu  



```
OBJECTIVES
- To be able read R help files for functions and special operators.
- To be able to use CRAN task views to identify packages to solve a problem.
- To be able to seek help from your peers.
```

## R help files

- get help files for functions:


```r
?function_name
help(function_name)

?"+"              # Use quotes for special operators
??function_name   # Two question marks for fuzzy searching
```

- `vignette()` to list all tutorials & extended example documentations or `vignette(package="package-name")` for specific package

## CRAN task views

- is a specially maintained list of packages grouped into fields
- https://cran.r-project.org/web/views/

## Help from peers

- `dput()` to dump the data you’re working with into a format so that it can be copy and pasted by anyone else into their R session
- `sessionInfo()` to print your current version of R & packages you loaded
- google and use stackoverflow [`[r]`](https://stackoverflow.com/questions/tagged/r) tag
