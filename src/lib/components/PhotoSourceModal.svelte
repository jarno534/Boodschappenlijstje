<script lang="ts">
  import { Camera, Image as ImageIcon, X } from 'lucide-svelte';

  export let onClose: () => void;
  export let onSelectLibrary: () => void;
  export let onSelectCamera: () => void;
</script>

<div class="fixed inset-0 z-50 bg-black/50 flex items-center justify-center p-4">
  <div class="bg-white rounded-3xl p-6 w-full max-w-sm shadow-2xl relative animate-in fade-in zoom-in-95 duration-200">
    <button class="absolute top-4 right-4 p-2 text-gray-400 hover:text-gray-700 bg-gray-100 rounded-full transition-colors" on:click={onClose}>
      <X size={20} />
    </button>
    
    <h2 class="text-xl font-bold mb-6 text-gray-800 pr-8">Foto toevoegen</h2>

    <div class="grid grid-cols-2 gap-4">
      <button 
        class="flex flex-col items-center justify-center gap-3 p-6 bg-blue-50 hover:bg-blue-100 rounded-2xl transition-colors border-2 border-transparent hover:border-blue-200"
        on:click={onSelectCamera}
      >
        <div class="w-12 h-12 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 mb-1">
          <Camera size={26} />
        </div>
        <span class="font-semibold text-blue-900">Camera</span>
      </button>

      <button 
        class="flex flex-col items-center justify-center gap-3 p-6 bg-purple-50 hover:bg-purple-100 rounded-2xl transition-colors border-2 border-transparent hover:border-purple-200"
        on:click={onSelectLibrary}
      >
        <div class="w-12 h-12 rounded-full bg-purple-100 flex items-center justify-center text-purple-600 mb-1">
          <ImageIcon size={26} />
        </div>
        <span class="font-semibold text-purple-900">Gallerij</span>
      </button>
    </div>
  </div>
</div>
