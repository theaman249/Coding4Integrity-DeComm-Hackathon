<script lang="ts">
    import * as Card from "$lib/components/ui/card/index.js";
    import Wallet from "lucide-svelte/icons/wallet";
    import * as AlertDialog from "$lib/components/ui/alert-dialog";
    import {Button} from "$lib/components/ui/button";
</script>

<Card.Root>
    <Card.Header
        class="flex flex-row items-center justify-between space-y-0 pb-2"
    >
        <Card.Title class="text-sm font-medium">Wallet Balance</Card.Title>
        <Wallet class="text-muted-foreground h-4 w-4" />
    </Card.Header>
    <Card.Content>
        <div class="text-2xl font-bold">KT 45,231.89</div>
        <p class="text-muted-foreground text-xs">**** *** 4321</p>
        <div class="space-x-1 space-y-1 justify-center self-center content-center align-center">
            
            <div class="space-x-1 space-y-1">
                
                <AlertDialog.Root>
                  <Button class="mt-2 w-24 ml-36"> <AlertDialog.Trigger>Transfer</AlertDialog.Trigger></Button>
                    <AlertDialog.Content>
                    <AlertDialog.Header>
                    <AlertDialog.Title>This will take you to the page for transferring Knowledge Tokens</AlertDialog.Title>
                    <AlertDialog.Description>
                    This feature is not yet implemented. But it will serve the purpose of a user transfering Knowledge Tokens to another user.
                    </AlertDialog.Description>
                    </AlertDialog.Header>
                    <AlertDialog.Footer>
                    <AlertDialog.Cancel>Cancel</AlertDialog.Cancel>
                    <AlertDialog.Action>Continue</AlertDialog.Action>
                    </AlertDialog.Footer>
                    </AlertDialog.Content>
                </AlertDialog.Root>
                    </div>
          </div>
    </Card.Content>
  </Card.Root>