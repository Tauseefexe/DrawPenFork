console.log('[DRAWPEN]: Extended toolbar page preloading...');

const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  // Renderer -> Main
  invokeCloseApp: () => ipcRenderer.invoke('close_app'),
  invokeDrawMode: () => ipcRenderer.invoke('enable_draw_mode'),
});
