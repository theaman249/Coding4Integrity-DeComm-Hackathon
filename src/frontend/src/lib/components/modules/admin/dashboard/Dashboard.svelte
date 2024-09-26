<script lang="ts">
  import { Button } from "$lib/components/ui/button";
  import ViewProducts from "$lib/components/modules/admin/ViewProducts/ViewProducts.svelte";
  import AddProduct from "$lib/components/modules/admin/AddProduct/AddProduct.svelte";
  import { fullName } from "$lib/data/stores/stores";
  import * as Tabs from "$lib/components/ui/tabs";
  import { onMount } from "svelte";
  import * as Card from "$lib/components/ui/card/index.js";

  onMount(()=>{

    console.log('Working!!');
  });

  let chosen = "Dashboard"; 

  //let chosen = "Add Products";
</script>

<div
  class="grid grid-cols-12 p-4 mt-24 xl:m-20 xl:p-20 xl:border-4 xl:border-zinc-400 xl:border-solid xl:shadow-2xl max-h-fit"
>
  <div class="col-span-12 h-fit grid grid-cols-12 w-full overflow-scroll mt-5">
    <div class="col-span-12">
      <h1 class="text-2xl font-bold">Welcome {$fullName}!</h1>

      <Tabs.Root value="Dashboard" class=" space-y-1 mt-3">
        <Tabs.List>
          <Tabs.Trigger value="Dashbaord">Dashboard</Tabs.Trigger>
          <Tabs.Trigger value="Add">Add Products</Tabs.Trigger>
          <Tabs.Trigger value="View">View Products</Tabs.Trigger>

        </Tabs.List>
        <Tabs.Content value="Dashboard">
            <div class="flex">
              </div>
              <div class="space-y-1 w-1/4 h-full ">
                <div class="space-y-2 space-x-2 mt-2"> 
                <p>DASHBOARD</p> 
                          <!-- come code for dashboard here -->

                </div>
            </div>
            
        </Tabs.Content>
        <!-- come code for Add Products here -->
        <Tabs.Content value="Add">
          <div class="flex space-x-2 space-y-1"> 
            <Card.Root class="col-span-3 w-full">
              <Card.Header>
                <Card.Title>Add Product</Card.Title>
                <Card.Description> Fill in the fields below to add your product to the DECOMM customer facing
                  website</Card.Description>
              </Card.Header>
              <Card.Content>
                <AddProduct />
              </Card.Content>
              </Card.Root>
          </div>
        </Tabs.Content>

      <!-- come code for View here -->
      <Tabs.Content value="View">
        <div class="flex space-x-2 space-y-1"> 
          <Card.Root class="col-span-3 w-full">
            <Card.Header>
              <Card.Title>View Products</Card.Title>
              <Card.Description>View a list of all the products you have added on the platforms.</Card.Description>
            </Card.Header>
            <Card.Content>
              <ViewProducts />
            </Card.Content>
          </Card.Root>
        </div>
      </Tabs.Content> 
      </Tabs.Root>
      
    </div>
  </div>
</div>
