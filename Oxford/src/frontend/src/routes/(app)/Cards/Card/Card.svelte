<script lang="ts">
    import { Button } from "$lib/components/ui/button";
    import * as Carousel from "$lib/components/ui/carousel";
    import * as Drawer from "$lib/components/ui/drawer";
    import { toast } from "svelte-sonner";
    import { cart, addToCart } from "$lib/data/stores/stores";
    
    const Currency : any ={
      btc : {"btc": null},
      eth : {"eth": null},
      icp : {"icp": null},
      usd : {"usd": null},
      eur : {"eur": null},
      gbp : {"gbp": null},
    }

    export type productPrice = {
      currency : typeof Currency;
      amount: number;
    }

    export let productLongDesc : string
    export let productCategory : string
    export let name : string
    export let productShortDesc: string
    export let productID: number
    export let isSold: boolean
    export let isVisible: boolean
    export let sellerID : string
    export let productPrice : productPrice
    export let productPicture : string
    
    export let product = {
      name: name,
      productLongDesc: productLongDesc,
      productCategory: productCategory,
      productShortDesc: productShortDesc,
      productID: productID,
      isSold: isSold,
      isVisible: isVisible,
      sellerID: sellerID,
      productPrice: productPrice,
      productPicture: productPicture,
    };

    function add() {
        $cart.value = $cart.value + 1;
        addToCart(product)
        toast("Added " + product.name + " to cart");
    }
</script>
  
  <div class="max-w-md mx-auto bg-white shadow-md rounded-md overflow-hidden min-h-[650px] max-h-[650px] relative">
    <Carousel.Root>
      <Carousel.Content>
        <Carousel.Item><img class="w-full h-96 object-cover" src={product.productPicture} alt={product.name}/></Carousel.Item>
      </Carousel.Content>
      <Carousel.Previous />
      <Carousel.Next />
    </Carousel.Root>
    <div class="p-4">
      <div class="flex justify-between mb-2">
        <h2 class="text-xl font-semibold">{@html product.name}</h2>
        <h2 class="text-xl font-semibold">
          {#each Object.keys(product.productPrice.currency) as currency}
              {#if (product.productPrice.currency).hasOwnProperty(currency)}
                {product.productPrice.amount} {currency.toUpperCase()}
              {/if}
          {/each}
        </h2>
      </div>
      <p class="text-gray-600 mb-4">{@html product.productShortDesc}</p>
    </div>
    <div class="p-4 absolute bottom-0 w-full">
      <div class="flex justify-between gap-x-2">
        <Drawer.Root>
          <Drawer.Trigger class="border-2 border-zinc-200 p-1 w-3/5 h-full rounded-md hover:bg-zinc-300 hover:border-zinc-600">More details</Drawer.Trigger>
          <Drawer.Content>
            <div class="mx-auto w-full max-w-sm h-full">
              <Drawer.Header>
                <Drawer.Title>{@html product.name}</Drawer.Title>
              </Drawer.Header>
              <div class="p-4 pb-0">
                <div class="flex items-center justify-center space-x-2">
                  <div class="flex-1 text-center">
                    <div class="text-7xl font-bold tracking-tighter">
                    </div>
                    <div class="text-[0.7rem] text-start uppercase text-muted-foreground my-2">
                      {#each Object.keys(product.productPrice.currency) as currency}
                          {#if (product.productPrice.currency).hasOwnProperty(currency)}
                            Price: {product.productPrice.amount} {currency.toUpperCase()}
                          {/if}
                      {/each}
                    </div>
                    <div class="text-[0.7rem] text-start uppercase text-muted-foreground my-2">
                      ProductID: {@html product.productID}
                    </div>
                    <div class="text-[0.7rem] text-start uppercase text-muted-foreground my-2">
                      Category: {@html product.productCategory}
                    </div>
                    <div class="text-[0.7rem] text-start uppercase text-muted-foreground my-2">
                      Seller: {@html product.sellerID}
                    </div>
                    <div class="text-[0.7rem] text-start uppercase text-muted-foreground my-2">
                      Description: {@html product.productLongDesc}
                    </div>
                  </div>
              </div>
              <Drawer.Footer>
                <Button on:click={() => add()}>Add to cart</Button>
                <Drawer.Close asChild let:builder>
                  <Button builders={[builder]} variant="outline">Close</Button>
                </Drawer.Close>
              </Drawer.Footer>
            </div>
          </Drawer.Content>
        </Drawer.Root>
        <Button class="w-3/5 h-full" variant="default" on:click={() => add()}>Add to cart</Button>
      </div>
    </div>
  </div>
  