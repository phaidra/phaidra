const { MongoClient } = require('mongodb');

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

async function processJob(job) {
  try {
    console.log(`Processing job for PID: ${job.pid}`);

    const handleData = {
      values: [
        {
          index: 1,
          type: "URL",
          data: {
            format: "string",
            value: `${config.baseURL}/${job.pid}`
          }
        }
      ]
    };

    const json = JSON.stringify(handleData, null, 2);

    console.log(`PUT: ${json}`);
    console.log(`URL: http://handle:8000/api/handles/${job.hdl}?overwrite=false`);

    // const username = 'prefix?';
    // const password = 'privkey?';
    // const base64Credentials = btoa(`${username}:${password}`);
  
    const response = await fetch(`http://handle:8000/api/handles/${job.hdl}?overwrite=false`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json'//,
        //'Authorization': `Basic ${base64Credentials}`
      },
      body: json
    });

    if (!response.ok) {
      console.error(`Error processing job ${job.pid}:`, response);
      throw new Error(`Failed to create handle: ${response.status} ${response.statusText}`);
    }

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
