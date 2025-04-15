
# MiKTeX (miktex)

Installs MiKTeX and useful addons for a pleasant development experience in VS Code (automatic package installation, LaTeX Workshop VS Code extension, tex-fmt)

## Example Usage

```json
"features": {
    "ghcr.io/rferrali/devcontainer-features/miktex:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| autoInstallPackages | Whether to configure MiKTeX to automatically install missing packages. If false, you will have to install missing packages manually. | boolean | true |
| installTexFmt | Whether to install tex-fmt, a LaTeX formatter. If false, you will have to disable the latex-workshop.formatting.latex setting. | boolean | true |

## Customizations

### VS Code Extensions

- `James-Yu.latex-workshop`



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/rferrali/devcontainer-features/blob/main/src/miktex/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
