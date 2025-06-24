{{flutter_js}}
{{flutter_build_config}}

const loading = document.createElement('div');
loading.style.position = 'fixed';
loading.style.top = '50%';
loading.style.left = '50%';
loading.style.transform = 'translate(-50%, -50%)';
loading.style.textAlign = 'center';
loading.style.fontSize = '18px';
loading.style.color = '#333';
loading.textContent = "Loading Entrypoint...";
document.body.appendChild(loading);

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    loading.textContent = "Initializing engine...";
    const appRunner = await engineInitializer.initializeEngine();

    loading.textContent = "Running app...";
    await appRunner.runApp();
    
    // Remove loading indicator
    document.body.removeChild(loading);
  }
}); 