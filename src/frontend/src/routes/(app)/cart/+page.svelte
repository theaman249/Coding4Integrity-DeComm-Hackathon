<script lang="ts">
  import { cart, cartPage, fullName } from "$lib/data/stores/stores";
  import { Button } from "$lib/components/ui/button/index.js";
  import { toast } from "svelte-sonner";
  import Reload from "svelte-radix/Reload.svelte";
  import { goto } from "$app/navigation";
  import { actorBackend } from "$lib/motokoImports/backend";
  import { onMount } from "svelte";
  import * as AlertDialog from "$lib/components/ui/alert-dialog";
  import { Label } from "$lib/components/ui/label/index.js";
    import { Input } from "$lib/components/ui/input";

  let checkout = false;
  let buttonClicked = false;
  let posts = false;
  let converted: any[] = [];
  let formSubmitted = false;
  let formCleared = false;
  let totalCost = 0;

  $: {
    if (converted.length > 0) {
      totalCost = total();
    }
  }

  async function removeProduct(product) {
    try {
      formSubmitted = true;
      const result = await actorBackend.removeFromUserCart(
        $fullName,
        product.productID,
      );
      if (result) {
        toast("Removed " + product.name + " from cart");
        $cart.value = $cart.value - 1;
        converted = converted.filter((p) => p.productID !== product.productID);
      } else {
        toast.error("Failed to remove product from cart");
      }
    } catch (error) {
      toast.error("There was an error removing the product. Please try again", {
        description: getFormattedDateTime(),
      });
    } finally {
      formSubmitted = false;
    }
  }

  async function removeAllProducts() {
    try {
      formCleared = true;
      const result = await actorBackend.clearUserCart($fullName);
      if (result) {
        toast("Removed all products from cart");
        $cart.value = 0;
        converted = [];
      } else {
        toast.error("Failed to clear the cart");
      }
    } catch (error) {
      toast.error(
        "There was an error removing all the products. Please try again",
        { description: getFormattedDateTime() },
      );
    } finally {
      formCleared = false;
    }
  }

  function total() {
    let totalPrice = 0;

    if (converted.length === 0) {
      return totalPrice;
    }
    converted.forEach((product) => {
      if (!product.productPrice || !product.productPrice.currency) {
        return;
      }

      Object.keys(product.productPrice.currency).forEach((currency) => {
        if (product.productPrice.currency.hasOwnProperty(currency)) {
          totalPrice += product.productPrice.amount;
        } else {
          toast.error("Currency not found in product. Please try again", {
            description: getFormattedDateTime(),
          });
        }
      });
    });

    return totalPrice;
  }

  async function purchase() {
    try {
      for (const product of converted) {
        try {
          buttonClicked = true;
          const result = await actorBackend.purchase(
            $fullName,
            product.productID,
          );
          buttonClicked = false;
          if ("err" in result) {
            throw new Error(result.err);
          }
        } catch (error) {
          console.error("Error in purchase:", error);
          throw error;
        }
      }
      await removeAllProducts();
      checkout = false;
      $cartPage.value = false;
      toast("Items Purchased", { description: getFormattedDateTime() });
    } catch (error) {
      console.error("Error in purchase function:", error);
      buttonClicked = false;
      toast.error(
        "There was an error purchasing all the products. Please try again: " +
          error.message,
      );
    }
  }

  async function homePage() {
    await goto("/");
  }

  onMount(async () => {
    const resProduct = await actorBackend.getUserCartProductTypes($fullName);
    converted = await convertBigIntToNumber(resProduct);
    posts = true;
  });

  async function convertBigIntToNumber(products: any[]) {
    return products.map((product) => ({
      ...product,
      productPrice: {
        ...product.productPrice,
        amount: Number(product.productPrice.amount),
      },
      productID: Number(product.productID),
    }));
  }

  function getFormattedDateTime() {
    const now = new Date();
    const dayOfWeek = now.toLocaleDateString("en-US", { weekday: "long" });
    const monthDay = now.toLocaleDateString("en-US", {
      month: "long",
      day: "numeric",
    });
    const year = now.getFullYear();
    const time = now.toLocaleTimeString([], {
      hour: "numeric",
      minute: "2-digit",
      hour12: true,
    });

    return `${dayOfWeek}, ${monthDay} ${year} at ${time}`;
  }
</script>

