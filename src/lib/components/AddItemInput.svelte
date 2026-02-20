<script lang="ts">
  import { Camera, RefreshCw, Tag } from 'lucide-svelte';
  import { supabase } from '$lib/supabase';
  import type { Profile } from '$lib/supabase';
  import PhotoSourceModal from './PhotoSourceModal.svelte';

  export let currentProfile: Profile;
  export let onAdded: () => void;

  let text = '';
  let isLoading = false;
  let fileInputGeneral: HTMLInputElement;
  let fileInputCamera: HTMLInputElement;
  let isPhotoModalOpen = false;
  let isAction = false;

  async function handleSubmit() {
    if (!text.trim()) return;
    
    isLoading = true;
    const { error } = await supabase.from('groceries').insert({
      name: text.trim(),
      added_by: currentProfile.id,
      is_done: false,
      is_action: isAction,
      photo_url: null
    });

    if (!error) {
      text = '';
      isAction = false;
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
      photo_url: publicUrlData.publicUrl
    });

    if (!dbError) {
      text = '';
      isAction = false;
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
