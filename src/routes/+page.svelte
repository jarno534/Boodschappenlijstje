<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase, type Profile, type Grocery } from '$lib/supabase';
  import ProfileSelector from '$lib/components/ProfileSelector.svelte';
  import SettingsModal from '$lib/components/SettingsModal.svelte';
  import AddItemInput from '$lib/components/AddItemInput.svelte';
  import GroceryList from '$lib/components/GroceryList.svelte';
  import { LogOut, Settings } from 'lucide-svelte';

  let profiles: Profile[] = [];
  let groceries: Grocery[] = [];
  let currentProfile: Profile | null = null;
  let isSettingsOpen = false;
  let isLoading = true;

  onMount(async () => {
    // Check local storage for saved profile
    const savedProfileId = localStorage.getItem('selectedProfileId');
    await loadProfiles();
    
    if (savedProfileId) {
      const found = profiles.find(p => p.id === savedProfileId);
      if (found) {
        currentProfile = found;
        await loadGroceries();
      }
    }
    
    // Subscribe to real-time updates for groceries
    const channel = supabase.channel('schema-db-changes')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'groceries' },
        (payload) => {
          loadGroceries();
        }
      )
      .subscribe();
      
    isLoading = false;
    
    return () => {
      supabase.removeChannel(channel);
    };
  });

  async function loadProfiles() {
    const { data } = await supabase.from('profiles').select('*').order('name');
    if (data) profiles = data;
  }

  async function loadGroceries() {
    const { data } = await supabase.from('groceries').select('*').order('created_at', { ascending: false });
    if (data) groceries = data;
  }

  function handleProfileSelect(profile: Profile) {
    currentProfile = profile;
    localStorage.setItem('selectedProfileId', profile.id);
    loadGroceries();
  }

  function handleLogout() {
    currentProfile = null;
    localStorage.removeItem('selectedProfileId');
  }
</script>

<div class="max-w-md mx-auto min-h-screen bg-gray-100 flex flex-col relative">
  {#if isLoading}
    <div class="flex-1 flex items-center justify-center">
      <div class="animate-pulse flex items-center justify-center space-x-2">
        <div class="w-3 h-3 bg-blue-500 rounded-full"></div>
        <div class="w-3 h-3 bg-pink-500 rounded-full"></div>
        <div class="w-3 h-3 bg-green-500 rounded-full"></div>
      </div>
    </div>
  {:else if !currentProfile}
    <div class="flex-1 bg-white">
      <ProfileSelector 
        {profiles} 
        onSelect={handleProfileSelect} 
        onOpenSettings={() => isSettingsOpen = true} 
      />
    </div>
  {:else}
    <!-- Main App Header -->
    <header 
      class="sticky top-0 z-10 px-4 py-4 backdrop-blur-md border-b flex justify-between items-center transition-colors"
      style={`background-color: ${currentProfile.color}11; border-color: ${currentProfile.color}33`}
    >
      <button class="flex items-center gap-3 text-left hover:opacity-80 transition-opacity" on:click={handleLogout}>
        <div 
          class="w-10 h-10 rounded-full flex items-center justify-center text-white font-bold text-xl shadow-sm"
          style="background-color: {currentProfile.color}"
        >
          {currentProfile.name.charAt(0).toUpperCase()}
        </div>
        <div>
          <h1 class="font-bold text-gray-900 leading-tight">Boodschappen</h1>
          <p class="text-xs text-blue-600 font-medium">Klik om profiel te wisselen</p>
        </div>
      </button>
    </header>

    <!-- Main Content -->
    <main class="flex-1 p-4 pb-24 overflow-y-auto">
      <AddItemInput 
        {currentProfile} 
        onAdded={loadGroceries}
      />
      
      <GroceryList 
        {groceries} 
        {profiles} 
        {currentProfile} 
        onRefresh={loadGroceries}
      />
    </main>
  {/if}

  <!-- Settings Modal -->
  {#if isSettingsOpen}
    <SettingsModal 
      {profiles} 
      onClose={() => isSettingsOpen = false} 
      onRefresh={async () => { await loadProfiles(); if (currentProfile) handleProfileSelect(profiles.find(p => p.id === currentProfile!.id) || profiles[0]); }} 
    />
  {/if}
</div>
