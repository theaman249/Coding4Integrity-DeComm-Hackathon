<script lang="ts">
    import { Button } from "$lib/components/ui/button";
    import ViewProducts from "$lib/components/modules/admin/ViewProducts/ViewProducts.svelte";
    import AddProduct from "$lib/components/modules/admin/AddProduct/AddProduct.svelte"
    import { fullName } from "$lib/data/stores/stores";

    let chosen = "Add Products";
</script>

<div class="grid grid-cols-12 mt-3 p-2 xl:p-0 xl:mt-28">
    <div class="col-span-12 h-fit grid grid-cols-12 w-full lg:pl-20 overflow-scroll">
        <div class="col-span-12">
            <h1 class="text-2xl font-bold">Welcome {$fullName}!</h1>
            <p class="text-lg border-b-2 border-zinc-300 pb-5 mt-2 opacity-75">Manage your products and preferences here.</p>
        </div>
        <div class="col-span-12 grid grid-cols-12">
            <div class="col-span-12 lg:hidden flex px-2 justify-around mt-5">
                <div><Button class="w-full my-1 justify-start hover:underline {chosen === "Add Products" ? "bg-stone-100" : ""}" variant="ghost" on:click={()=> chosen = "Add Products"}>Add Producs</Button></div>
                <div><Button class="w-full my-1 justify-start hover:underline {chosen === "View Products" ? "bg-stone-100" : ""}" variant="ghost" on:click={()=> chosen = "View Products"}>View Products</Button></div>
            </div>
            <div class="hidden lg:col-span-2 lg:block mt-10">
                <div><Button class="w-full my-1 justify-start hover:underline {chosen === "Add Products" ? "bg-stone-100" : ""}" variant="ghost" on:click={()=> chosen = "Add Products"}>Add Producs</Button></div>
                <div><Button class="w-full my-1 justify-start hover:underline {chosen === "View Products" ? "bg-stone-100" : ""}" variant="ghost" on:click={()=> chosen = "View Products"}>View Products</Button></div>
            </div>
            <div class="col-span-12 lg:col-span-10 mt-10 px-2 lg:px-20 h-fit overflow-scroll">
                {#if chosen === "Add Products" }
                    <AddProduct />
                {:else if chosen === "View Products"}
                    <ViewProducts />
                {/if}
            </div>
        </div>
    </div>
</div>