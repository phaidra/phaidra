import Mirador from 'mirador/dist/es/src/index';
import { miradorImageToolsPlugin } from 'mirador-image-tools';

const originalViewer = Mirador.viewer.bind(Mirador);
Mirador.viewer = (config, plugins = []) =>
  originalViewer(config, [...miradorImageToolsPlugin, ...plugins]);

export default Mirador;
