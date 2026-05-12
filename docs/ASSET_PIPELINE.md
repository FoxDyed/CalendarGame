# Asset Pipeline Documentation

## Current assets
- CSS in `styles/main.css`
- TypeScript modules in `src/`

## Build pipeline
- `tsc` compiles `src/**/*.ts` to `dist/`.
- No bundler currently; modules are loaded natively.

## Optimization recommendations
- Add hashed filenames via bundler (Vite/esbuild) for long-term caching.
- Inline critical CSS for above-the-fold paint.
- Convert screenshots and future images to WebP/AVIF.
- Keep `.logs/` artifacts out of production deploy package.
