# Keyboard shortcuts in VS Code

## Custom shortcuts

### Toggle between code editor and terminal

```json
{
    "key": "ctrl+alt+t",
    "command": "workbench.action.terminal.focus"
},
{
    "key": "ctrl+alt+t",
    "command": "workbench.action.focusActiveEditorGroup",
    "when":    "terminalFocus"
}
```
