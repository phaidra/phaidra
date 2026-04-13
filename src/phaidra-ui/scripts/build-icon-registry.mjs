import { promises as fs } from 'fs'
import path from 'path'
import { fileURLToPath, pathToFileURL } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const compiledDir = path.join(__dirname, '..', 'compiled-icons')
const outDir = path.join(__dirname, '..', 'icons')
const outFile = path.join(outDir, 'registry.js')

async function main () {
  await fs.mkdir(outDir, { recursive: true })

  const entries = await fs.readdir(compiledDir)
  const icons = {}

  for (const file of entries) {
    if (!file.endsWith('.js') || file === 'index.js') continue
    const fullPath = path.join(compiledDir, file)
    let mod
    try {
      mod = await import(pathToFileURL(fullPath).href)
    } catch (e) {
      console.warn(`build-icon-registry: skip ${file}: ${e.message}`)
      continue
    }
    const def = mod.__svgIconDefinition
    if (!def || typeof def !== 'object') continue
    for (const [name, meta] of Object.entries(def)) {
      if (!meta || meta.viewBox == null || meta.data == null) continue
      icons[name] = {
        width: Number(meta.width),
        height: Number(meta.height),
        viewBox: meta.viewBox,
        data: meta.data
      }
    }
  }

  const sortedNames = Object.keys(icons).sort()

  let output = ''
  output += '// Auto-generated from compiled-icons/*.js by scripts/build-icon-registry.mjs\n'
  output += '// Do not edit by hand; re-run the script instead.\n\n'
  output += 'export const ICONS = {\n'
  for (const name of sortedNames) {
    const icon = icons[name]
    output += `  '${name}': {\n`
    output += `    width: ${icon.width},\n`
    output += `    height: ${icon.height},\n`
    output += `    viewBox: '${icon.viewBox}',\n`
    output += `    data: '${icon.data.replace(/'/g, "\\'")}',\n`
    output += '  },\n'
  }
  output += '}\n'

  await fs.writeFile(outFile, output, 'utf8')
  console.log(`Wrote ${sortedNames.length} icons to ${outFile}`)
}

main().catch((err) => {
  console.error('Error building icon registry:', err)
  process.exit(1)
})

