import { state } from '../store/modules/vocabulary'

var roles = {
  'role:aut': 1,
  'role:advisor': 2,
  'role:coadvisor': 3,
  'role:assessor': 4
}
var bookTypeOrder = {
  'role:edt': 1,
  'role:aut': 2,
  'role:advisor': 3,
  'role:coadvisor': 4,
  'role:assessor': 5
}

let i = Object.keys(roles).length
let stateX = state()
for (let r of stateX.vocabularies.rolepredicate.terms) {
  i++
  if (!roles[r['@id']]) {
    roles[r['@id']] = i
  }
}

let j = Object.keys(bookTypeOrder).length
let stateY = state()
for (let r of stateY.vocabularies.rolepredicate.terms) {
  j++
  if (!bookTypeOrder[r['@id']]) {
    bookTypeOrder[r['@id']] = j
  }
}

export default {
  roles,
  bookTypeOrder
}