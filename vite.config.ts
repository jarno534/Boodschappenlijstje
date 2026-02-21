import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import tailwindcss from '@tailwindcss/vite';
import { SvelteKitPWA } from '@vite-pwa/sveltekit';

export default defineConfig({
	plugins: [
		tailwindcss(),
		sveltekit(),
		SvelteKitPWA({
			registerType: 'autoUpdate',
			manifest: {
				name: 'Boodschappen',
				short_name: 'Boodschappen',
				description: 'Gedeelde Boodschappenlijst',
				theme_color: '#ffffff',
				background_color: '#ffffff',
				display: 'standalone',
				icons: [
					{
						src: '/icon-192x192.png',
						sizes: '192x192',
						type: 'image/png'
					},
					{
						src: '/icon-512x512.png',
						sizes: '512x512',
						type: 'image/png'
					},
					{
						src: '/icon-512x512.png',
						sizes: '512x512',
						type: 'image/png',
						purpose: 'any maskable'
					}
				]
			}
		})
	]
});
