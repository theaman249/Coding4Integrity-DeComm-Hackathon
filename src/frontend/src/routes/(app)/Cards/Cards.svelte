<script lang="ts">
    import { Button } from "$lib/components/ui/button";
    import * as Select from "$lib/components/ui/select";
    import { fullName, loggedIn, loginStore, accountType, cart, cartPage } from '$lib/data/stores/stores';
    import Input from '$lib/components/ui/input/input.svelte';
    import Card from "./Card/Card.svelte";
    import Sidebar from "../Sidebar/Sidebar.svelte";
    import { createPostsIndex, searchPostsIndex, type Result } from "$lib/components/helpers/search";
    import { onMount } from "svelte";
    import * as Sheet from "$lib/components/ui/sheet";
    import { Gear } from "radix-icons-svelte";
    import { goto } from '$app/navigation';
    import { actorBackend } from "$lib/motokoImports/backend"

    let searchTerm = '';
    let search: 'loading' | 'ready' = 'loading'
	let results: Result[] = []
    let posts : [];

	onMount(async () => {
        const resProduct = await actorBackend.getAllProductTypes();
        const converted = await convertBigIntToNumber(resProduct);
        posts = converted;
		createPostsIndex(converted)
		search = 'ready'
	})

    async function convertBigIntToNumber(products: any[]) {
        return products.map(product => ({
            ...product,
            productPrice: {
                ...product.productPrice,
                amount: Number(product.productPrice.amount)
            },
            productID: Number(product.productID)
        }));
    }


	$: if (search === 'ready') {
		results = searchPostsIndex(searchTerm)
        console.log(results)
	}


    function logOut(){
        loggedIn.update(currentValue =>({value : false}));
        $accountType.value = "Personal";
        $loginStore = true;
        $fullName = "";
        goto("/login")
    }

    function pAccount(){
        $accountType.value = "Personal";
        goto('/')
    }

    function bAccount(){
        $accountType.value = "Bussiness";
        goto('/admin')
    }
</script>

