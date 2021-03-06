# 06 Subsetting Data
csiu  



```
OBJECTIVES
- To be able to subset vectors, factors, matrices, lists, and data frames
- To be able to extract individual and multiple elements: by index, by name, using comparison operations
- To be able to skip and remove elements from various data structures.
```

## Subsetting data structures

- vector subsetting, see next section
- Factor subsetting works the same way as vector subsetting, but skipping elements does not remove level
- matrix subsetting takes 2 arguments (row, column) when using `[`
- list subsetting by:
    - `[` to subset list but not extract element
    - `[[` to extract individual elements of a list
    - `$` is a shorthand way for extracting elements by name
- data frames are lists underneath the hood

## Extracting elements

- indexing in R starts at 1 (not 0)
- access individual values by location/index using `[]`
- access slices of data using `[low:high]`
- access arbitrary sets of data/getting multiple elements at once using `[c(...)]`


```r
# get the nth value
x[1]
x[4]

# get slice
x[1:4]

# get arbitrary set
x[c(1, 3)]
x[c(1,1,3)]
```

- instead of index, can subset by name
- `which()` to select subsets of data based on value by finding which indices are true
- `%in%` goes through each element of its left argument, and asks “Does this element occur in the second argument?”

## Skipping and removing elements

- use minus and then reassign


```r
x[-2]
x[c(-1, -5)]  # or x[-c(1,5)]
x[-(1:3)]
```
