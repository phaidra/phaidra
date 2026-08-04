import { fromNodeMiddleware } from 'h3'
import legacyRedirect from '../../server-middleware/redirect'

// Keep existing redirect behavior while using Nuxt 4/Nitro middleware registration.
export default fromNodeMiddleware(legacyRedirect)
