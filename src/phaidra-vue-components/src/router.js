import { createRouter, createWebHistory } from 'vue-router'

export default createRouter({
  history: createWebHistory(),
  routes: [
    {
      name: 'detail',
      path: '/details',
      component: {
        template: '<div><b>Details</b> not implemented in PVC demo app</div>'
      }
    }
  ]
})
