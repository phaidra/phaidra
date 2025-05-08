const { MongoClient } = require('mongodb');
const obj2gltf = require('obj2gltf');
const fs = require('fs').promises;
const path = require('path');

// Service configuration
const config = {
  mongodb: {
    url: `mongodb://${process.env.MONGODB_PHAIDRA_USER}:${process.env.MONGODB_PHAIDRA_PASSWORD}@${process.env.MONGODB_PHAIDRA_HOST}/admin`,
    dbName: process.env.MONGO_AGENT_DB || 'paf_mongodb',
    collection: 'jobs'
  },
  store: process.env.CONVERTED_3D_PATH || '/mnt/converted_3d',
  sleepTime: parseInt(process.env.IMAGE_CONVERSION_INTERVAL || '5') * 1000
};

async function processJob(job) {
  try {
    console.log(`Processing job for PID: ${job.pid}`);
    
    // Create output directory based on idhash
    const lvl1 = job.idhash.substring(0, 1);
    const lvl2 = job.idhash.substring(1, 2);
    const outDir = path.join(config.store, lvl1, lvl2);
    await fs.mkdir(outDir, { recursive: true });
    
    // Convert OBJ to GLTF
    const gltf = await obj2gltf(job.path);
    const outputPath = path.join(outDir, `${job.idhash}.gltf`);
    
    // Save the converted file
    await fs.writeFile(outputPath, JSON.stringify(gltf));
    
    // Update job status
    await updateJobStatus(job.pid, 'finished', {
      image: outputPath
    });
    
    console.log(`Successfully converted ${job.pid} to ${outputPath}`);
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
    { pid, agent: '3d' },
    update
  );
}

async function getNewJobs() {
  return await jobsCollection.find({
    agent: '3d',
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
