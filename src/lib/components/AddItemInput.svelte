<script lang="ts">
  import { Camera, RefreshCw, X } from 'lucide-svelte';
  import { supabase, type Profile } from '$lib/supabase';

  export let currentProfile: Profile;
  export let onAdded: () => void;

  let text = '';
  let isLoading = false;
  let fileInput: HTMLInputElement;

  async function handleSubmit() {
    if (!text.trim()) return;
    
    isLoading = true;
    const { data, error } = await supabase.from('groceries').insert({
      name: text.trim(),
      added_by: currentProfile.id,
      is_done: false,
    });

    if (!error) {
      text = '';
      onAdded();
    }
    isLoading = false;
  }

  async function handleFileUpload(event: Event) {
    const target = event.target as HTMLInputElement;
    if (!target.files || target.files.length === 0) return;

    if (!text.trim()) {
      alert("Typ eerst de naam van het artikel voordat je een foto toevoegt.");
      target.value = '';
      return;
    }

    const file = target.files[0];
    const fileExt = file.name.split('.').pop();
    const fileName = `${Math.random()}.${fileExt}`;
    const filePath = `photos/${fileName}`;

    isLoading = true;
    
    // Upload image to Supabase storage
    const { error: uploadError } = await supabase.storage.from('product-photos').upload(filePath, file);

    if (uploadError) {
      console.error(uploadError);
      alert("Fout bij uploaden foto");
      isLoading = false;
      return;
    }

    // Insert item with photo
    const { data: publicUrlData } = supabase.storage.from('product-photos').getPublicUrl(filePath);

    const { error: dbError } = await supabase.from('groceries').insert({
      name: text.trim(),
      added_by: currentProfile.id,
      is_done: false,
      photo_url: publicUrlData.publicUrl
    });

    if (!dbError) {
      text = '';
      onAdded();
    }
    
    target.value = '';
    isLoading = false;
  }
</script>

<form on:submit|preventDefault={handleSubmit} class="w-full flex items-center gap-2 mb-6" style="--profile-color: {currentProfile.color}">
  <div class="relative flex-1">
    <input
      type="text"
      placeholder="Wat wil je toevoegen?"
      bind:value={text}
      disabled={isLoading}
      class="w-full pl-5 pr-12 py-4 bg-white shadow-sm border-2 rounded-2xl focus:outline-none transition-colors text-lg"
      style={`border-color: ${currentProfile.color}33`}
      on:focus={(e) => (e.currentTarget.style.borderColor = currentProfile.color)}
      on:blur={(e) => {
        if (!e.currentTarget.value) e.currentTarget.style.borderColor = `${currentProfile.color}33`;
      }}
    />
    
    <label class="absolute right-3 top-1/2 -translate-y-1/2 p-2 text-gray-400 hover:text-gray-600 transition-colors cursor-pointer" style={isLoading ? 'pointer-events: none; opacity: 0.5' : ''}>
      <Camera size={24} />
      <input 
        type="file" 
        accept="image/*" 
        capture="environment" 
        class="hidden" 
        bind:this={fileInput}
        on:change={handleFileUpload}
      />
    </label>
  </div>
  
  <button 
    type="submit" 
    disabled={!text.trim() || isLoading}
    class="p-4 rounded-2xl text-white shadow-sm disabled:opacity-50 transition-transform active:scale-95 flex items-center justify-center min-w-[64px]"
    style="background-color: {currentProfile.color}"
  >
    {#if isLoading}
      <RefreshCw size={24} class="animate-spin" />
    {:else}
      Voeg toe
    {/if}
  </button>
</form>
