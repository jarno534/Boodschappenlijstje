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

  <div class="flex items-center justify-between w-full">
    <!-- Action Checkbox Button -->
    <label 
      class="flex items-center gap-2 cursor-pointer bg-white px-4 py-3.5 rounded-2xl border-2 transition-colors shadow-sm select-none text-sm" 
      style={isAction ? 'border-color: #ef4444; background-color: #fef2f2; color: #dc2626;' : 'border-color: #f3f4f6; color: #6b7280;'}
    >
      <input type="checkbox" bind:checked={isAction} class="hidden" />
      <Tag size={18} class={isAction ? 'fill-red-100' : ''} />
      <span class="font-bold">Actie</span>
    </label>

    <!-- Dropdown, Camera & Submit Button Row -->
    <div class="flex items-center gap-1.5">
      <!-- Store Dropdown Selector -->
      <div class="relative">
        <button
          type="button"
          on:click={toggleStoreDropdown}
          class="flex items-center gap-1.5 bg-white px-3 py-3.5 rounded-2xl border-2 transition-all shadow-sm text-sm font-bold text-gray-500 whitespace-nowrap"
          style={selectedStore ? `border-color: ${currentProfile.color}; color: ${currentProfile.color}; background-color: ${currentProfile.color}08;` : 'border-color: #f3f4f6;'}
        >
          {#if selectedStore}
            <StoreLogo store={selectedStore} class="h-5 w-auto max-w-[48px] rounded-md shadow-sm shrink-0" />
            <span class="truncate max-w-[70px]">{selectedStore}</span>
          {:else}
            <Store size={18} class="shrink-0 text-gray-400" />
            <span>Winkel</span>
          {/if}
          <span class="text-[10px] text-gray-400">▼</span>
        </button>

        {#if isStoreDropdownOpen}
          <button 
            type="button"
            class="fixed inset-0 z-20 bg-transparent cursor-default w-full h-full border-0 p-0" 
            on:click={() => isStoreDropdownOpen = false}
            aria-label="Sluit menu"
          ></button>
          
          <div class="absolute bottom-full right-0 mb-2 w-52 bg-white rounded-2xl shadow-xl border border-gray-100 py-2 z-30 animate-in fade-in slide-in-from-bottom-2 duration-150">
            <button
              type="button"
              on:click={() => selectStore('')}
              class="w-full flex items-center gap-3 px-5 py-2.5 text-left hover:bg-gray-50 transition-colors text-sm font-semibold text-red-500"
            >
              <div class="w-6 h-6 rounded-md bg-red-50 flex items-center justify-center shrink-0">
                <X size={14} />
              </div>
              Geen winkel
            </button>
            
            <div class="h-px bg-gray-100 my-1"></div>

            {#each stores as storeOption}
              <button
                type="button"
                on:click={() => selectStore(storeOption)}
                class="w-full flex items-center justify-between px-5 py-2.5 text-left hover:bg-gray-50 transition-colors text-sm font-semibold text-gray-700 {selectedStore === storeOption ? 'bg-gray-50' : ''}"
              >
                <div class="flex items-center gap-3">
                  <StoreLogo store={storeOption} class="h-6 w-auto max-w-[48px] rounded-md shadow-sm shrink-0" />
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

      <!-- Camera button -->
      <button 
        type="button"
        class="p-3.5 bg-white rounded-2xl shadow-sm transition-colors border-2 text-gray-500 hover:text-gray-900 shrink-0" 
        style={isLoading ? 'pointer-events: none; opacity: 0.5' : `border-color: #f3f4f6;`}
        on:click={handleCameraClick}
      >
        <Camera size={20} />
      </button>

      <!-- Submit button -->
      <button 
        type="submit" 
        disabled={!text.trim() || isLoading}
        class="p-3.5 px-5 rounded-2xl text-white shadow-sm disabled:opacity-50 transition-transform active:scale-95 flex items-center justify-center font-bold text-base shrink-0"
        style="background-color: {currentProfile.color}"
      >
        {#if isLoading}
          <RefreshCw size={20} class="animate-spin" />
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
