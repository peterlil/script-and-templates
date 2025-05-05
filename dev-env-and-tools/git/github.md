# GitHub Markdown - Snippets and tips

## Multiline code block within a table cell

You can replace <code>\`</code> with <code>\<code\></code> tags and, use `&nbsp;` for indentation and `<br>` as line breaks.

For code blocks use <code>\<pre\></code> tags instead of <code>```</code>.

## Set SSH key to use for local repo

```bash
git config core.sshCommand "ssh -i ~/.ssh/custom_key"
```
