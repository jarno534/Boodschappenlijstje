<script lang="ts">
  import { Camera, RefreshCw, Tag, Store, X } from 'lucide-svelte';
  import { supabase } from '$lib/supabase';
  import type { Profile } from '$lib/supabase';
  import PhotoSourceModal from './PhotoSourceModal.svelte';
  import StoreLogo from './StoreLogo.svelte';

  export let currentProfile: Profile;
  export let onAdded: () => void;

  let text = '';
  let isLoading = false;
  let fileInputGeneral: HTMLInputElement;
  let fileInputCamera: HTMLInputElement;
  let isPhotoModalOpen = false;
  let isAction = false;
  let selectedStore = '';
  let isStoreDropdownOpen = false;
  const stores = ['Delhaize', 'Colruyt', 'Aldi', 'Lidl', 'Albert Heijn', 'Carrefour'];

  function toggleStoreDropdown() {
    isStoreDropdownOpen = !isStoreDropdownOpen;
  }

  function selectStore(store: string) {
    selectedStore = store;
    isStoreDropdownOpen = false;
  }

  async function handleSubmit() {
    if (!text.trim()) return;
    
    isLoading = true;
    const { error } = await supabase.from('groceries').insert({
      name: text.trim(),
      added_by: currentProfile.id,
      is_done: false,
      is_action: isAction,
      store: selectedStore || null,
      photo_url: null
    });

    if (!error) {
      text = '';
      isAction = false;
      selectedStore = '';
      onAdded();
    } else {
      console.error(error);
      alert("Er ging iets mis bij het toevoegen.");
    }
    isLoading = false;
  }

  function handleCameraClick() {
    if (!text.trim()) {
      alert("Typ eerst de naam van het artikel voordat je een foto toevoegt.");
      return;
    }
    isPhotoModalOpen = true;
  }

  async function handleFileUpload(event: Event) {
    const target = event.target as HTMLInputElement;
    if (!target.files || target.files.length === 0) return;

    isPhotoModalOpen = false;
    const file = target.files[0];
    const fileExt = file.name.split('.').pop();
    const fileName = `${Math.random()}.${fileExt}`;
    const filePath = `photos/${fileName}`;

    isLoading = true;
    
    const { error: uploadError } = await supabase.storage.from('product-photos').upload(filePath, file);

    if (uploadError) {
      console.error(uploadError);
      alert("Fout bij uploaden foto");
      isLoading = false;
      return;
    }

    const { data: publicUrlData } = supabase.storage.from('product-photos').getPublicUrl(filePath);

    const { error: dbError } = await supabase.from('groceries').insert({
      name: text.trim(),
      added_by: currentProfile.id,
      is_done: false,
      is_action: isAction,
      store: selectedStore || null,
      photo_url: publicUrlData.publicUrl
    });

    if (!dbError) {
      text = '';
      isAction = false;
      selectedStore = '';
      onAdded();
    } else {
      console.error(dbError);
      alert("Er ging iets mis bij het toevoegen van het artikel met foto.");
    }
    
    target.value = '';
    isLoading = false;
  }
</script>

