{{flutter_js}}
{{flutter_build_config}}

// Убираем надписи загрузки - используем наш собственный loading экран
_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
  }
}); 