<script lang="ts">
	import { onMount } from "svelte";


    // let frontendVer = '0.0.1';

    let backendVer = $state('');

    onMount(() => {
        fetch('http://daedalus.ncl.ac.uk:8000/version').then((res) => res.json()).then((data) => backendVer = data.version)
    })
    

</script>

<div class="flex flex-col text-gray-500 text-sm ">
    <div class="flex items-center gap-2 ">
        {#if backendVer}
            <div class="w-2 h-2 rounded-2xl bg-green-700"></div>
        {:else}
            <div class="w-2 h-2 rounded-4xl bg-red-700"></div>
        {/if}
        <div class="{backendVer ? 'text-green-700' : ''} text-xs capitalize"> SERVER {backendVer} </div>
    </div>
    
    <!-- <div class="text-xs">UI ({frontendVer})</div> -->
</div>
