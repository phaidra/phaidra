module.exports = {
  apps: [{
    name: 'nuxt',
    cwd: '/usr/local/phaidra/phaidra-ui',
    script: './node_modules/.bin/nuxt',
    args: `start -c ${process.cwd()}/nuxt.config.js`,
    exec_mode: 'cluster',
    instances: '8',
    watch: false,
    env: { NODE_ENV: 'production' }
  }]
}