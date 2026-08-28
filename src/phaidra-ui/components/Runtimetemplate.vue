<script>
import { useRootStore } from '~/stores/root'
import { h, defineComponent, getCurrentInstance } from 'vue'
import { compile, NodeTypes } from '@vue/compiler-dom'
import * as runtimeDom from '@vue/runtime-dom'
import { cmsRuntimeComponents } from '../utils/cms-runtime-components'
import { ClientOnly, NuxtLink } from '#components'
import { cmsLocalComponents } from '../utils/cms-local-components'

const CMS_COMPONENTS = {
  ...cmsRuntimeComponents,
  ...cmsLocalComponents,
  NuxtLink,
  ClientOnly
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

function preprocessTemplate(source) {
  const styles = []
  const cleaned = (source || '<div></div>')
    .replace(/<style\b[^>]*>([\s\S]*?)<\/style>/gi, (_, css) => {
      const trimmed = css.trim()
      if (trimmed) {
        styles.push(trimmed)
      }
      return ''
    })
    .replace(/<script\b[^>]*>[\s\S]*?<\/script>/gi, '')

  return { cleaned, styles }
}

function injectTemplateStyles(styles, cacheKey) {
  if (!import.meta.client || !styles.length) {
    return
  }
  const id = `cms-template-styles-${cacheKey}`
  if (document.getElementById(id)) {
    return
  }
  const el = document.createElement('style')
  el.id = id
  el.textContent = styles.join('\n')
  document.head.appendChild(el)
}

function templateCacheKey(source, styles) {
  let hash = 0
  const input = source + styles.join('\0')
  for (let i = 0; i < input.length; i++) {
    hash = ((hash << 5) - hash) + input.charCodeAt(i)
    hash |= 0
  }
  return Math.abs(hash).toString(36)
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
  const { cleaned, styles } = preprocessTemplate(template)
  const source = patchSlotDefaults(cleaned)
  const cacheKey = templateCacheKey(source, styles)
  if (componentCache.has(cacheKey)) {
    return componentCache.get(cacheKey)
  }

  const renderFn = compileRenderFn(source)
  const component = defineComponent({
    name: 'CmsRuntimeTemplate',
    components: CMS_COMPONENTS,
    props: {
      runtimeCtx: { type: Object, required: true }
    },
    mounted() {
      injectTemplateStyles(styles, cacheKey)
    },
    render() {
      const ctx = this.runtimeCtx
      // Header CMS template does not reference signedin; track auth so nav re-renders
      void ctx?.signedin
      void useRootStore().user?.token
      return renderFn(ctx, [])
    }
  })

  componentCache.set(cacheKey, component)
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

    // Re-render CMS templates when auth state on the parent changes.
    void parent.signedin
    void useRootStore().user?.token

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
