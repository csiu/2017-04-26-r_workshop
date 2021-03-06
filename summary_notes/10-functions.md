# 10 Functions Explained
csiu  



```
OBJECTIVES
- Define a function that takes arguments.
- Return a value from a function.
- Test a function.
- Set default values for function arguments.
- Explain why we should divide programs into small, single-purpose functions.
```

## Writing functions

- `function` to define new function
- Parameters to pass values into functions
    - you can specify default arguments
- `return` to send result back


```r
my_sum <- function(a, b=0) { # 2 parameters: a and b
                             # default argument of b is 0
  the_sum <- a + b
  return(the_sum)            # return output
}
```

- if you define function in separate script, use `source` to load function into program

## Testing functions

- important to test and document functions
- documentation helps you/others understand purpose of function & how to use it

## Purpose of functions

- by dividing programs into small, single-purpose functions, you can mix/match/combine functions into ever-larger chunks to get what you want
- makes writing code more concise & easy to read
