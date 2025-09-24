const { MongoClient } = require('mongodb');
const { execFile } = require('child_process');
const { promisify } = require('util');
const path = require('path');

const execFileAsync = promisify(execFile);

// Service configuration via environment variables with sensible default
const config = {
  mongodb: {
    url: `mongodb://${process.env.MONGODB_PHAIDRA_USER}:${process.env.MONGODB_PHAIDRA_PASSWORD}@${process.env.MONGODB_PHAIDRA_HOST}/admin`,
    dbName: process.env.MONGO_AGENT_DB || 'paf_mongodb',
    collection: 'jobs'
  },
  tika: {
    jarPath: process.env.TIKA_APP_JAR || '/opt/tika/tika-app.jar',
    timeoutMs: parseInt(process.env.TIKA_TIMEOUT_MS || '120000', 10)
  },
  solr: {
    baseUrl: process.env.SOLR_URL || 'http://solr:8983/solr',
    collection: process.env.SOLR_COLLECTION || 'phaidra',
    field: process.env.SOLR_TEXT_FIELD || 'text_general',
    username: process.env.SOLR_USER || 'phaidra',
    password: process.env.SOLR_PASS || 'phaidra'
  },
  sleepTime: parseInt(process.env.PDF_EXTRACTION_INTERVAL || '20', 10) * 1000 // 20 seconds
};

let mongoClient;
let jobsCollection;

async function updateJobStatus(pid, status, setFields = {}, agent = 'tika') {
  const update = { $set: { status, ...setFields } };
  await jobsCollection.updateOne({ pid, agent }, update);
}

async function extractPdfText(pdfFilePath) {
  const args = ['-jar', config.tika.jarPath, '-t', pdfFilePath];
  const options = { timeout: config.tika.timeoutMs, maxBuffer: 50 * 1024 * 1024 };
  const { stdout } = await execFileAsync('java', args, options);
  return stdout;
}

async function getNewJobs() {
  return jobsCollection.find({ agent: 'tika', status: 'new' }).toArray();
}

async function processJob(job) {
  try {
    if (!job.path) {
      await updateJobStatus(job.pid, 'failed', { error: 'Missing job.path' });
      return false;
    }

    // Mark as processing
    await updateJobStatus(job.pid, 'processing');

    const pdfPath = path.resolve(job.path);
    const text = await extractPdfText(pdfPath);
    // Send text to Solr and mark finished
    await updateSolr(job.pid, text);
    await updateJobStatus(job.pid, 'finished', { solr_updated_at: new Date().toISOString() });
    return true;
  } catch (error) {
    console.error('pdf extraction job failed:', error);
    await updateJobStatus(job.pid, 'failed', { error: String(error && error.message ? error.message : error) });
    return false;
  }
}

async function updateSolr(pid, text) {
  const url = `${config.solr.baseUrl}/${encodeURIComponent(config.solr.collection)}/update?commit=true`;
  // Use atomic update to set/replace the field on existing doc
  const payload = [{ pid: pid, [config.solr.field]: { set: text } }];
  
  const headers = { 'Content-Type': 'application/json' };
  if (config.solr.username && config.solr.password) {
    const auth = Buffer.from(`${config.solr.username}:${config.solr.password}`).toString('base64');
    headers['Authorization'] = `Basic ${auth}`;
  }
  
  const res = await fetch(url, {
    method: 'POST',
    headers,
    body: JSON.stringify(payload)
  });
  console.log('Solr update response:', res);
  if (!res.ok) {
    const body = await res.text().catch(() => '');
    throw new Error(`Solr update failed: ${res.status} ${res.statusText} ${body}`);
  }
}

async function main() {
  try {
    mongoClient = await MongoClient.connect(config.mongodb.url);
    const db = mongoClient.db(config.mongodb.dbName);
    jobsCollection = db.collection(config.mongodb.collection);

    console.log('Connected to MongoDB, watching for new PDF extraction jobs...');
    console.table({
      MongoURL: config.mongodb.url.replace(/:\\w+@/, ':****@'),
      DB: config.mongodb.dbName,
      Collection: config.mongodb.collection,
      IntervalMs: config.sleepTime,
      TikaJar: config.tika.jarPath,
      TimeoutMs: config.tika.timeoutMs,
      Solr: `${config.solr.baseUrl}/${config.solr.collection}`,
      SolrField: config.solr.field,
      SolrUser: config.solr.username
    });

    while (true) {
      const jobs = await getNewJobs();
      if (jobs.length === 0) {
        await new Promise((r) => setTimeout(r, config.sleepTime));
        continue;
      }
      for (const job of jobs) {
        await processJob(job);
      }
    }
  } catch (e) {
    console.error('tika worker fatal error:', e);
  } finally {
    if (mongoClient) {
      await mongoClient.close();
    }
  }
}

process.on('SIGTERM', async () => {
  console.log('Received SIGTERM, shutting down...');
  if (mongoClient) {
    await mongoClient.close();
  }
  process.exit(0);
});

if (require.main === module) {
  main().catch(console.error);
}

module.exports = { main };


