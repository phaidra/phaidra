import qs from 'qs'
import axios from 'axios'
import config from '../config/phaidra-ui'

export default async (req, res, next) => {
  let baseURL = process.env.OUTSIDE_HTTP_SCHEME + '://' + process.env.PHAIDRA_HOSTNAME + process.env.PHAIDRA_PORTSTUB + process.env.PHAIDRA_HOSTPORT

  const redirectEvaluator = async (pid) => {
      let apiBaseURL = 'http://' + process.env.PHAIDRA_API_HOST_INTERNAL + ':3000'
      let params = { q: '*:*', defType: 'edismax', wt: 'json', start: 0, rows: 1, fq: 'pid:"' + pid + '"' }
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
              redirect(res, '/api/object/' + pid + '/preview')
              return
            }
          }
        }
        if (doc['isinadminset']) {
          for (let adminset of doc['isinadminset']) {
            if (adminset === 'phaidra:ir.univie.ac.at') {
              redirect(res, process.env.IR_BASE_URL + '/' + pid)
              return
            }
          }
        }
      }
      redirect(res, baseURL + '/detail/' + pid)
  }

  if(req.url.includes('/latest')) {
    try {
      
      const match = req.url.match(/\/o:(\d+)\/latest/);
      let apiBaseURL = 'http://' + process.env.PHAIDRA_API_HOST_INTERNAL + ':3000'
      let response = await axios.request({
        method: 'GET',
        url: apiBaseURL + '/object/o:' + match[1] + '/info',
      })
      const versionsData = response.data.info.versions
      if(versionsData.length){
        const latestVersionIndex = versionsData.reduce((maxIdx, item, index, arr) => 
            new Date(item.created) > new Date(arr[maxIdx].created) ? index : maxIdx, 0
        );
        if(new Date(response.data.info.created) < new Date(versionsData[latestVersionIndex].created)){
          await redirectEvaluator(versionsData[latestVersionIndex]['pid'])
          return
        }
      }
      next()
    } catch (error) {
      console.log('error',error)
      next()
    }
  }
  
  // Check for pdf download start
  
  const regex = /^\/detail\/([^\/]+)\.pdf$/;
  const match = req.url.match(regex)
  if(match) {
    let pid = match[1].replace('.pdf', '')
    redirect(res, baseURL + '/api/object/' + pid + '/download')
    return
  }
  
  // Check for pdf download end

  if (process.env.LEGACY_OPEN_REDIRECT === 'true') {
    if (/^\/open\/o:\d+$/.test(req.url)) { 
      let pid = req.url.replace('/open', '')
      let redUrl = baseURL + '/' + pid
      console.log(redUrl)
      redirect(res, redUrl)
      return
    }
    if (/^\/view\/o:\d+$/.test(req.url)) { 
      let pid = req.url.replace('/view', '')
      let redUrl = baseURL + '/' + pid
      console.log(redUrl)
      redirect(res, redUrl)
      return
    }
    if (/^\/download\/o:\d+$/.test(req.url)) { 
      let pid = req.url.replace('/download', '')
      let redUrl = baseURL + '/api/object/' + pid + '/download'
      console.log(redUrl)
      redirect(res, redUrl)
      return
    }
  }
  if (/^\/o:\d+$/.test(req.url)) { 
    let pid = req.url.replace('/', '')
    try {
      await redirectEvaluator(pid)
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