<div class="grid grid-cols-12">
    <header class="bg-white border-b-4 border-zinc-300 fixed top-0 w-full z-20 lg:hidden col-span-12">
        <nav class="grid grid-cols-12 gap-4 items-center py-2 text-stone-500 hover:text-stone-500 focus:text-stone-700 lg:py-1 data-te-navbar-ref">
            <div class="col-span-6 flex justify-start">
                <div class="ml-2">
                    <Select.Root>
                        <Select.Trigger class="w-[180px] font-medium">
                            <Select.Value placeholder="Personal Account" />
                        </Select.Trigger>
                        <Select.Content>
                            <p class="text-sm text-center my-3">{$fullName}</p>
                            <hr>
                            <Select.Item value="Personal Account" on:click={pAccount}>Personal Account</Select.Item>
                            <Select.Item value="Business Account" on:click={bAccount}>Business Account</Select.Item>
                            <hr>
                            <Button class="ghost w-full h-full" on:click={logOut}>Log Out</Button>
                        </Select.Content>
                    </Select.Root>
                </div>
            </div>
            <div class="col-span-6 flex justify-end mr-2">
                <a href="#" class="relative cursor-pointer" on:click|preventDefault={() => $cartPage.value = true}>
                    <svg class="w-12 h-12" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><g id="SVGRepo_bgCarrier" stroke-width="0"></g><g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g><g id="SVGRepo_iconCarrier"> <path fill-rule="evenodd" clip-rule="evenodd" d="M14.3999 3.2C14.8417 2.86863 15.4685 2.95817 15.7999 3.4L18.4999 7H18.5031C20.3417 7 21.7478 8.6389 21.4682 10.4562L20.3913 17.4562C20.1661 18.9197 18.9069 20 17.4261 20H6.57366C5.09295 20 3.8337 18.9197 3.60855 17.4562L2.53162 10.4562C2.25204 8.63889 3.65808 7 5.49674 7H5.4999L8.1999 3.4C8.53127 2.95817 9.15808 2.86863 9.5999 3.2C10.0417 3.53137 10.1313 4.15817 9.7999 4.6L7.9999 7H15.9999L14.1999 4.6C13.8685 4.15817 13.9581 3.53137 14.3999 3.2ZM5.98825 9C5.99551 9.00008 6.00277 9.00008 6.01002 9H17.9898H18.0116H18.5031C19.116 9 19.5846 9.5463 19.4914 10.1521L18.4145 17.1521C18.3395 17.6399 17.9197 18 17.4261 18H6.57366C6.08009 18 5.66034 17.6399 5.58529 17.1521L4.50837 10.1521C4.41517 9.5463 4.88385 9 5.49674 9H5.98825Z" fill="#000000"></path> </g></svg>
                    <div class="absolute top-[1.6rem] right-[1.35rem] flex items-center justify-center w-5 h-5 bg-black text-white text-xs font-semibold rounded-full">{$cart.value}</div>
                </a>
            </div>
        </nav>
    </header>
    <div class="col-span-12 grid grid-cols-12 justify-center gap-4 p-5 mt-20 mb-28 lg:mb-0 md:p-8 xl:p-5 2xl:p-40 min-h-screen w-full relative">
        {#if !posts}
            <div class="col-span-12 flex h-full w-full justify-center items-center text-3xl lg:text-7xl">
                Loading Items....
            </div>
        {:else if posts && (searchTerm === "" || searchTerm === "Search for item...")}
            {#each posts as post}
                <div class="col-span-12 md:col-span-6 lg:col-span-3 w-full h-1/6 border-zinc-300 shadow-lg">
                    <Card 
                        name={post.name} 
                        productLongDesc={post.productLongDesc}
                        productCategory={post.productCategory}
                        productShortDesc={post.productShortDesc}
                        productID={post.productID}
                        isSold={post.isSold}
                        isVisible={post.isVisible}
                        sellerID={post.sellerID}
                        productPrice={post.productPrice}
                        productPicture={post.productPicture} 
                    /> 
                </div>
            {/each}
        {:else if results}
            {#if results.length <= 0}
                <div class="col-span-12 flex h-full w-full justify-center items-center text-7xl">
                    No Results Found....
                </div>
            {:else if results.length > 0}
                {#each results as result}
                {console.log(result)}
                    <div class="col-span-12 md:col-span-6 lg:col-span-3 w-full h-1/6 border-zinc-300 shadow-lg">
                        <Card 
                            name={result.name} 
                            productLongDesc={result.productLongDesc}
                            productCategory={result.productCategory}
                            productShortDesc={result.productShortDesc}
                            productID={result.productID}
                            isSold={result.isSold}
                            isVisible={result.isVisible}
                            sellerID={result.sellerID}
                            productPrice={result.productPrice},
                            productPicture={result.productPicture} 
                        /> 
                    </div>
                {/each}
            {/if}
        {/if}
    </div>
    <footer class="bg-white border-t-4 border-zinc-300 fixed bottom-0 w-full z-20 col-span-12">
        <nav class="grid grid-cols-12 gap-4 items-center py-2 text-stone-500 hover:text-stone-500 focus:text-stone-700 lg:py-1 data-te-navbar-ref">
            <div class="hidden lg:col-span-3 lg:flex lg:justify-start">
                <div class="ml-2 lg:ml-10">
                    <Select.Root>
                        <Select.Trigger class="w-[100px] lg:w-[180px] font-medium">
                            <Select.Value placeholder="Personal Account" />
                        </Select.Trigger>
                        <Select.Content>
                            <p class="text-sm text-center my-3">{$fullName}</p>
                            <hr>
                            <Select.Item value="Personal Account" on:click={pAccount}>Personal Account</Select.Item>
                            <Select.Item value="Business Account" on:click={bAccount}>Business Account</Select.Item>
                            <hr>
                            <Button class="ghost w-full h-full" on:click={logOut}>Log Out</Button>
                        </Select.Content>
                    </Select.Root>
                </div>
            </div>
    
            <div class="col-span-12 p-2 lg:p-0 lg:col-span-6 flex justify-center">
                {#if search === 'ready'}
                    <Input class="rounded-2xl border-2 text-center" bind:value={searchTerm} placeholder="Search for Item" autocomplete="off" spellcheck="false" type="search"/>
                {/if}
            </div>
    
            <div class="hidden lg:col-span-3 lg:flex justify-end lg:mr-10">
                <a href="#" class="relative cursor-pointer" on:click|preventDefault={() => $cartPage.value = true}>
                    <svg class="w-16 h-16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><g id="SVGRepo_bgCarrier" stroke-width="0"></g><g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g><g id="SVGRepo_iconCarrier"> <path fill-rule="evenodd" clip-rule="evenodd" d="M14.3999 3.2C14.8417 2.86863 15.4685 2.95817 15.7999 3.4L18.4999 7H18.5031C20.3417 7 21.7478 8.6389 21.4682 10.4562L20.3913 17.4562C20.1661 18.9197 18.9069 20 17.4261 20H6.57366C5.09295 20 3.8337 18.9197 3.60855 17.4562L2.53162 10.4562C2.25204 8.63889 3.65808 7 5.49674 7H5.4999L8.1999 3.4C8.53127 2.95817 9.15808 2.86863 9.5999 3.2C10.0417 3.53137 10.1313 4.15817 9.7999 4.6L7.9999 7H15.9999L14.1999 4.6C13.8685 4.15817 13.9581 3.53137 14.3999 3.2ZM5.98825 9C5.99551 9.00008 6.00277 9.00008 6.01002 9H17.9898H18.0116H18.5031C19.116 9 19.5846 9.5463 19.4914 10.1521L18.4145 17.1521C18.3395 17.6399 17.9197 18 17.4261 18H6.57366C6.08009 18 5.66034 17.6399 5.58529 17.1521L4.50837 10.1521C4.41517 9.5463 4.88385 9 5.49674 9H5.98825Z" fill="#000000"></path> </g></svg>
                    <div class="absolute top-[1.6rem] right-[1.35rem] flex items-center justify-center w-5 h-5 bg-black text-white text-xs font-semibold rounded-full">{$cart.value}</div>
                </a>
            </div>
        </nav>
    </footer>
</div>