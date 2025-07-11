# Samples of regular expressions

## Helpers for going from json to bicep

### Search and replace single quotes
First search and replace single quotes with the escape sequence `\'`.

### Find the closing quote for a name in a json file.
This expression finds the closing quote and the trailing colon. Replace with just a colon.
_#lookbehind_
```
(?<=^[\s]+"[\w\s]+)"[\s]*:
```

### Find the leading quote for a name in a json file
This expression find the leading quote for name. 
_#lookaround_

This version relies on the trailing quote is already replaced.
```
(?<=^[\s]+)"(?=[\w\s]+:)
```

This version relies on the trailing quote is there.
```
(?<=^[\s]+)"(?=[\w\s]+":)
```

Replace with nothing.

### Replace double quotes with single quotes

Just do simple replacement.

### Replace all json-commas

Replace all commas at the end of the line. Replace with nothing.

```
,$
```