<form on:submit|preventDefault={handleSubmit} class="w-full flex flex-col gap-3 mb-6" style="--profile-color: {currentProfile.color}">
  <input
    type="text"
    placeholder="Wat wil je toevoegen?"
    bind:value={text}
    disabled={isLoading}
    class="w-full px-5 py-4 bg-white shadow-sm border-2 rounded-2xl focus:outline-none transition-colors text-lg font-medium"
    style={`border-color: ${currentProfile.color}33`}
    on:focus={(e) => (e.currentTarget.style.borderColor = currentProfile.color)}
    on:blur={(e) => {
      if (!e.currentTarget.value) e.currentTarget.style.borderColor = `${currentProfile.color}33`;
    }}
  />

  <!-- Store Dropdown -->
  <div class="relative w-full">
    <button
      type="button"
      on:click={toggleStoreDropdown}
      class="w-full flex items-center justify-between px-5 py-4 bg-white shadow-sm border-2 rounded-2xl hover:bg-gray-50 transition-all text-base font-medium text-left"
      style={`border-color: ${currentProfile.color}33`}
    >
      <div class="flex items-center gap-3">
        {#if selectedStore}
          <StoreLogo store={selectedStore} class="w-6 h-6 rounded-md shadow-sm shrink-0" />
          <span class="text-gray-950 font-semibold">{selectedStore}</span>
        {:else}
          <Store class="text-gray-400 shrink-0" size={20} />
          <span class="text-gray-400">Kies een winkel (optioneel)</span>
        {/if}
      </div>
      <span class="text-gray-400 text-xs transition-transform duration-200 {isStoreDropdownOpen ? 'rotate-180' : ''}">
        ▼
      </span>
    </button>

    {#if isStoreDropdownOpen}
      <button 
        type="button"
        class="fixed inset-0 z-20 bg-transparent cursor-default w-full h-full border-0 p-0" 
        on:click={() => isStoreDropdownOpen = false}
        aria-label="Sluit menu"
      ></button>
      
      <div class="absolute left-0 right-0 mt-2 bg-white rounded-2xl shadow-xl border border-gray-100 py-2 z-30 max-h-60 overflow-y-auto animate-in fade-in slide-in-from-top-2 duration-150">
        <button
          type="button"
          on:click={() => selectStore('')}
          class="w-full flex items-center gap-3 px-5 py-3 text-left hover:bg-gray-50 transition-colors text-sm font-semibold text-red-500"
        >
          <div class="w-6 h-6 rounded-md bg-red-50 flex items-center justify-center shrink-0">
            <X size={14} />
          </div>
          Geen specifieke winkel
        </button>
        
        <div class="h-px bg-gray-100 my-1"></div>

        {#each stores as storeOption}
          <button
            type="button"
            on:click={() => selectStore(storeOption)}
            class="w-full flex items-center justify-between px-5 py-3 text-left hover:bg-gray-50 transition-colors text-sm font-semibold text-gray-700 {selectedStore === storeOption ? 'bg-gray-50' : ''}"
          >
            <div class="flex items-center gap-3">
              <StoreLogo store={storeOption} class="w-6 h-6 rounded-md shadow-sm shrink-0" />
              <span>{storeOption}</span>
            </div>
            {#if selectedStore === storeOption}
              <span class="w-2 h-2 rounded-full" style="background-color: {currentProfile.color}"></span>
            {/if}
          </button>
        {/each}
      </div>
    {/if}
  </div>
  
  <div class="flex items-center justify-between w-full">
    <label 
      class="flex items-center gap-2 cursor-pointer bg-white px-4 py-3.5 rounded-2xl border-2 transition-colors shadow-sm select-none" 
      style={isAction ? 'border-color: #ef4444; background-color: #fef2f2; color: #dc2626;' : 'border-color: #f3f4f6; color: #6b7280;'}
    >
      <input type="checkbox" bind:checked={isAction} class="hidden" />
      <Tag size={20} class={isAction ? 'fill-red-100' : ''} />
      <span class="font-bold">Actie</span>
    </label>

    <div class="flex items-center gap-2">
      <button 
        type="button"
        class="p-4 bg-white rounded-2xl shadow-sm transition-colors border-2" 
        style={isLoading ? 'pointer-events: none; opacity: 0.5' : `border-color: ${currentProfile.color}33; color: ${currentProfile.color}`}
        on:click={handleCameraClick}
      >
        <Camera size={24} />
      </button>
      
      <button 
        type="submit" 
        disabled={!text.trim() || isLoading}
        class="p-4 px-6 rounded-2xl text-white shadow-sm disabled:opacity-50 transition-transform active:scale-95 flex items-center justify-center min-w-[100px] font-bold text-lg"
        style="background-color: {currentProfile.color}"
      >
        {#if isLoading}
          <RefreshCw size={24} class="animate-spin" />
        {:else}
          Voeg toe
        {/if}
      </button>
    </div>
  </div>
</form>

<!-- Use separate inputs to trigger different native behaviors (gallery vs camera app on mobile) -->
<input 
  type="file" 
  accept="image/*" 
  class="hidden" 
  bind:this={fileInputGeneral}
  on:change={handleFileUpload}
/>

<input 
  type="file" 
  accept="image/*" 
  capture="environment"
  class="hidden" 
  bind:this={fileInputCamera}
  on:change={handleFileUpload}
/>

{#if isPhotoModalOpen}
  <PhotoSourceModal 
    onClose={() => isPhotoModalOpen = false} 
    onSelectLibrary={() => { isPhotoModalOpen = false; fileInputGeneral.click(); }}
    onSelectCamera={() => { isPhotoModalOpen = false; fileInputCamera.click(); }}
  />
{/if}
