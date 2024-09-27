<script lang="ts">
    import * as Card from "$lib/components/ui/card/index.js";
    import ChartNoAxesColumnDecreasing from "lucide-svelte/icons/chart-no-axes-column-decreasing";
    import {Button} from "$lib/components/ui/button";
</script>

<Card.Root>
    <Card.Header
        class="flex flex-row items-center justify-between space-y-0 pb-2"
    >
        <Card.Title class="text-sm font-medium">Spending</Card.Title>
        <ChartNoAxesColumnDecreasing class="text-muted-foreground h-4 w-4" />
    </Card.Header>
    <Card.Content>
        <div class="text-2xl font-bold">KT 5,876.89</div>
    </Card.Content>
  </Card.Root>