<script lang="ts">
    import * as Table from "$lib/components/ui/table/index.js";
    import { actorBackend } from "$lib/motokoImports/backend";
    import { onMount } from 'svelte';
    import Skeleton from '$lib/components/ui/skeleton/skeleton.svelte';
    import { fullName } from "$lib/data/stores/stores";
    import * as Sheet from "$lib/components/ui/sheet/index.js";
    import { Button } from "$lib/components/ui/button/index.js";
    import { Input } from "$lib/components/ui/input/index.js";
    import { Label } from "$lib/components/ui/label/index.js";
    import { superForm, defaults } from "sveltekit-superforms/client"
    import { z } from "zod"
    import { zod } from 'sveltekit-superforms/adapters'
    import Reload from "svelte-radix/Reload.svelte";
    import * as Select from "$lib/components/ui/select";
    import { Textarea } from "$lib/components/ui/textarea/";

    let showSkeleton = true;
    let products : any[] = [];
    let loaded = false;
    let formSubmitted = false;
    $: selectedCurrency = "USD";
    $: selectedCategory = "Electronics";
    const supportedCurrencies = ["usd", "gbp", "eur", "icp", "btc", "eth"];

    const currencies = [
        { value: "USD", label: "USD" },
        { value: "Euro", label: "Euro" },
        { value: "BGP", label: "BGP" },
        { value: "BTC", label: "BTC" },
        { value: "ETH", label: "ETH" },
        { value: "ICP", label: "ICP" },
    ];

    const categories = [
        { value: "Electronics", label: "Electronics" },
        { value: "Clothing", label: "Clothing & Apparel" },
        { value: "Home", label: "Home & Kitchen" },
        { value: "Beauty & Personal Care", label: "Beauty & Personal Care" },
        { value: "Books", label: "Books & Audible" },
        { value: "Toys & Games", label: "Toys & Games" },
        { value: "Sports & Outdoors", label: "Sports & Outdoors" },
        { value: "Automotive", label: "Automotive" },
        { value: "Office Products", label: "Office Products" },
        { value: "Musical Instruments", label: "Musical Instruments" },
    ];

    const newContactSchema = z.object({
        Name: z.string().min(2).max(15),
        sDesc: z.string().min(10).max(200),
        lDesc: z.string().min(50).max(2069),
        price: z.number().min(1).max(100000),
    })

    const { form, enhance, constraints } = superForm(defaults(zod(newContactSchema)), {
        SPA: true,
        validators: zod(newContactSchema),
            onSubmit(){
                formSubmitted = true;
            },
            onUpdated({ form }) {

            },
    })

    onMount(async () => {
        try {
            products = await actorBackend.getAllProductTypes();
            console.log(products)
            showSkeleton = false;
            loaded = true;
        } catch (err: unknown) {
            console.error(err);
        };
    });

    function handlelDesc(event) {
        product.productLongDesc = event.target.value;
        $form.lDesc = event.target.value;
    }

    function handlelSDesc(event) {
        product.productShortDesc = event.target.value;
        $form.SDesc = event.target.value;
    }
</script>


