<script>
import { h, defineComponent, getCurrentInstance } from 'vue'
import { compile, NodeTypes } from '@vue/compiler-dom'
import * as runtimeDom from '@vue/runtime-dom'
import { cmsRuntimeComponents } from '../utils/cms-runtime-components'
import { ClientOnly, NuxtLink } from '#components'
import Icon from './Icon.vue'

const CMS_COMPONENTS = {
  ...cmsRuntimeComponents,
  NuxtLink,
  'nuxt-link': NuxtLink,
  ClientOnly,
  'client-only': ClientOnly,
  Icon,
  icon: Icon
}

const COMPILE_OPTIONS = {
  hoistStatic: false,
  cacheHandlers: false,
  nodeTransforms: [stripRefAttributes]
}

const componentCache = new Map()

function stripRefAttributes(node) {
  if (node.type !== NodeTypes.ELEMENT) {
    return
  }
  node.props = node.props.filter((prop) => {
    if (prop.type === NodeTypes.ATTRIBUTE && prop.name === 'ref') {
      return false
    }
    if (
      prop.type === NodeTypes.DIRECTIVE &&
      prop.name === 'bind' &&
      prop.arg?.type === NodeTypes.SIMPLE_EXPRESSION &&
      prop.arg.content === 'ref'
    ) {
      return false
    }
    return true
  })
}

function cmsBindProps(props) {
  if (!props || typeof props !== 'object') {
    return props ?? {}
  }
  const { ref: _ref, ...rest } = props
  return rest
}

function patchSlotDefaults(source) {
  return (source || '<div></div>')
    .replace(
      /v-slot(?::default)?="\{\s*isHovering\s*,\s*props\s*\}"/g,
      'v-slot="{ isHovering = false, props = {} } = {}"'
    )
    .replace(
      /v-slot:activator="\{\s*props\s*\}"/g,
      'v-slot:activator="{ props = {} } = {}"'
    )
    .replace(/\bv-bind="props"/g, 'v-bind="cmsBind(props)"')
}

function resolveCmsComponent(name) {
  if (typeof name !== 'string') {
    return name
  }
  const camel = name.replace(/-([a-z])/g, (_, c) => c.toUpperCase())
  const pascal = camel.charAt(0).toUpperCase() + camel.slice(1)
  return (
    CMS_COMPONENTS[pascal] ||
    CMS_COMPONENTS[camel] ||
    CMS_COMPONENTS[name] ||
    runtimeDom.resolveComponent(name)
  )
}

function compileRenderFn(source) {
  const { code } = compile(source, COMPILE_OPTIONS)
  const patchedCode = code
    .replace(/\b_resolveComponent\(/g, '__cmsResolveComponent(')
    .replace(/\bcmsBind\(/g, '_ctx.cmsBind(')
  return new Function(
    'Vue',
    '__cmsResolveComponent',
    patchedCode
  )(runtimeDom, resolveCmsComponent)
}

function createRuntimeCtx(parent, templateProps) {
  const hasProps = Object.keys(templateProps).length > 0
  return new Proxy(parent, {
    get(target, key, receiver) {
      if (key === 'cmsBind') {
        return cmsBindProps
      }
      if (hasProps && Object.prototype.hasOwnProperty.call(templateProps, key)) {
        return templateProps[key]
      }
      const value = Reflect.get(target, key, receiver)
      return typeof value === 'function' ? value.bind(target) : value
    }
  })
}

function getTemplateComponent(template) {
  const source = patchSlotDefaults(template)
  if (componentCache.has(source)) {
    return componentCache.get(source)
  }

  const renderFn = compileRenderFn(source)
  const component = defineComponent({
    name: 'CmsRuntimeTemplate',
    components: CMS_COMPONENTS,
    props: {
      runtimeCtx: { type: Object, required: true }
    },
    render() {
      return renderFn(this.runtimeCtx, [])
    }
  })

  componentCache.set(source, component)
  return component
}

function resolveParent(instance, explicitParent) {
  return (
    explicitParent ||
    instance?.parent?.proxy ||
    instance?.proxy?.$parent
  )
}

export default {
  props: {
    template: String,
    parent: Object,
    templateProps: {
      type: Object,
      default: () => ({})
    }
  },
  render() {
    if (!this.template) {
      return null
    }

    const instance = getCurrentInstance()
    const parent = resolveParent(instance, this.parent)
    if (!parent) {
      return h('div')
    }

    const TemplateComponent = getTemplateComponent(this.template)
    const runtimeCtx = createRuntimeCtx(parent, this.templateProps)
    const vnode = h(TemplateComponent, { runtimeCtx })
    const appContext = parent.$?.appContext ?? instance?.appContext
    if (appContext) {
      vnode.appContext = appContext
    }
    return vnode
  }
}
</script>
