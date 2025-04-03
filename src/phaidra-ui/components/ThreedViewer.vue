<template>
  <div ref="container" class="threed-viewer"></div>
</template>

<script>
import * as THREE from 'three';
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';

export default {
  name: 'ThreedViewer',
  props: {
    modelUrl: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      scene: null,
      camera: null,
      renderer: null,
      controls: null,
      model: null
    };
  },
  mounted() {
    this.initScene();
    this.loadModel();
    this.animate();
  },
  beforeDestroy() {
    // Cleanup
    if (this.renderer) {
      this.renderer.dispose();
    }
    if (this.model) {
      this.model.traverse((object) => {
        if (object.isMesh) {
          object.geometry.dispose();
          object.material.dispose();
        }
      });
    }
  },
  methods: {
    initScene() {
      // Create scene
      this.scene = new THREE.Scene();
      this.scene.background = new THREE.Color(0xf0f0f0);

      // Create camera
      this.camera = new THREE.PerspectiveCamera(
        75,
        this.$refs.container.clientWidth / this.$refs.container.clientHeight,
        0.1,
        1000
      );
      this.camera.position.z = 5;

      // Create renderer
      this.renderer = new THREE.WebGLRenderer({ antialias: true });
      this.renderer.setSize(this.$refs.container.clientWidth, this.$refs.container.clientHeight);
      this.$refs.container.appendChild(this.renderer.domElement);

      // Add lights
      const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
      this.scene.add(ambientLight);

      const directionalLight = new THREE.DirectionalLight(0xffffff, 0.5);
      directionalLight.position.set(0, 1, 0);
      this.scene.add(directionalLight);

      // Add controls
      this.controls = new OrbitControls(this.camera, this.renderer.domElement);
      this.controls.enableDamping = true;
      this.controls.dampingFactor = 0.05;

      // Handle window resize
      window.addEventListener('resize', this.onWindowResize);
    },
    loadModel() {
      const loader = new GLTFLoader();
      loader.load(
        this.modelUrl,
        (gltf) => {
          this.model = gltf.scene;
          this.scene.add(this.model);

          // Center and scale the model
          const box = new THREE.Box3().setFromObject(this.model);
          const center = box.getCenter(new THREE.Vector3());
          const size = box.getSize(new THREE.Vector3());
          
          const maxDim = Math.max(size.x, size.y, size.z);
          const scale = 2 / maxDim;
          this.model.scale.setScalar(scale);
          
          this.model.position.sub(center.multiplyScalar(scale));
        },
        (xhr) => {
          console.log((xhr.loaded / xhr.total * 100) + '% loaded');
        },
        (error) => {
          console.error('Error loading model:', error);
        }
      );
    },
    animate() {
      requestAnimationFrame(this.animate);
      this.controls.update();
      this.renderer.render(this.scene, this.camera);
    },
    onWindowResize() {
      this.camera.aspect = this.$refs.container.clientWidth / this.$refs.container.clientHeight;
      this.camera.updateProjectionMatrix();
      this.renderer.setSize(this.$refs.container.clientWidth, this.$refs.container.clientHeight);
    }
  }
};
</script>

<style scoped>
.threed-viewer {
  width: 100%;
  height: 500px;
  background-color: #f0f0f0;
}
</style> 