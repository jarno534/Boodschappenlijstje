<script lang="ts">
  export let store: string | null | undefined = '';
  let className = '';
  export { className as class };
</script>

{#if store === 'Albert Heijn'}
  <svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg" class={className}>
    <rect width="100" height="100" rx="22" fill="#00A0E2"/>
    <path d="M42 62C42 67.5 37.5 72 32 72C26.5 72 22 67.5 22 62C22 56.5 26.5 52 32 52H42V62Z" fill="white"/>
    <path d="M42 72V35C42 29.5 46.5 25 52 25C57.5 25 62 29.5 62 35V72" stroke="white" stroke-width="12" stroke-linecap="round"/>
    <path d="M42 52H52C57.5 52 62 56.5 62 62" stroke="white" stroke-width="12" stroke-linecap="round"/>
  </svg>
{:else if store === 'Colruyt'}
  <svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg" class={className}>
    <rect width="100" height="100" rx="22" fill="#FF5000"/>
    <path d="M25 75C25 50 45 25 75 25C75 40 60 50 45 75H25Z" fill="white"/>
    <circle cx="68" cy="65" r="8" fill="white"/>
  </svg>
{:else if store === 'Aldi'}
  <svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg" class={className}>
    <rect width="100" height="100" rx="22" fill="#00205B"/>
    <path d="M25 75C25 50 35 30 50 30C65 30 75 50 75 75" stroke="#00A4E4" stroke-width="12" stroke-linecap="round" fill="none"/>
    <path d="M35 75C35 60 42 45 50 45C58 45 65 60 65 75" stroke="#E4002B" stroke-width="8" stroke-linecap="round" fill="none"/>
    <path d="M45 75C45 70 47 62 50 62C53 62 55 70 55 75" stroke="#FFCD00" stroke-width="6" stroke-linecap="round" fill="none"/>
  </svg>
{:else if store === 'Lidl'}
  <svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg" class={className}>
    <rect width="100" height="100" rx="22" fill="#0050A1"/>
    <circle cx="50" cy="52" r="36" fill="#FFD600" stroke="#E2001A" stroke-width="6"/>
    <text x="50" y="64" fill="#0050A1" font-family="system-ui, sans-serif" font-weight="900" font-size="32" text-anchor="middle" transform="rotate(-10 50 52)">LIDL</text>
  </svg>
{:else if store === 'Delhaize'}
  <svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg" class={className}>
    <rect width="100" height="100" rx="22" fill="#E2001A"/>
    <path d="M35 75 C35 75 33 60 40 55 C47 50 50 45 48 38 C46 31 52 25 60 25 C68 25 72 31 70 38 C68 45 65 48 55 53 C50 55 48 65 52 75" stroke="white" stroke-width="8" stroke-linecap="round" fill="none"/>
    <path d="M60 40 H75 M60 48 H72" stroke="white" stroke-width="6" stroke-linecap="round"/>
  </svg>
{:else if store === 'Carrefour'}
  <svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg" class={className}>
    <rect width="100" height="100" rx="22" fill="#F4F4F9" stroke="#E2E8F0" stroke-width="2"/>
    <path d="M50 15 L15 50 L50 85 Z" fill="#E2001A"/>
    <path d="M50 15 L85 50 L50 85 Z" fill="#00569C"/>
    <path d="M56 32 C48 32 42 38 42 50 C42 62 48 68 56 68 C62 68 66 64 66 64 L66 53 H56 V47 H74 V63 C74 63 66 76 54 76 C38 76 28 65 28 50 C28 35 38 24 54 24 C66 24 74 37 74 37 Z" fill="#F4F4F9"/>
  </svg>
{/if}
