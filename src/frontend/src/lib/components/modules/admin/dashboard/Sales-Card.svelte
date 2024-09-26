<script lang="ts">
    import * as Card from "$lib/components/ui/card/index.js";
    import SmartphoneNfc from "lucide-svelte/icons/smartphone-nfc";
</script>

<Card.Root>
    <Card.Header
        class="flex flex-row items-center justify-between space-y-0 pb-2"
    >
        <Card.Title class="text-sm font-medium">Sales (NFTs)</Card.Title>
        <SmartphoneNfc class="text-muted-foreground h-4 w-4" />
    </Card.Header>
    <Card.Content>
        <div class="text-2xl font-bold">+ 12.00 </div>
    </Card.Content>
  </Card.Root>