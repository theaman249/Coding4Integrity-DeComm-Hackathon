<script lang="ts">
    import * as Card from "$lib/components/ui/card/index.js";
    import Wallet from "lucide-svelte/icons/wallet";
    import * as AlertDialog from "$lib/components/ui/alert-dialog";
    import {Button} from "$lib/components/ui/button";
    import * as RadioGroup from "$lib/components/ui/radio-group/index.js";
    import { Label } from "$lib/components/ui/label/index.js";
    import { Input } from "$lib/components/ui/input";
    import { toast } from "svelte-sonner";
    import { actorBackend } from "$lib/motokoImports/backend";
    import { onMount } from "svelte";
    import { walletID, walletBalance } from "$lib/data/stores/stores";
    import {
        Email,
        Password,
    } from "$lib/data/stores/stores.js";
    var receipiantID = "";
    var amountToSend = 0;
    var passConfirm = "";

    onMount(async () => {
        const walletDetails = await actorBackend.getDataForPersonalDashboard($Email);

        if(walletDetails)
        {
            $walletBalance = walletDetails.walletBallanceKT;
            console.log(walletDetails)
        }
    });

    async function transferTokens(){
        console.log('Transfering Token function');
        // you need => walletID, amount, Password
        // Convert amountToSend to bigint
        let amountToSendBigInt = BigInt(amountToSend);

        // console.log(receipiantID);
        // console.log(amountToSendBigInt);
        // console.log(passConfirm);

        let res = await actorBackend.transferTokens(receipiantID,amountToSendBigInt,passConfirm);

        if(res.msg = "tokens sent to wallet "+receipiantID)
        {

            const walletDetails = await actorBackend.getDataForPersonalDashboard($Email);

            if(walletDetails)
            {
                $walletBalance = walletDetails.walletBallanceKT;
            }

            toast.success("Payment Successful", {
                description: "Transfer Successful!",
                action: {
                label: "done",
                onClick: () => console.info("transferred")
                }
            });

        }
        else{
            toast.error(res.msg); 
        }
    };
</script>

<Card.Root>
    <Card.Header
        class="flex flex-row items-center justify-between space-y-0 pb-2"
    >
        <Card.Title class="text-sm font-medium">Wallet Balance</Card.Title>
        <Wallet class="text-muted-foreground h-8 w-8" />
    </Card.Header>
    <Card.Content>
        <div class="text-2xl font-bold">KT {$walletBalance}</div>
        <p class="text-muted-foreground text-xs">{$walletID}</p>
        <div class="space-x-1 space-y-1 justify-center self-center content-center align-center">
            
            <div class="space-x-1 space-y-1">
                
                <AlertDialog.Root>
                  <Button class="mt-2 w-24 ml-36"> <AlertDialog.Trigger>Transfer</AlertDialog.Trigger></Button>
                    <AlertDialog.Content>
                        <Card.Root>
                            <Card.Header>
                                <Card.Title>Knowledge Token Transfer</Card.Title>
                                <Card.Description>Transfer Knowledge Tokens to other users</Card.Description>
                            </Card.Header>
                            <Card.Content class="grid gap-6">
                                <RadioGroup.Root value="KT" class="grid grid-cols-1">
                                    <Label
                                        for="KT"
                                        class="border-muted bg-popover hover:bg-accent hover:text-accent-foreground [&:has([data-state=checked])]:border-primary flex flex-col items-center justify-between rounded-md border-2 p-4"
                                    >
                                        <RadioGroup.Item value="card" id="KT" class="sr-only" aria-label="KT" />
                                        <svg
                                            xmlns="http://www.w3.org/2000/svg"
                                            viewBox="0 0 24 24"
                                            fill="none"
                                            stroke="currentColor"
                                            stroke-linecap="round"
                                            stroke-linejoin="round"
                                            stroke-width="2"
                                            class="mb-3 h-6 w-6"
                                        >
                                            <rect width="20" height="14" x="2" y="5" rx="2" />
                                            <path d="M2 10h20" />
                                        </svg>
                                        KT Wallet
                                    </Label>
                                </RadioGroup.Root>
                                <div class="grid gap-2">
                                    <Label for="email">Receiver Email</Label>
                                    <Input type="email" id="email" placeholder="e.g receiver@example.com" />
                                </div>
                                <div class="grid gap-2">
                                    <Label for="WalletID">Receiver WalletID</Label>
                                    <Input bind:value={receipiantID} type="text" id="WalletID" placeholder="e.g XXXXX-XXXXX-XXXXX-XXXXX" />
                                </div>
                                <div class="grid gap-2">
                                    <Label for="amount">Amount</Label>
                                    <Input bind:value = {amountToSend} type="number" id="amount" placeholder="e.g 2461" />
                                </div>
                            </Card.Content>
                            <Card.Footer>
                                <Card.Description>To cancel click the 'esc' button.</Card.Description>
                            </Card.Footer>
                        </Card.Root>
                    <AlertDialog.Footer>
                        <AlertDialog.Root>
                            <Button class="w-full"> <AlertDialog.Trigger>Continue</AlertDialog.Trigger></Button>
                            <AlertDialog.Content>
                                <AlertDialog.Header>
                                    <div class="grid gap-2">
                                        <Label for="pword">To Authorize The Transfer Please Confirm Your Password</Label>
                                        <Input bind:value = {passConfirm} type="password" id="pword" placeholder="password" />
                                    </div>
                                </AlertDialog.Header>
                                <AlertDialog.Footer>
                                    <AlertDialog.Cancel on:click={() =>
                                        toast.error("Transfer Cancelled", {
                                         description: "You have cancelled the transfer",
                                         action: {
                                          label: "close",
                                          onClick: () => console.info("cancelled")
                                         }
                                        })}>Cancel</AlertDialog.Cancel>
                                    <AlertDialog.Action on:click = {() => transferTokens()}>Continue</AlertDialog.Action>
                                </AlertDialog.Footer>
                            </AlertDialog.Content>
                        </AlertDialog.Root>
                    </AlertDialog.Footer>
                    </AlertDialog.Content>
                </AlertDialog.Root>
                    </div>
          </div>
    </Card.Content>
  </Card.Root>