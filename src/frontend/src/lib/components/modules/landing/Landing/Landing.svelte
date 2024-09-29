<script lang="ts">

    import { onMount } from "svelte";
    import { quintOut } from "svelte/easing";
    import * as Menubar from "$lib/components/ui/menubar";
    import { fullName } from "$lib/data/stores/stores";
    import * as Tabs from "$lib/components/ui/tabs";
    import { Wallet } from "$lib/components/modules/landing/index.ts";
    import ScrollText from "lucide-svelte/icons/scroll-text";
    import { Bar , Line} from "$lib/components/modules/landing/index.ts";
    import {Button} from "$lib/components/ui/button";
    import {Transactions} from "$lib/components/modules/landing/index.ts";
    import {Spending} from "$lib/components/modules/landing/index.ts";
    import {Income} from "$lib/components/modules/landing/index.ts";
    import * as Card from "$lib/components/ui/card/index.js";
    import ProductCards from "$lib/components/modules/app/ProductCards/ProductCards.svelte";
    import { accountType } from "$lib/data/stores/stores";
    import { goto } from "$app/navigation";
    import { actorBackend } from "$lib/motokoImports/backend";
  
    let posts = false;
    let converted;
  
    let loaded = false;

    onMount(async () => {
     const resProduct = await actorBackend.getAllProductTypes();
    if ($accountType.value !== "undefined") {
      $accountType.value = "Personal Account";
      loaded = true;
    }
  });

  async function viewItems()
  {
    console.log ('OPENING ORIGINAL LANDING PAGE');
     goto("/MyProducts");
  }

  </script>
  
  <div class="p-4 mt-24 xl:m-20 xl:p-20 xl:border-4 xl:border-zinc-400 xl:border-solid xl:shadow-2xl max-h-fit w-full">
    <div class=" h-fit w-full overflow-scroll mt-5">
        <div class="space-y-2">
          <h1 class="text-2xl font-bold ">Welcome {$fullName}!</h1>
        </div>

        <Tabs.Root value="Overview" class=" space-y-1 mt-3">
            <Tabs.List>
              <Tabs.Trigger value="Overview">Overview</Tabs.Trigger>
              <Tabs.Trigger value="Transactions">Transactions</Tabs.Trigger>
            </Tabs.List>
            <Tabs.Content value="Overview">
                <div class="grid grid-cols-8">
                  <div class="col-span-3 p-1 h-full"><Line/></div>
                  <div class="col-span-3 p-1 grid grid-cols-2 gap-2 "> 
                      <div class="h-1/3 p-1"><Spending/> </div>
                      <div class="h-1/3 p-1"><Income/> </div>
                    <div class=" col-span-2 px-2"><Bar/></div>
                  </div>
                  <div class="space-y-1 h-full col-span-2">
                    <div class="space-y-2 space-x-2 mt-2 h-full"> 
                      <Wallet/>
                      <Card.Root class="col-span-3 space-y-0 mb-2">
                               <Card.Header class="flex flex-row items-center justify-between space-y-0 pb-2">
                                 <Card.Title  class="text-m font-medium" > My Items </Card.Title>
                                 <ScrollText class="text-muted-foreground h-8 w-8" />
                               </Card.Header>
                               <Card.Content> 
                                <Card.Description>View your purchased Items here and shop for more.</Card.Description>
                                 <Button class="w-24 ml-36"on:click={() => {viewItems() }}> View Items  </Button>
                               </Card.Content>
                             </Card.Root> 
                    </div>
                </div>
                </div>
                
            </Tabs.Content>
            <Tabs.Content value="Transactions">
              <div class="flex space-x-2 space-y-1"> 
                <Card.Root class="col-span-3 w-3/4">
                  <Card.Header>
                    <Card.Title>Latest Transactions</Card.Title>
                    <Card.Description>View the history of how you spent your Knowledge Tokens.</Card.Description>
                  </Card.Header>
                  <Card.Content>
                    <Transactions/>
                  </Card.Content>
                </Card.Root>
                <div class="space-y-1 w-1/4 h-full ">
                  <Wallet/>
                  <div class="flex h-fit p-4 space-x-2 mt-2"> 
                  </div>
              </div>
              </div>
            </Tabs.Content>

          </Tabs.Root>


       

  </div>
</div>
  