<script lang="ts">
    import * as Card from "$lib/components/ui/card/index.js";
    import SmartphoneNfc from "lucide-svelte/icons/smartphone-nfc";
</script>

<Card.Root>
    <Card.Header
        class="flex flex-row items-center justify-between space-y-0 pb-2"
    >
        <Card.Title class="text-l font-medium">Sales (NFTs)</Card.Title>
        <SmartphoneNfc class="text-muted-foreground h-8 w-8" />
    </Card.Header>
    <Card.Content>
        <div class="text-2xl font-bold mt-2">+ 12.00 </div>
        <p class="text-muted-foreground text-xs"> over the last 30 days</p>
    </Card.Content> 
  </Card.Root>