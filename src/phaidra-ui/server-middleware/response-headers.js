import config from '../config/phaidra-ui'

export default (req, res, next) => {
  const instanceConfig = config.instances[config.defaultinstance]
  const customHeaders = instanceConfig?.customResponseHeaders || {}
  const globalHeaders = config.global?.customResponseHeaders || {}
  const allHeaders = { ...globalHeaders, ...customHeaders }
  Object.keys(allHeaders).forEach(headerName => {
    const headerValue = allHeaders[headerName]
    if (headerValue !== null && headerValue !== undefined) {
      res.setHeader(headerName, headerValue)
    }
  })

  next()
}

