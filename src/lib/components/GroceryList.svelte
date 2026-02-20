<script lang="ts">
  import type { Grocery, Profile } from '$lib/supabase';
  import { supabase } from '$lib/supabase';
  import { Check, Trash2, Camera, User, X } from 'lucide-svelte';

  export let groceries: Grocery[] = [];
  export let profiles: Profile[] = [];
  export let onRefresh: () => void;
  export let currentProfile: Profile;

  let allSelected = false;
  let fullscreenPhotoUrl: string | null = null;
  let isDeleteDialogOpen = false;

  function toggleSelectAll() {
    allSelected = !allSelected;
    let newStatus = allSelected;
    groceries = groceries.map(g => ({ ...g, is_done: newStatus }));
    updateAllStatus(newStatus);
  }

  async function toggleStatus(grocery: Grocery) {
    const idx = groceries.findIndex(g => g.id === grocery.id);
    if (idx !== -1) {
      groceries[idx].is_done = !groceries[idx].is_done;
      await supabase.from('groceries').update({ is_done: groceries[idx].is_done }).eq('id', grocery.id);
    }
  }

  async function updateAllStatus(status: boolean) {
    const ids = groceries.map(g => g.id);
    if (ids.length > 0) {
      await supabase.from('groceries').update({ is_done: status }).in('id', ids);
    }
  }

  async function executeDelete() {
    isDeleteDialogOpen = false;
    const toDelete = groceries.filter(g => g.is_done).map(g => g.id);
    if (toDelete.length > 0) {
      await supabase.from('groceries').delete().in('id', toDelete);
      onRefresh();
      allSelected = false;
    }
  }

  function getProfileColor(profileId: string) {
    return profiles.find(p => p.id === profileId)?.color || '#ccc';
  }
  
  function getProfileName(profileId: string) {
    return profiles.find(p => p.id === profileId)?.name || 'Onbekend';
  }
</script>

<div class="w-full flex justify-between items-center mb-4">
  <button 
    class="text-sm font-medium text-gray-500 hover:text-gray-900 transition-colors"
    on:click={toggleSelectAll}
  >
    {allSelected ? 'Deselecteer alles' : 'Selecteer alles'}
  </button>
  
  <button 
    on:click={() => isDeleteDialogOpen = true}
    class="flex items-center gap-1.5 text-sm font-medium text-red-500 hover:text-red-600 transition-colors px-3 py-1.5 rounded-lg hover:bg-red-50"
    disabled={!groceries.some(g => g.is_done)}
  >
    <Trash2 size={16} /> Verwijderen
  </button>
</div>

<div class="space-y-3">
  {#if groceries.length === 0}
    <div class="text-center py-10 text-gray-400">
      De lijst is leeg! Voeg iets toe bovenaan.
    </div>
  {/if}

  {#each groceries as item (item.id)}
    <button 
      class="w-full flex items-center gap-4 p-4 {item.is_action ? 'bg-red-50/40' : 'bg-white'} rounded-2xl shadow-sm border-l-8 text-left transition-all hover:bg-gray-50 active:scale-[0.98] {item.is_done ? 'opacity-60' : ''}"
      style="border-color: {getProfileColor(item.added_by)}"
      on:click={() => toggleStatus(item)}
    >
      <div 
        class="w-6 h-6 rounded-full border-2 flex items-center justify-center shrink-0 transition-colors {item.is_done ? 'bg-current text-white' : 'bg-transparent text-transparent'}"
        style="color: {currentProfile.color}; border-color: {item.is_done ? currentProfile.color : '#e5e7eb'};"
      >
        <Check size={14} class="stroke-[3]" />
      </div>

      <div class="flex-1 min-w-0">
        <span class="block text-lg font-medium break-words {item.is_done ? 'text-gray-400 line-through decoration-red-500 decoration-4' : 'text-gray-900'}">
          {#if item.is_action}
            <span class="inline-block bg-red-100 text-red-600 text-[10px] font-bold px-2 py-0.5 rounded-md mr-1 align-text-bottom uppercase tracking-wider">Actie</span>
          {/if}
          {item.name}
        </span>
        <div class="flex items-center gap-1 text-xs text-gray-400 mt-1">
          <User size={12} /> {getProfileName(item.added_by)}
        </div>
      </div>

      {#if item.photo_url}
        <button type="button" class="shrink-0 group relative p-0 border-0 bg-transparent" on:click|stopPropagation={() => fullscreenPhotoUrl = item.photo_url}>
          <img src={item.photo_url} alt={item.name} class="w-12 h-12 object-cover rounded-xl border border-gray-100 shadow-sm" />
          <div class="absolute inset-0 bg-black/20 rounded-xl opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
            <Camera size={16} class="text-white" />
          </div>
        </button>
      {/if}
    </button>
  {/each}
</div>

{#if fullscreenPhotoUrl}
  <button 
    type="button"
    class="fixed inset-0 z-50 bg-black/90 flex items-center justify-center p-4 border-0" 
    on:click={() => fullscreenPhotoUrl = null}
  >
    <img src={fullscreenPhotoUrl} alt="Vergrote foto" class="max-w-full max-h-full object-contain rounded-lg shadow-2xl" />
    <div class="absolute top-6 right-6 p-3 text-white bg-black/50 rounded-full hover:bg-black/80 transition-colors">
      <X size={28} />
    </div>
  </button>
{/if}

{#if isDeleteDialogOpen}
  <div class="fixed inset-0 z-50 bg-black/60 flex items-center justify-center p-4 backdrop-blur-sm animate-in fade-in duration-200">
    <div class="bg-white rounded-3xl p-6 w-full max-w-sm shadow-2xl animate-in fade-in zoom-in-95 duration-200 text-center">
      <div class="mx-auto w-16 h-16 bg-red-100 rounded-full flex items-center justify-center text-red-500 mb-4">
        <Trash2 size={32} />
      </div>
      <h3 class="text-xl font-bold text-gray-900 mb-2">Artikelen verwijderen</h3>
      <p class="text-gray-500 mb-8">Weet je zeker dat je alle geselecteerde artikelen wilt weggooien? Dit kan niet ongedaan worden gemaakt.</p>
      
      <div class="grid grid-cols-2 gap-3">
        <button 
          class="p-4 bg-gray-100 hover:bg-gray-200 rounded-2xl font-bold text-gray-700 transition-colors"
          on:click={() => isDeleteDialogOpen = false}
        >
          Annuleren
        </button>
        <button 
          class="p-4 bg-red-500 hover:bg-red-600 rounded-2xl font-bold text-white transition-colors"
          on:click={executeDelete}
        >
          Verwijderen
        </button>
      </div>
    </div>
  </div>
{/if}
