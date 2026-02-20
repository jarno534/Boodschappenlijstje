<script lang="ts">
  import type { Profile } from '$lib/supabase';
  
  export let profiles: Profile[] = [];
  export let onSelect: (profile: Profile) => void;
  export let onOpenSettings: () => void;
</script>

<div class="flex flex-col items-center justify-center min-h-[80vh] p-4 text-center">
  <h1 class="text-3xl font-bold mb-8 text-gray-800">Wie ben je?</h1>
  
  <div class="grid grid-cols-2 gap-4 w-full max-w-sm">
    {#each profiles as profile}
      <button
        class="aspect-square rounded-2xl flex items-center justify-center text-2xl font-semibold shadow-sm transition-transform active:scale-95 text-white"
        style="background-color: {profile.color}"
        on:click={() => onSelect(profile)}
      >
        {profile.name}
      </button>
    {/each}
  </div>

  <button 
    class="mt-12 text-gray-400 hover:text-gray-600 underline underline-offset-4 text-sm font-medium transition-colors"
    on:click={onOpenSettings}
  >
    Profielen instellen
  </button>
</div>
