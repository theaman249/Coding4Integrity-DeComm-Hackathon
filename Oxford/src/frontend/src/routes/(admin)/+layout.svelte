<script lang="ts">
  import "../../app.css";
  import { onNavigate } from '$app/navigation';
  import { loggedIn } from "$lib/data/stores/stores"
  import { Toaster } from "$lib/components/ui/sonner";
  import Header from "$lib/components/modules/Header/Header.svelte"
  import Footer from "$lib/components/modules/admin/Footer/Footer.svelte";

  $: innerWidth = 0

  onNavigate((navigation) => {
    if (!(document as any).startViewTransition) return;
    return new Promise((resolve) => {
      (document as any).startViewTransition(async () => {
        resolve();
        await navigation.complete;
      });
    });
  });
</script>

<svelte:window bind:innerWidth />


<Toaster />

{#if $loggedIn.value !== false && innerWidth > 1024}
  <Header />
{/if}

<slot />

{#if $loggedIn.value !== false}
  <Footer />
{/if}
