<script lang="ts">
  export let store: string | null | undefined = '';
  let className = '';
  export { className as class };

  function getLogoPath(name: string | null | undefined): string | null {
    if (!name) return null;
    switch (name) {
      case 'Albert Heijn':
        return '/images/stores/albert_heijn.svg';
      case 'Colruyt':
        return '/images/stores/colruyt.svg';
      case 'Aldi':
        return '/images/stores/aldi.svg';
      case 'Lidl':
        return '/images/stores/lidl.svg';
      case 'Delhaize':
        return '/images/stores/delhaize.svg';
      case 'Carrefour':
        return '/images/stores/carrefour.svg';
      default:
        return null;
    }
  }

  $: logoPath = getLogoPath(store);
</script>

{#if logoPath}
  <img 
    src={logoPath} 
    alt={store} 
    class="object-contain bg-white rounded-md p-0.5 {className}"
  />
{/if}
