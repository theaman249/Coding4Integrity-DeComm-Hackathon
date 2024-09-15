<script lang="ts">
    import * as Card from "$lib/components/ui/card/index.js";
    import Wallet from "lucide-svelte/icons/wallet";
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
        <p class="text-muted-foreground text-xs">-20.1% from last month</p>
    </Card.Content>
  </Card.Root>