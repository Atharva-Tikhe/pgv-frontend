<script lang="ts">

    let { data } = $props();

    let regid = $state(0);
    let selectedSample = $derived(regid);

    const loadSample = function (sid: number) {
        regid = sid;
    }
</script>


<div class="grid grid-cols-[0.3fr_1fr] gap-4 m-5">

    <div class="col-start-1 col-span-1">
        <div class="overflow-y-auto max-h-60 border-gray-200 border-2 mb-2">
            {#each data.samples as sample, idx (idx)}
                <!-- svelte-ignore a11y_click_events_have_key_events -->
                <div tabindex="0" onclick={() => loadSample(sample.RegId)} role="button" class="border-gray-400 border-2 m-2 flex w-auto justify-between">{sample.RegId}<span class="text-sm text-gray-300 font-bold w-auto px-2 items-center"> batch {sample.Batch} </span></div>
            {/each}
        </div>

        <div class="flex flex-col gap-1">
            <span>Interpretation {selectedSample != 0 ? ': ' + selectedSample : ''}</span>
            <textarea name="interpretation" id="" placeholder="Write Sample Interpretation {selectedSample != 0 ? ': ' + selectedSample : ''}" class="w-auto"></textarea>
        </div>

    </div>
    <div class="col-start-2 ">Main: {selectedSample}</div>
</div>