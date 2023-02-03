Note: These commands are using the flavor of RegEx that TextPad recognizes

## Replace a value with an incrementing number
EXAMPLE:

```
One
Two
Three
```

Find: `(.*)\n`
Replace: `\i{1,1}_\1\n`

RESULT:
```
1_One
2_Two
3_Three
```

EXPLANATION:
`\i{STARTING_NUMBER, AMOUNT_TO_INCREMENT}`
- The first parameter is what number you want to start at, this doesn't have to be 1
- The 2nd parameter is the amount you want to increment on each line
- If you just want to step by 1 each time, you can also just specify the first parameter. `\i{1}` would increment each line by 1, starting with 1