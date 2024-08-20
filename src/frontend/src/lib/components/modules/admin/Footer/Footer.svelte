<script lang="ts">
    import { Button } from "$lib/components/ui/button";
    import * as Select from "$lib/components/ui/select";
    import { fullName, loggedIn, loginStore, accountType } from '$lib/data/stores/stores';
    import { goto } from '$app/navigation';


    function logOut(){
        loggedIn.update(currentValue =>({value : false}));
        $accountType.value = "Bussiness";
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

<footer>
  <nav class="bg-white border-t-2 border-zinc-300
  grid grid-cols-12 lg:grid-cols-12 gap-4 w-full flex-nowrap items-center justify-between py-2 text-stone-500
   hover:text-stone-500 focus:text-stone-700 lg:flex-wrap lg:justify-start lg:py-3
  data-te-navbar-ref fixed bottom-0 z-10">
      <div class="col-span-10 lg:col-span-3">
        <div class="flex">  
          <div class="ml-2 lg:ml-10">
            <Select.Root>
                <Select.Trigger class="w-[180px] font-medium">
                  <Select.Value placeholder="Business Account" />
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
      </div>
  </nav>
</footer>