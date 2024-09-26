<script>
    import { BusinessTransactions } from "$lib/components/modules/admin/dashboard/index";
    import { Sales } from "$lib/components/modules/admin/dashboard/index";
    import { Revenue } from "$lib/components/modules/admin/dashboard/index";
    import { SalesCard } from "$lib/components/modules/admin/dashboard/index";
</script>

<div class="flex">
    <div class="border-1 border-rounded w-2/4"><BusinessTransactions/></div>
    <div class="w-2/4 grid grid-rows-2 grid-cols-2 gap-2"> 
        <div class="row-span-2"><Sales/></div>
        <div>
            <Revenue/>
            <SalesCard/>
        </div>
    </div>
</div>