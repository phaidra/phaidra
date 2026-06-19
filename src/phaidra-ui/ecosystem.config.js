module.exports = {
  apps: [
    {
      name: 'nuxt',
      cwd: '/usr/local/phaidra/phaidra-ui',
      script: '.output/server/index.mjs',
      interpreter: 'node',
      exec_mode: 'cluster',
      instances: 2,
      watch: false,
      env: {
        NODE_ENV: 'production',
        HOST: '0.0.0.0',
        PORT: '3001'
      }
    }
  ]
};