<script lang="ts">
    import { cartProducts, cart, removeFromCart, cartPage, clearCart, fullName } from "$lib/data/stores/stores";
    import { Button } from "$lib/components/ui/button/index.js";
    import { toast } from "svelte-sonner";
    import { Label } from "$lib/components/ui/label/";
    import * as Select from "$lib/components/ui/select";
    import { httpOutcalls } from "$lib/motokoImports/backend"
    import { onDestroy } from 'svelte';
    import { writable } from 'svelte/store';
    import Reload from "svelte-radix/Reload.svelte";


    let checkout = false;
    $: selectedCurrency = "";
    let exchangeRate = [];
    let totalCost = 0;
    let timeLeft = writable(600);
    let buttonClicked = false;

    $: interval = setInterval(() => {
        timeLeft.update(value => {
            if (value > 0) {
                return value - 1;
            } else {
                return 600;
            }
        });
    }, 1000);


    onDestroy(() => clearInterval(interval));

    const Currency : any ={
      btc : {"btc": null},
      eth : {"eth": null},
      icp : {"icp": null},
      usd : {"usd": null},
      eur : {"eur": null},
      gbp : {"gbp": null},
    }

    const currencies = [
    { value: "USD", label: "USD" },
    { value: "EUR", label: "Euro" },
    { value: "GBP", label: "BGP" },
    { value: "BTC", label: "BTC" },
    { value: "ETH", label: "ETH" },
    { value: "ICP", label: "ICP" },
  ];

    const carts = $cartProducts;

    function removeProduct(product) {
        $cart.value = $cart.value - 1;
        removeFromCart(product.productID)
        toast("Removed " + product.name + " from cart");
    }

    function removeAllProducts(){
        $cart.value = 0;
        clearCart()
        toast("Removed All produts from cart");
    }

    async function getRates(desiredCurrency) {
        try {
            const res = await httpOutcalls.getConfirmationDetails(desiredCurrency);
            const filteredRates = res.filter(
                (item) =>
                item.currency === "USD" ||
                item.currency === "EUR" ||
                item.currency === "GBP" ||
                item.currency === "BTC" ||
                item.currency === "ETH" ||
                item.currency === "ICP"
            );

            exchangeRate = filteredRates.slice(0, 6);
            console.log(exchangeRate);
            return exchangeRate;
        } catch (error) {
            throw error;
        }
    }

    function convertPrice(price, currency) {
        if(currency.eur === null){
            const rate = findRateByCurrency("EUR", exchangeRate)
            const calculatedPrice = (price / rate);
            totalCost = totalCost + calculatedPrice;
            return calculatedPrice;
        }else if(currency.gbp === null){
            const rate = findRateByCurrency("GBP", exchangeRate)
            const calculatedPrice = (price / rate);
            totalCost = totalCost + calculatedPrice;
            return calculatedPrice;
        }else if(currency.btc === null){
            const rate = findRateByCurrency("BTC", exchangeRate)
            const calculatedPrice = (price / rate);
            totalCost = totalCost + calculatedPrice;
            return calculatedPrice;
        }else if(currency.usd === null){
            const rate = findRateByCurrency("USD", exchangeRate)
            const calculatedPrice = (price / rate);
            totalCost = totalCost + calculatedPrice;
            return calculatedPrice;
        }else if(currency.icp === null){
            const rate = findRateByCurrency("ICP", exchangeRate)
            const calculatedPrice = (price / rate);
            totalCost = totalCost + calculatedPrice;
            return calculatedPrice;
        }else if(currency.eth === null){
            const rate = findRateByCurrency("ETH", exchangeRate)
            const calculatedPrice = (price / rate);
            totalCost = totalCost + calculatedPrice;
            return calculatedPrice;
        }
    }

    function findRateByCurrency(currency: string, data: { rate: string, currency: string }[]): string | null {
        for (const item of data) {
            if (item.currency === currency) {
            return item.rate;
            }
        }
        return null;
    }

    async function purchase(){
        for (const product of carts){
            try {
                // await actorBackend.purchase($fullName, product.productPrice, product);
            } catch (error) {
                throw error;
            }
        }
        removeAllProducts();
        checkout = false;
        $cartPage.value == false;
        toast("Items Purchased");
    };
</script>