<h2 class="text-xl font-semibold ml-2 mb-5">Products</h2>
{#if showSkeleton}
    <div class="col-span-1"></div>
    <div class="col-span-10">
        <Table.Root>
            <Table.Caption>List of your products</Table.Caption>
            <Table.Header>
                <Table.Row class="max-[400px]:text-xs max-[500px]:text-md">
                    <Table.Head class="{innerWidth <= 800 ? 'w-[33%]' : 'w-1/5'}">Product Name</Table.Head>
                    {#if innerWidth > 800}
                        <Table.Head class="{innerWidth <= 800 ? 'w-[32%]' : 'w-1-/10'}">Price</Table.Head>
                        <Table.Head class="{innerWidth <= 800 ? 'w-[33%]' : 'w-1-/10'}">Description</Table.Head>
                    {/if}
                    <Table.Head class="{innerWidth <= 800 ? 'w-[43%]' : 'w-1/5'} text-right">More Details</Table.Head>
                </Table.Row>
            </Table.Header>
            <Table.Body>
                {#each Array.from({ length: 20 }, (_, i) => i) as index}
                    <Table.Row>
                        <Table.Cell class="font-medium">
                            <Skeleton class="w-[60%] h-[27px]" />
                        </Table.Cell>
                        {#if innerWidth > 800}
                            <Table.Cell>
                                <Skeleton class="w-[40%] h-[27px]" />
                            </Table.Cell>
                            <Table.Cell>
                                <Skeleton class="w-[60%] h-[27px]" />
                            </Table.Cell>
                            
                        {/if}
                        <Table.Cell class="flex justify-end items-end">
                            <Skeleton class="w-[40%] h-[27px]" />
                        </Table.Cell>
                    </Table.Row>
                {/each}
            </Table.Body>
        </Table.Root>
    </div>
    <div class="col-span-1"></div>
{:else}
<div class="col-span-1"></div>
<div class="col-span-10">
    {#if loaded}
        {#if products.length > 0}
            <Table.Root>
                <Table.Caption>List of your products</Table.Caption>
                <Table.Header>
                    <Table.Row class="max-[400px]:text-xs max-[500px]:text-md">
                        <Table.Head class="{innerWidth <= 800 ? 'w-[33%]' : 'w-1/5'}">Product Name</Table.Head>
                        {#if innerWidth > 800}
                            <Table.Head class="{innerWidth <= 800 ? 'w-[32%]' : 'w-1-/10'}">Price</Table.Head>
                            <Table.Head class="{innerWidth <= 800 ? 'w-[33%]' : 'w-1-/10'}">Description</Table.Head>
                        {/if}
                        <Table.Head class="{innerWidth <= 800 ? 'w-[43%]' : 'w-1/5'} text-right">More Details</Table.Head>
                    </Table.Row>
                </Table.Header>
                <Table.Body>
                    {#each products as product}
                        {#if product.sellerID === $fullName}
                            <Table.Row>
                                <Table.Cell class="font-medium">
                                    {product.name}
                                </Table.Cell>
                                {#if innerWidth > 800}
                                    <Table.Cell>
                                        {product.productPrice.amount}
                                    </Table.Cell>
                                    <Table.Cell>
                                        {product.productShortDesc}
                                    </Table.Cell>
                                {/if}
                                <Table.Cell class="flex justify-end items-end">
                                    <form method="POST" use:enhance>
                                        <Sheet.Root>
                                            <Sheet.Trigger asChild let:builder>
                                            <Button builders={[builder]} variant="outline">View More Details</Button>
                                            </Sheet.Trigger>
                                            <Sheet.Content side="right">
                                            <Sheet.Header>
                                                <Sheet.Title>Edit Product</Sheet.Title>
                                                <Sheet.Description>
                                                Make changes to your products here. Click save when you're done.
                                                </Sheet.Description>
                                            </Sheet.Header>
                                            <div class="grid gap-4 py-4">
                                                <div class="grid grid-cols-4 items-center gap-4">
                                                    <Label for="name">Name</Label>
                                                    <Input class="col-span-3" type="text" id="Name" name="Name" placeholder={product.name} bind:value={$form.Name} {...$constraints.Name} />
                                                </div>
                                                <div class="grid grid-cols-4 items-center gap-4">
                                                    <Label for="price">Category</Label>
                                                    <Select.Root
                                                    onSelectedChange={(v) =>{
                                                        v && (selectedCategory = v.value)
                                                    }}
                                                    >
                                                        <Select.Trigger class="col-span-3">
                                                        <Select.Value placeholder="{product.productCategory}" />
                                                        </Select.Trigger>
                                                        <Select.Content>
                                                        <Select.Group>
                                                            <Select.Label>Category</Select.Label>
                                                            {#each categories as category}
                                                            <Select.Item value={category.value} label={category.label}
                                                                >{category.label}</Select.Item
                                                            >
                                                            {/each}
                                                        </Select.Group>
                                                        </Select.Content>
                                                        <Select.Input name="favoriteFruit" />
                                                    </Select.Root>
                                                </div>
                                                <div class="grid grid-cols-4 items-center gap-4">
                                                    <Label for="price">Currency</Label>
                                                    <Select.Root
                                                    onSelectedChange={(v) =>{
                                                        v && (selectedCurrency = v.value)
                                                    }}
                                                    >
                                                        <Select.Trigger class="col-span-3">
                                                        <Select.Value />
                                                        </Select.Trigger>
                                                        <Select.Content>
                                                        <Select.Group>
                                                            <Select.Label>Currency</Select.Label>
                                                            {#each currencies as currency}
                                                            <Select.Item value={currency.value} label={currency.label}
                                                                >{currency.label}</Select.Item
                                                            >
                                                            {/each}
                                                        </Select.Group>
                                                        </Select.Content>
                                                        <Select.Input name="favoriteFruit" />
                                                    </Select.Root>
                                                </div>
                                                <div class="grid grid-cols-4 items-center gap-4">
                                                    <Label for="price">Price</Label>
                                                    <Input class="col-span-3" type="number" id="price" placeholder={product.productPrice.amount} />
                                                </div>
                                                <div class="grid grid-cols-4 items-center gap-4">
                                                    <Label for="sDesc">Short Description</Label>
                                                    <Input class="col-span-3" type="text" id="sDesc" name="sDesc" on:input={handlelSDesc} {...$constraints.sDesc} value={product.productShortDesc} />
                                                </div>
                                                <div class="grid grid-cols-4 items-center gap-4">
                                                    <Label for="lDesk">Full Description</Label>
                                                    <Textarea class="col-span-3" id="lDesc" name="lDesc"value={product.productLongDesc} on:input={handlelDesc} {...$constraints.lDesc}  />
                                                </div>
                                            </div>
                                            <Sheet.Footer>
                                                <Button type="submit">Save changes</Button>
                                            </Sheet.Footer>
                                            </Sheet.Content>
                                        </Sheet.Root>
                                    </form>
                                </Table.Cell>
                            </Table.Row>
                        {/if}
                    {/each}
                </Table.Body>
            </Table.Root>
        {/if}
    {/if}
</div>
<div class="col-span-1"></div>
{/if}