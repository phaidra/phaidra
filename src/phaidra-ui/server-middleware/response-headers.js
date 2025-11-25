import axios from 'axios'

let configCache = {
  headers: null,
  timestamp: 0,
  ttl: 60000
}

export default async function (req, res, next) {
  try {
    let customHeaders = null
    
    if (req.app && req.app.$store && req.app.$store.state && req.app.$store.state.instanceconfig) {
      customHeaders = req.app.$store.state.instanceconfig.customResponseHeaders
    }
    
    if (!customHeaders || Object.keys(customHeaders).length === 0) {
      const now = Date.now()
      
      if (configCache.headers && (now - configCache.timestamp) <= configCache.ttl) {
        customHeaders = configCache.headers
      } else {
        try {
          const apiBaseURL = 'http://' + process.env.PHAIDRA_API_HOST_INTERNAL + ':3000'
          const response = await axios.get(apiBaseURL + '/config/public?nocache=1')
          customHeaders = response?.data?.public_config?.customResponseHeaders || {}
          
          configCache.headers = customHeaders
          configCache.timestamp = now
        } catch (error) {
          if (configCache.headers) {
            customHeaders = configCache.headers
          }
        }
      }
    }
    
    if (customHeaders && typeof customHeaders === 'object' && Object.keys(customHeaders).length > 0) {
      Object.keys(customHeaders).forEach(headerName => {
        const headerValue = customHeaders[headerName]
        if (headerValue !== null && headerValue !== undefined) {
          res.setHeader(headerName, headerValue)
        }
      })
    }
  } catch (error) {
    console.error('Error in response-headers middleware:', error.message)
  }

  next()
}
