<script>
    import { BusinessTransactions } from "$lib/components/modules/admin/dashboard/index";
    import { Sales } from "$lib/components/modules/admin/dashboard/index";
    import { Revenue } from "$lib/components/modules/admin/dashboard/index";
    import { SalesCard } from "$lib/components/modules/admin/dashboard/index";
    import * as Card from "$lib/components/ui/card/index";
    import BusinessTransations from "./Business-Transations.svelte";
</script>

<div class="grid grid-cols-2 gap-4">
    <div> <Card.Root class="col-span-3">
        <Card.Header>
          <Card.Title>Business Transactions</Card.Title>
        </Card.Header>
        <Card.Content>
          <BusinessTransations/>
        </Card.Content>
    </Card.Root> 
    </div>

    <div class="grid grid-rows-2 gap-3"> 
        <div><Sales/> </div>
        <div class="grid grid-cols-2 gap-2 h-2/3">
            <Revenue/>
            <SalesCard/>
        </div>
    </div>
</div>