<script lang="ts">
  import '../app.css';
  let { children } = $props();
</script>

<div class="min-h-screen pb-20">
  {@render children()}
</div>
