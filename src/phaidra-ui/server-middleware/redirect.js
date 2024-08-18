import qs from 'qs'
import axios from 'axios'
import config from '../config/phaidra-ui'

export default async (req, res, next) => {
  if (/^\/o:\d+$/.test(req.url)) { 
    let baseURL = process.env.OUTSIDE_HTTP_SCHEME + '://' + process.env.PHAIDRA_HOSTNAME + process.env.PHAIDRA_PORTSTUB + process.env.PHAIDRA_HOSTPORT
    let apiBaseURL = 'http://' + process.env.PHAIDRA_API_HOST_INTERNAL + ':3000'
    let pid = req.url.replace('/', '')
    let params = { q: '*:*', defType: 'edismax', wt: 'json', start: 0, rows: 1, fq: 'pid:"' + pid + '"' }
    try {
      let response = await axios.request({
        method: 'POST',
        url: apiBaseURL + '/search/select',
        data: qs.stringify(params, { arrayFormat: 'repeat' }),
        headers: {
          'content-type': 'application/x-www-form-urlencoded'
        },
        params: params
      })
      let docs = response.data.response.docs
      if (docs.length >= 1) {
        let doc = docs[0]
        if (doc['cmodel']) {
          if (doc['cmodel'] === 'Book') {
            if (!doc.datastreams.includes("POLICY") && !doc.isrestricted) {
              if (doc.datastreams.includes("UWMETADATA")) {
                redirect(res, config.instances[config.defaultinstance].fedora + '/objects/' + pid + '/methods/bdef:Book/view')
                return
              } else {
                redirect(res, baseURL + '/api/object/' + pid + '/preview')
                return
              }
            }
          }
        }
        if (doc['isinadminset']) {
          for (let adminset of doc['isinadminset']) {
            if (adminset === 'phaidra:ir.univie.ac.at') {
              redirect(res, 'https://' + config.instances[config.defaultinstance].irbaseurl + '/' + pid)
              return
            }
          }
        }
      }
      redirect(res, baseURL + '/detail/' + pid)
      return
    } catch (error) {
      console.log(error)
      next()
    } finally {
      next()
    }
  } else {
    next()
  }
}

function redirect(res, location) {
  res.writeHead(301, {
    location
  })
  res.end()
}
