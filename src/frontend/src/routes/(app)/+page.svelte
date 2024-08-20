<script lang="ts">
	import { loggedIn, accountType, cartPage } from "$lib/data/stores/stores";
    import Cards from "./Cards/Cards.svelte";
	import Cart from "./cart/Cart.svelte"
	import { onMount } from 'svelte';

	let loaded = false;

	onMount (async ()=>{
		if($accountType.value !== "undefined"){
			$accountType.value = "Personal"
			loaded = true;
		}
	})
</script>

<main>
	{#if $loggedIn.value !== false}
		{#if loaded == true && $cartPage.value == false}
            <Cards />
		{:else if loaded == true && $cartPage.value == true}
			<Cart />
		{/if}
	{/if}
</main>
