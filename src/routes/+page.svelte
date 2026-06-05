<script lang="ts">
    import JBrowseViewer from '$lib/components/JBrowseViewer.svelte';
    import type { Sample } from '$lib/types/api';

    let { data } = $props();

    let selectedSample: Sample | null = $state(null);

    const loadSample = function (sample: Sample) {
        selectedSample = sample;
    }
</script>


<div class="grid grid-cols-[0.3fr_1fr] gap-4 m-5 h-[calc(100vh-40px)]">

    <div class="col-start-1 col-span-1 flex flex-col gap-4">
        <div class="overflow-y-auto border-gray-200 border-2 flex-grow">
            {#each data.samples as sample, idx (idx)}
                <!-- svelte-ignore a11y_click_events_have_key_events -->
                <div 
                    tabindex="0" 
                    onclick={() => loadSample(sample)} 
                    role="button" 
                    class="border-gray-400 border-2 m-2 p-2 flex justify-between cursor-pointer hover:bg-gray-50 {selectedSample?.RegId === sample.RegId ? 'bg-blue-50 border-blue-500' : ''}"
                >
                    <span class="font-bold">{sample.RegId}</span>
                    <span class="text-sm text-gray-500">batch {sample.Batch}</span>
                </div>
            {/each}
        </div>

        <div class="flex flex-col gap-1 border-t pt-4">
            <span class="font-bold text-lg">Interpretation {selectedSample ? ': ' + selectedSample.RegId : ''}</span>
            <textarea 
                name="interpretation" 
                id="interpretation" 
                placeholder="Write Sample Interpretation {selectedSample ? ': ' + selectedSample.RegId : ''}" 
                class="w-full border-2 border-gray-200 p-2 min-h-[150px]"
            ></textarea>
            <button class="mt-2 bg-blue-600 text-white py-2 rounded hover:bg-blue-700">Save Notes</button>
        </div>

    </div>
    <div class="col-start-2 border-2 border-gray-200 overflow-hidden">
        <JBrowseViewer sample={selectedSample} />
    </div>
</div>