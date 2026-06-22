export default defineNuxtConfig({
  devtools: { enabled: true },

  ssr: true,

  runtimeConfig: {
    public: {
      apiUrl: process.env.VITE_API_URL || 'http://localhost:3000',
    },
  },

  modules: [],

  css: [],

  vite: {
    server: {
      proxy: {
        '/api': {
          target: 'http://localhost:3000',
          changeOrigin: true,
        },
      },
    },
  },
});
