# Bash reusable snittpets and tips

## Loop over lines in a variable

```bash
while IFS= read -r line; do
    echo "... $line ..."
done <<< "$list"
```
