<script lang="ts">
  import type { Profile } from '$lib/supabase';
  import { supabase } from '$lib/supabase';
  import { X } from 'lucide-svelte';

  export let profiles: Profile[] = [];
  export let onClose: () => void;
  export let onRefresh: () => void;

  let editingProfiles = profiles.map(p => ({ ...p }));
  let isSaving = false;

  async function save() {
    isSaving = true;
    for (const p of editingProfiles) {
      // update all profiles
      await supabase.from('profiles').update({ name: p.name, color: p.color }).eq('id', p.id);
    }
    isSaving = false;
    onRefresh();
    onClose();
  }
</script>

<div class="fixed inset-0 z-50 bg-black/50 flex items-center justify-center p-4">
  <div class="bg-white rounded-2xl p-6 w-full max-w-sm shadow-xl relative">
    <button class="absolute top-4 right-4 text-gray-400 hover:text-gray-700" on:click={onClose}>
      <X size={24} />
    </button>
    
    <h2 class="text-xl font-bold mb-6 text-gray-800">Instellingen</h2>

    <div class="space-y-4 max-h-[60vh] overflow-y-auto">
      {#each editingProfiles as profile}
        <div class="flex items-center gap-3">
          <input type="color" bind:value={profile.color} class="w-10 h-10 rounded-lg cursor-pointer shrink-0 border-0 p-0" />
          <input 
            type="text" 
            bind:value={profile.name} 
            class="w-full px-3 py-2 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
            placeholder="Naam"
          />
        </div>
      {/each}
    </div>

    <button 
      class="w-full mt-6 bg-gray-900 text-white font-semibold py-3 rounded-xl disabled:opacity-50 transition-colors"
      on:click={save}
      disabled={isSaving}
    >
      {isSaving ? 'Opslaan...' : 'Opslaan'}
    </button>
  </div>
</div>
