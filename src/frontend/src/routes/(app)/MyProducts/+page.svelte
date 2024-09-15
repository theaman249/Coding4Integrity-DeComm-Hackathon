<script lang="ts">

    import { onMount } from "svelte";
    import { fullName } from "$lib/data/stores/stores";
    import ProductCards from "$lib/components/modules/app/ProductCards/ProductCards.svelte";
    import { accountType } from "$lib/data/stores/stores";
    import { actorBackend } from "$lib/motokoImports/backend";
    import Header  from "$lib/components/modules/Header/Header.svelte"
    let loaded = false;

    onMount(async () => {
      const resProduct = await actorBackend.getAllProductTypes();
    if ($accountType.value !== "undefined") {
      $accountType.value = "Personal Account";
      loaded = true;
    }
  });

  </script>
  <Header/>
  <div class="p-4 mt-24 xl:m-20 xl:p-20 xl:border-4 xl:border-zinc-400 xl:border-solid xl:shadow-2xl max-h-fit w-7/8">
    <div class=" h-fit w-full overflow-scroll mt-5">
        <div class="space-y-2">
          <h1 class="text-2xl font-bold ">Welcome {$fullName}!</h1>
        </div>
                {#if loaded == true}
                    <ProductCards />
                {/if}
    
</div>
</div>
  