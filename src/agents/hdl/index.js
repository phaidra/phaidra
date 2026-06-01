import HandleHttpApi from "./handle.js";
import nodeUtil from 'node:util';
import fs from 'node:fs/promises';
import { MongoClient } from 'mongodb';

nodeUtil.inspect.defaultOptions.depth = null;
process.env["NODE_TLS_REJECT_UNAUTHORIZED"] = "0";

// Service configuration
const config = {
  mongodb: {
    url: `mongodb://${process.env.MONGODB_PHAIDRA_USER}:${process.env.MONGODB_PHAIDRA_PASSWORD}@${process.env.MONGODB_PHAIDRA_HOST}/admin`,
    dbName: 'paf_mongodb',
    collection: 'jobs'
  },
  sleepTime: parseInt(process.env.IMAGE_CONVERSION_INTERVAL || '5') * 1000,
  baseURL: `${process.env.OUTSIDE_HTTP_SCHEME}://${process.env.PHAIDRA_HOSTNAME}${process.env.PHAIDRA_PORTSTUB}${process.env.PHAIDRA_HOSTPORT}`,
  agentName: 'hdl'
};

async function loadPrivateKey() {
  const jwkJson = await fs.readFile('admpriv.jwk', 'utf8');
  const privateKey = JSON.parse(jwkJson);
  return privateKey;
}

async function processJob(job) {
  try {
    console.log(`Processing job for PID: ${job.pid}`);

    const privateKey = await loadPrivateKey();
    // Must be https
    const serverUrl = "https://handle:8000";
    const authInfo = {
      adminIndex: 300,
      adminHandle: `0.NA/${process.env.HANDLE_PREFIX}`,
      privateKey,
      mode: "HS_PUBKEY"
    };
    const verbose = true;
    const handleHttpApi = new HandleHttpApi(authInfo, serverUrl, verbose);
    const createResult = await handleHttpApi.createUrlHandle(job.hdl, `${config.baseURL}/${job.pid}`);
    console.log(createResult);

    // Update job status
    await updateJobStatus(job.pid, 'finished');

    console.log(`Successfully registered handle for ${job.pid}`);
    return true;
  } catch (error) {
    console.error(`Error processing job ${job.pid}:`, error);
    await updateJobStatus(job.pid, 'failed');
    return false;
  }
}

async function updateJobStatus(pid, status, additionalFields = {}) {
  const update = {
    $set: {
      status,
      ...additionalFields
    }
  };

  await jobsCollection.updateOne(
    { pid, agent: config.agentName },
    update
  );
}

async function getNewJobs() {
  return await jobsCollection.find({
    agent: config.agentName,
    status: 'new'
  }).toArray();
}

let mongoClient;
let jobsCollection;

async function main() {
  try {
    // Connect to MongoDB
    mongoClient = await MongoClient.connect(config.mongodb.url);
    const db = mongoClient.db(config.mongodb.dbName);
    jobsCollection = db.collection(config.mongodb.collection);

    console.log('Connected to MongoDB, watching for new jobs...');

    console.table(config);

    // Main processing loop
    while (true) {
      const jobs = await getNewJobs();

      if (jobs.length === 0) {
        await new Promise(resolve => setTimeout(resolve, config.sleepTime));
        continue;
      }

      for (const job of jobs) {
        await processJob(job);
      }
    }
  } catch (error) {
    console.error('Fatal error:', error);
  } finally {
    if (mongoClient) {
      await mongoClient.close();
    }
  }
}

// Handle process termination
process.on('SIGTERM', async () => {
  console.log('Received SIGTERM, shutting down...');
  if (mongoClient) {
    await mongoClient.close();
  }
  process.exit(0);
});

main().catch(console.error);