{#if !checkout}
    <div class="grid grid-cols-12 w-full mt-5 lg:mt-28 p-2">
        <div class="col-span-12 grid grid-cols-12 px-2 lg:px-10">
            <div class="col-span-12 mb-5">
                <a href="#" class="flex" on:click|preventDefault={() => $cartPage.value = false}>
                    <svg class="arrow-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                        <path d="M20 11H7.414l4.293-4.293a1 1 0 0 0-1.414-1.414l-6 6a1 1 0 0 0 0 1.414l6 6a1 1 0 0 0 1.414-1.414L7.414 13H20a1 1 0 0 0 0-2z"/>
                    </svg>
                    Go Back
                </a>
            </div>
            <div class="col-span-12 mb-10 flex flex-col lg:flex-row lg:items-center justify-between">
                <h1 class="text-3xl font-semibold mb-5 lg:mb-0">Shopping Cart</h1>
                <div class="col-span-12 lg:col-span-auto flex flex-col lg:flex-row lg:gap-x-2">
                    <Button variant="destructive" class="mb-2 lg:mb-0" on:click={() => removeAllProducts()}>Clear Cart</Button>
                    <Button on:click={()=> checkout = true}>Proceed to Checkout</Button>
                </div>
            </div>        
            <div class="col-span-12 grid grid-cols-12">
                {#each carts as product}
                    <div class="col-span-4 lg:col-span-2 lg:ml-5 mb-12 border-y-2 border-l-2 border-gray-200">
                        <img class="h-52 w-52 object-cover p-2" src={product.productPicture} alt={product.name}/>
                    </div>
                    <div class="col-span-8 lg:col-span-10 border-y-2 border-r-2 border-gray-200 h-[13.25rem] w-full">
                        <div class="block relative">
                            <p class="text-2xl font-semibold mt-12">{product.name}</p>
                            <p class="opacity-75">{product.productCategory}</p>
                            {#each Object.keys(product.productPrice.currency) as currency}
                                {#if (product.productPrice.currency).hasOwnProperty(currency)}
                                    {product.productPrice.amount} {currency.toUpperCase()}
                                {/if}
                            {/each}
                            {#if !product.isSold}
                                <p class="text-green-500">In stock</p>
                            {:else}
                                <p class="text-red-500">Out of Stock</p>
                            {/if}
                            <Button variant="destructive" class="mt-2 absolute right-2" on:click={() => removeProduct(product)}>Remove Product</Button>
                        </div>
                    </div>
                {/each}
            </div>
        </div>
    </div>
{:else if checkout}
    <div class="grid grid-cols-12 w-full mt-5 lg:mt-28 p-2">
        <div class="col-span-12 grid grid-cols-12 px-2 lg:px-10">
            <div class="col-span-12 mb-5">
                <a href="#" class="flex" on:click|preventDefault={() => checkout = false}>
                    <svg class="arrow-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                        <path d="M20 11H7.414l4.293-4.293a1 1 0 0 0-1.414-1.414l-6 6a1 1 0 0 0 0 1.414l6 6a1 1 0 0 0 1.414-1.414L7.414 13H20a1 1 0 0 0 0-2z"/>
                    </svg>
                    Go Back
                </a>
            </div>
            <div class="col-span-12 mb-10">
                <h1 class="text-3xl font-semibold mb-5 lg:mb-0">Checkout</h1>
            </div> 
            <div class="grid grid-cols-12 col-span-12 justify-center items-center border-[3px] border-gray-200 p-4">
                <div class="col-span-12 mb-5">
                    <div class="grid w-full max-w-sm items-center gap-1.5 mt-5">
                        <Label for="price">Currency</Label>
                        <Select.Root
                          onSelectedChange={(v) =>{
                            v && (selectedCurrency = v.value)
                          }}
                        >
                            <Select.Trigger class="w-[180px]">
                              <Select.Value placeholder="Select a currency" />
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
                        <p class="text-sm text-muted-foreground">Select the desired currency you'd like to pay with.</p>
                    </div>
                </div>
                {#if selectedCurrency !== ""}
                    {#await getRates(selectedCurrency)}
                        <div class="col-span-12 mt-5">Calculating Price...</div>
                    {:then}
                        <div class="col-span-12 text-yellow-500 my-2">NOTE the prices change every {$timeLeft} seconds</div>
                        {#each carts as product}
                            <div class="col-span-12 my-2">{product.name}: {convertPrice(product.productPrice.amount, product.productPrice.currency) } {selectedCurrency.toUpperCase()}</div>
                        {/each}
                        <div class="col-span-12 my-2">Total Price of all products are {totalCost} {selectedCurrency}</div>
                        <div class="col-span-12 my-2 flex items-end justify-end place-items-end">
                            {#if !buttonClicked}
                                <Button on:click={() => purchase()}>Purchase</Button>
                            {:else}
                                <Button disabled>
                                    <Reload class="mr-2 h-4 w-4 animate-spin" />
                                    Purchasing Product
                                </Button>
                            {/if}
                        </div>
                    {:catch}
                        <div class="text-red-500">Error fetching Exchange rates</div>
                    {/await}
                {/if}
            </div>
        </div>
    </div>
{/if}


<style>
    .arrow-icon {
        width: 20px;
        height: 20px;
        margin-right: 5px;
    }
</style>