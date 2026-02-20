<script lang="ts">
  import type { Profile } from '$lib/supabase';
  import { supabase } from '$lib/supabase';
  import { X, Plus, Trash2 } from 'lucide-svelte';

  export let profiles: Profile[] = [];
  export let onClose: () => void;
  export let onRefresh: () => void;

  let editingProfiles = profiles.map(p => ({ ...p, isNew: false, isDeleted: false }));
  let isSaving = false;

  async function save() {
    isSaving = true;
    for (const p of editingProfiles) {
      if (p.isDeleted && !p.isNew) {
        await supabase.from('profiles').delete().eq('id', p.id);
      } else if (!p.isDeleted && p.isNew) {
        // Alleen name en color inserten (UUID wordt in DB gegenereerd)
        await supabase.from('profiles').insert({ name: p.name, color: p.color });
      } else if (!p.isDeleted && !p.isNew) {
        await supabase.from('profiles').update({ name: p.name, color: p.color }).eq('id', p.id);
      }
    }
    isSaving = false;
    onRefresh();
    onClose();
  }

  function addProfile() {
    editingProfiles = [...editingProfiles, { id: Date.now().toString(), name: '', color: '#3b82f6', isNew: true, isDeleted: false }];
  }

  function deleteProfile(id: string) {
    if (confirm("Weet je zeker dat je dit profiel wilt verwijderen? Alle gekoppelde boodschappen worden ook verwijderd!")) {
      editingProfiles = editingProfiles.map(p => p.id === id ? { ...p, isDeleted: true } : p);
    }
  }
</script>

<div class="fixed inset-0 z-50 bg-black/50 flex items-center justify-center p-4">
  <div class="bg-white rounded-2xl p-6 w-full max-w-sm shadow-xl relative">
    <button class="absolute top-4 right-4 text-gray-400 hover:text-gray-700" on:click={onClose}>
      <X size={24} />
    </button>
    
    <h2 class="text-xl font-bold mb-6 text-gray-800">Instellingen</h2>

    <div class="space-y-4 max-h-[60vh] overflow-y-auto mb-4">
      {#each editingProfiles.filter(p => !p.isDeleted) as profile}
        <div class="flex items-center gap-2">
          <input type="color" bind:value={profile.color} class="w-10 h-10 rounded-lg cursor-pointer shrink-0 border-0 p-0" />
          <input 
            type="text" 
            bind:value={profile.name} 
            class="w-full px-3 py-2 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all"
            placeholder="Naam"
          />
          <button class="p-2 text-red-500 hover:bg-red-50 rounded-lg transition-colors" on:click={() => deleteProfile(profile.id)}>
            <Trash2 size={20} />
          </button>
        </div>
      {/each}
      
      <button 
        class="w-full py-3 flex items-center justify-center gap-2 text-blue-600 font-medium hover:bg-blue-50 rounded-xl transition-colors border-2 border-dashed border-blue-200" 
        on:click={addProfile}
      >
        <Plus size={20} /> Nieuw profiel
      </button>
    </div>

    <button 
      class="w-full mt-2 bg-gray-900 text-white font-semibold py-3 rounded-xl disabled:opacity-50 transition-colors"
      on:click={save}
      disabled={isSaving}
    >
      {isSaving ? 'Opslaan...' : 'Opslaan'}
    </button>
  </div>
</div>
