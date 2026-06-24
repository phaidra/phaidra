<script>
import { h, defineComponent } from 'vue'
import { compile } from '@vue/compiler-dom'
import * as runtimeDom from '@vue/runtime-dom'
import { ClientOnly, NuxtLink } from '#components'
import Icon from './Icon.vue'

const runtimeComponents = {
  NuxtLink,
  'nuxt-link': NuxtLink,
  ClientOnly,
  'client-only': ClientOnly,
  Icon,
  icon: Icon
};

const defineDescriptor = (src, dest, name) => {
    if (!dest.hasOwnProperty(name)) {
      const descriptor = Object.getOwnPropertyDescriptor(src, name);
      Object.defineProperty(dest, name, descriptor);
    }
  };
  
  const merge = objs => {
    const res = {};
    objs.forEach(obj => {
      obj &&
        Object.getOwnPropertyNames(obj).forEach(name =>
          defineDescriptor(obj, res, name)
        );
    });
    return res;
  };

  const renderCache = new Map();

  function compileTemplate(template) {
    const source = template || "<div></div>";
    if (!renderCache.has(source)) {
      const { code } = compile(source, { hoistStatic: true });
      renderCache.set(source, new Function("Vue", code)(runtimeDom));
    }
    return renderCache.get(source);
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
      if (this.template) {
        const parent = this.parent || this.$parent
        const {
          $options: parentOptions = {}
        } = parent;
        const {
          components: parentComponents = {}
        } = parentOptions;
        const components = { ...runtimeComponents, ...parentComponents };
        const provide = this.$parent?._provided ?? this.$parent?.$?.provides;
        const renderFn = compileTemplate(this.template);
        const templateProps = this.templateProps;
  
        const dynamic = defineComponent({
          components,
          ...(provide ? { provide } : {}),
          render() {
            const ctx = Object.keys(templateProps).length
              ? merge([parent, templateProps])
              : parent;
            return renderFn(ctx, []);
          }
        });
  
        const vnode = h(dynamic);
        if (parent.$?.appContext) {
          vnode.appContext = parent.$.appContext;
        }
        return vnode;
      }
    }
  };

</script>
