# GitHub Markdown - Snippets and tips

## Multiline code block within a table cell

You can replace <code>\`</code> with <code>\<code\></code> tags and, use `&nbsp;` for indentation and `<br>` as line breaks.

For code blocks use <code>\<pre\></code> tags instead of <code>```</code>.

## Generate an SSH key for a specific GitHub user

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/custom_key
```

## Set SSH key to use for local repo

```bash
git config core.sshCommand "ssh -i ~/.ssh/custom_key"
```
