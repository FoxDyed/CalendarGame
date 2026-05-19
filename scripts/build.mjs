import { mkdir, readFile, readdir, rm, writeFile } from 'node:fs/promises';
import { dirname, join, relative } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const srcDir = join(root, 'src');
const distDir = join(root, 'dist');

async function walk(dir) {
  const entries = await readdir(dir, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    const full = join(dir, entry.name);
    if (entry.isDirectory()) files.push(...await walk(full));
    if (entry.isFile() && entry.name.endsWith('.ts')) files.push(full);
  }
  return files;
}

async function createTranspiler() {
  const moduleApi = await import('node:module');
  if (typeof moduleApi.stripTypeScriptTypes === 'function') {
    return (source) => moduleApi.stripTypeScriptTypes(source, { mode: 'transform' });
  }

  const ts = await import('typescript');
  return (source) => ts.transpileModule(source, {
    compilerOptions: {
      module: ts.ModuleKind.ES2022,
      target: ts.ScriptTarget.ES2022,
      importsNotUsedAsValues: ts.ImportsNotUsedAsValues.Remove
    }
  }).outputText;
}

await rm(distDir, { recursive: true, force: true });
const transpile = await createTranspiler();

for (const file of await walk(srcDir)) {
  const source = await readFile(file, 'utf8');
  const js = transpile(source);
  const out = join(distDir, relative(srcDir, file)).replace(/\.ts$/, '.js');
  await mkdir(dirname(out), { recursive: true });
  await writeFile(out, js, 'utf8');
}

console.log(`Built ${relative(root, distDir)}`);
