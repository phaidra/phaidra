import { state } from '../store/modules/vocabulary'

var roles = {
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

export default {
  roles
}
