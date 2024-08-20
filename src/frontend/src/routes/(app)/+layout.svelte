<script lang="ts">
  import "../../app.css";
  import { onNavigate } from '$app/navigation';
  import { loggedIn } from "$lib/data/stores/stores"
  import { Toaster } from "$lib/components/ui/sonner";
  import Header from "$lib/components/modules/Header/Header.svelte"

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


<Toaster />

{#if $loggedIn.value !== false}
  <Header />
{/if}

<slot />
