# Deployment Instructions

## Build
1. Install dependencies: `npm ci`
2. Compile TypeScript: `npm run build`
3. Serve static files from repository root (`index.html`, `styles/`, `src/`, `dist/`).

## Production hosting
- Use any static host (GitHub Pages, Netlify, S3 + CloudFront).
- Configure cache headers:
  - HTML: `no-cache`
  - CSS/JS/assets: `public, max-age=31536000, immutable`
- Enable gzip/brotli compression.

## Release validation
- Run `npm run ci:validate` before release.
- Confirm Playwright smoke and gameplay checks pass in CI.