{#if !checkout}
  <div class="flex flex-col min-h-screen w-full mt-32 lg:mt-40 p-2 bg-background">
    <div class="col-span-12 grid grid-cols-12 px-2 lg:px-10 flex-none">
      <div class="col-span-12 mb-5">
        <a href="/" class="flex" on:click|preventDefault={() => homePage()}>
          <svg
            class="arrow-icon"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
          >
            <path
              d="M20 11H7.414l4.293-4.293a1 1 0 0 0-1.414-1.414l-6 6a1 1 0 0 0 0 1.414l6 6a1 1 0 0 0 1.414-1.414L7.414 13H20a1 1 0 0 0 0-2z"
            />
          </svg>
          Go Back
        </a>
      </div>
      <div
        class="col-span-12 mb-10 flex flex-col lg:flex-row lg:items-center justify-between"
      >
        <h1 class="text-3xl font-semibold mb-5 lg:mb-0">Shopping Cart</h1>
        <div
          class="col-span-12 lg:col-span-auto flex flex-col lg:flex-row lg:gap-x-2"
        >
          {#if !formCleared}
            <Button
              variant="destructive"
              class="mb-2 lg:mb-0"
              on:click={() => removeAllProducts()}>Clear Cart</Button
            >
          {:else}
            <Button class="mb-2 lg:mb-0" disabled>
              <Reload class="flex justify-center h-4/5 animate-spin" />
              Clearing Cart
            </Button>
          {/if}
          <Button on:click={() => (checkout = true)}>Proceed to Checkout</Button>
        </div>
      </div>
      <div
        class="col-span-12 grid grid-cols-12 {!posts
          ? 'justify-center items-center w-full'
          : ''}"
      >
        {#if !posts}
          <div
            class="col-span-12 flex h-full w-full justify-center items-center text-3xl lg:text-7xl font-medium mt-40 2xl:mt-52 animate-pulse-custom"
          >
            Loading Cart Items....
          </div>
        {:else if posts && converted.length >= 1}
          {#each converted as product}
            <div
              class="col-span-4 lg:col-span-2 lg:ml-5 mb-12 border-y-[3.5px] border-l-[3.5px] border-zinc-400 rounded-tl-lg rounded-bl-lg"
            >
              <img
                class="h-52 w-52 object-cover p-2"
                src={product.productPicture}
                alt={product.name}
              />
            </div>
            <div
              class="col-span-8 lg:col-span-10 border-y-[3.5px] border-r-[3.5px] border-gray-400 h-[13.4rem] w-full rounded-tr-lg rounded-br-lg"
            >
              <div class="block relative">
                <p class="text-2xl font-semibold mt-12">{product.name}</p>
                <p class="opacity-75">{product.productCategory}</p>
                {#each Object.keys(product.productPrice.currency) as currency}
                  {#if product.productPrice.currency.hasOwnProperty(currency)}
                    {product.productPrice.amount} {currency.toUpperCase()}
                  {/if}
                {/each}
                {#if !product.isSold}
                  <p class="text-primary">In stock</p>
                {:else}
                  <p class="text-destructive">Out of Stock</p>
                {/if}
                {#if !formSubmitted}
                  <Button
                    variant="destructive"
                    class="mt-2 absolute right-2"
                    on:click={() => removeProduct(product)}
                    >Remove Product</Button
                  >
                {:else}
                  <Button class="mt-2 absolute right-2" disabled>
                    <Reload class="flex justify-center h-4/5 animate-spin" />
                    Removing from Cart
                  </Button>
                {/if}
              </div>
            </div>
          {/each}
        {:else if posts && converted.length <= 0}
          <div
            class="col-span-12 flex h-full w-full justify-center items-center text-3xl lg:text-7xl font-medium mt-40 2xl:mt-52"
          >
            No Products Found In Cart....
          </div>
        {/if}
      </div>
    </div>
  </div>
{:else if checkout}
  <div class="grid grid-cols-12 w-full mt-32 lg:mt-40 p-2">
    <div class="col-span-12 grid grid-cols-12 px-2 lg:px-10">
      <div class="col-span-12 mb-5">
        <a
          href="/"
          class="flex"
          on:click|preventDefault={() => (checkout = false)}
        >
          <svg
            class="arrow-icon"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
          >
            <path
              d="M20 11H7.414l4.293-4.293a1 1 0 0 0-1.414-1.414l-6 6a1 1 0 0 0 0 1.414l6 6a1 1 0 0 0 1.414-1.414L7.414 13H20a1 1 0 0 0 0-2z"
            />
          </svg>
          Go Back
        </a>
      </div>
      <div class="col-span-12 mb-10">
        <h1 class="text-3xl font-semibold mb-5 lg:mb-0">Checkout</h1>
      </div>
      <div
        class="grid grid-cols-12 col-span-12 justify-center items-center border-[3px] border-gray-600 p-4"
      >
        {#each converted as product}
          <div class="col-span-12 my-2">
            {product.name}:
            {#each Object.keys(product.productPrice.currency) as currency}
              {#if product.productPrice.currency.hasOwnProperty(currency)}
                {product.productPrice.amount} {currency.toUpperCase()}
              {/if}
            {/each}
          </div>
        {/each}
        <div class="col-span-12 my-2">
          Total Price of all products are <span class="font-bold"
            >{totalCost}</span
          > KT
        </div>
        <div
          class="col-span-12 my-2 flex items-end justify-end place-items-end"
        >
          {#if !buttonClicked}
          <AlertDialog.Root>
            <Button><AlertDialog.Trigger>Purchase</AlertDialog.Trigger></Button>
            <AlertDialog.Content>
              <AlertDialog.Header>
                <div class="grid gap-2">
                    <Label for="pword">To Authorize The Transfer Please Confirm Your Password</Label>
                    <Input type="password" id="pword" placeholder="password" />
                </div>
              </AlertDialog.Header>
              <AlertDialog.Footer>
                <AlertDialog.Cancel on:click={() =>
                    toast.error("Checkout Cancelled", {
                     description: "You have cancelled the checkout",
                     action: {
                      label: "close",
                      onClick: () => console.info("cancelled")
                     }
                    })}>Cancel</AlertDialog.Cancel>
                <AlertDialog.Action on:click={() => purchase()}>Continue</AlertDialog.Action>
              </AlertDialog.Footer>
            </AlertDialog.Content>
          </AlertDialog.Root>
          {:else}
            <Button disabled>
              <Reload class="mr-2 h-4 w-4 animate-spin" />
              {#if converted.length > 1}
                Purchasing Products
              {:else}
                Purchasing Product
              {/if}
            </Button>
          {/if}
        </div>
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
