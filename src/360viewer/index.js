const { MongoClient } = require('mongodb');
const AdmZip = require('adm-zip');
const fs = require('fs').promises;
const path = require('path');

const config = {
  mongodb: {
    url: `mongodb://${process.env.MONGODB_PHAIDRA_USER}:${process.env.MONGODB_PHAIDRA_PASSWORD}@${process.env.MONGODB_PHAIDRA_HOST}/admin`,
    dbName: process.env.MONGO_AGENT_DB || 'paf_mongodb',
    collection: 'jobs'
  },
  store: process.env.CONVERTED_360_PATH || '/mnt/converted_360',
  sleepTime: parseInt(process.env.IMAGE_CONVERSION_INTERVAL || '5') * 1000
};

const IMAGE_EXTENSIONS = ['.png', '.jpg', '.jpeg', '.gif', '.webp'];

function detectNamingPattern(filenames) {
  if (!filenames.length) return null;
  const first = path.basename(filenames[0]);
  const match = first.match(/^(.*?)(\d+)(.*)$/);
  return match ? `${match[1]}${'x'.repeat(match[2].length)}${match[3]}` : first;
}

function extractImageFiles(zip) {
  return zip.getEntries()
    .filter(e => !e.isDirectory && IMAGE_EXTENSIONS.includes(path.extname(e.entryName).toLowerCase()))
    .sort((a, b) => a.entryName.localeCompare(b.entryName));
}

async function processJob(job, db) {
  try {
    if (!job.path) {
      await db.collection('jobs').updateOne(
        { pid: job.pid, agent: 'unzip' },
        { $set: { status: 'new' } }
      );
      return false;
    }

    const zip = new AdmZip(job.path);
    const imageFiles = extractImageFiles(zip);

    if (!imageFiles.length) {
      await updateJobStatus(job.pid, 'failed', { error: 'No image files found' });
      return false;
    }

    const lvl1 = job.idhash.substring(0, 1);
    const lvl2 = job.idhash.substring(1, 2);
    const outDir = path.join(config.store, lvl1, lvl2, job.idhash);
    await fs.mkdir(outDir, { recursive: true });

    const extractedFiles = [];
    for (const entry of imageFiles) {
      const filename = path.basename(entry.entryName);
      const outputPath = path.join(outDir, filename);
      await fs.writeFile(outputPath, entry.getData());
      extractedFiles.push(filename);
    }

    const pattern = detectNamingPattern(extractedFiles);

    await updateJobStatus(job.pid, 'finished', {
      frames: extractedFiles,
      imagePattern: pattern,
      outputPath: outDir,
      totalFrames: extractedFiles.length
    });

    console.log(`Processed ${job.pid}: ${extractedFiles.length} frames`);
    return true;
  } catch (error) {
    console.error(`Error processing ${job.pid}:`, error.message);
    await updateJobStatus(job.pid, 'failed', { error: error.message });
    return false;
  }
}

async function updateJobStatus(pid, status, additionalFields = {}) {
  await db.collection(config.mongodb.collection).updateOne(
    { pid, agent: 'unzip' },
    { $set: { status, ...additionalFields } }
  );
}

let db;

async function main() {
  console.log('360 Viewer service started');
  
  const client = new MongoClient(config.mongodb.url);
  await client.connect();
  db = client.db(config.mongodb.dbName);

  while (true) {
    try {
      const jobs = await db.collection(config.mongodb.collection)
        .find({ agent: 'unzip', status: 'new' })
        .limit(10)
        .toArray();

      for (const job of jobs) {
        await db.collection(config.mongodb.collection).updateOne(
          { pid: job.pid, agent: 'unzip' },
          { $set: { status: 'processing' } }
        );
        await processJob(job, db);
      }
    } catch (error) {
      console.error('Service error:', error.message);
    }

    await new Promise(resolve => setTimeout(resolve, config.sleepTime));
  }
}

process.on('SIGINT', () => {
  console.log('Shutting down gracefully...');
  process.exit(0);
});

main().catch(console.error);
