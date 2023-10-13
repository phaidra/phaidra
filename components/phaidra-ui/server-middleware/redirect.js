import qs from 'qs'
import axios from 'axios'
import config from '../config/phaidra-ui'

export default async (req, res, next) => {
  if (/^\/o:\d+$/.test(req.url)) {
    let pid = req.url.replace('/', '')
    let params = { q: '*:*', defType: 'edismax', wt: 'json', start: 0, rows: 1, fq: 'pid:"' + pid + '"' }
    try {
      let response = await axios.request({
        method: 'POST',
        url: '/search/select',
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
            if (doc.datastreams.includes("UWMETADATA")) {
              redirect(res, config.instances[config.defaultinstance].fedora + '/objects/' + pid + '/methods/bdef:Book/view')
              return
            } else {
              redirect(res, config.instances[config.defaultinstance].api + '/object/' + pid + '/preview')
              return
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
      redirect(res, 'https://' + config.instances[config.defaultinstance].baseurl + '/detail/' + pid)
      return
    } catch (error) {
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
