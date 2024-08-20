<script lang="ts">
    import "../app.css";
    import { onNavigate } from '$app/navigation';
    import { Toaster } from "$lib/components/ui/sonner";
    import { loggedIn, registerStore, accountType } from "$lib/data/stores/stores";
    import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import Login from "./(app)/login/+page.svelte"

    let loaded = false;

    onNavigate((navigation) => {
    if (!(document as any).startViewTransition) return;
    return new Promise((resolve) => {
        (document as any).startViewTransition(async () => {
        resolve();
        await navigation.complete;
        });
    });
    });

    onMount (async ()=>{
        if($accountType.value !== "undefined"){
            $accountType.value = "Personal"
            loaded = true;
        }

        if(loaded == true){
            if($loggedIn.value === true){
                if($accountType.value === "Personal"){
                    redirectTo('/')
                }else if($accountType.value === "Bussiness"){
                    redirectTo('/admin')
                }
            }else if ($loggedIn.value === false){
                if($registerStore){
                    redirectTo('/login')
                }
            }
            
        }
    })


    function redirectTo(path: string) {
        goto(path);
    }
</script>

<Toaster />

<slot />