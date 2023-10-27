export default {
  htmlToPlaintext (text) {
    return text ? String(text).replace(/<[^>]+>/gm, '') : ''
  },
  xmlToJson (xmlDocument) {
    // Create the return object
    var obj = {}
    if (xmlDocument.nodeType === 1) { // element
      // do attributes
      if (xmlDocument.attributes.length > 0) {
        obj['@attributes'] = {}
        for (var j = 0; j < xmlDocument.attributes.length; j++) {
          var attribute = xmlDocument.attributes.item(j)
          obj['@attributes'][attribute.nodeName] = attribute.nodeValue
        }
      }
    } else if (xmlDocument.nodeType === 3) { // text
      obj = xmlDocument.nodeValue
    }
    // do children
    if (xmlDocument.hasChildNodes()) {
      for (var i = 0; i < xmlDocument.childNodes.length; i++) {
        var item = xmlDocument.childNodes.item(i)
        var nodeName = item.nodeName
        if (typeof (obj[nodeName]) === 'undefined') {
          obj[nodeName] = this.xmlToJson(item)
        } else {
          if (typeof (obj[nodeName].push) === 'undefined') {
            var old = obj[nodeName]
            obj[nodeName] = []
            obj[nodeName].push(old)
          }
          obj[nodeName].push(this.xmlToJson(item))
        }
      }
    }
    return obj
  }
}
