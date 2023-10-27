export default {
  arrayMove (arr, oldIndex, newIndex) {
    if (newIndex >= arr.length) {
      var k = newIndex - arr.length + 1
      while (k--) {
        arr.push(undefined)
      }
    }
    return arr.splice(newIndex, 0, arr.splice(oldIndex, 1)[0])
  },
  duplicate (arr, e) {
    var i = arr.indexOf(e)
    var e2 = JSON.parse(JSON.stringify(e))
    arr = arr.splice(i + 1, 0, e2)
    return e2
  },
  remove (arr, e) {
    var i = arr.indexOf(e)
    arr = arr.splice(i, 1)
  },
  moveUp (arr, e) {
    var i = arr.indexOf(e)
    if (i - 1 >= 0) {
      return this.arrayMove(arr, i, i - 1)
    }
  },
  moveDown (arr, e) {
    var i = arr.indexOf(e)
    if (i + 1 <= arr.length) {
      return this.arrayMove(arr, i, i + 1)
    }
  }
}
