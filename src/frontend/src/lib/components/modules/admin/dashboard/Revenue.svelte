<script lang="ts">
    import * as Card from "$lib/components/ui/card/index.js";
    import HandCoins from "lucide-svelte/icons/hand-coins";

    import {Button} from "$lib/components/ui/button";
</script>

<Card.Root>
    <Card.Header
        class="flex flex-row items-center justify-between space-y-0 pb-2"
    >
        <Card.Title class="text-l font-medium">Revenue</Card.Title>
        <HandCoins class="text-muted-foreground h-8 w-8" />
    </Card.Header>
    <Card.Content>
        <div class="text-2xl font-bold mt-2">KT 11,345.34</div>
        <p class="text-muted-foreground text-xs">over the last 30 days</p>
    </Card.Content>
  </Card.Root>