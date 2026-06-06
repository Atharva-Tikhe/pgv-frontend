<script lang="ts">
    import IGV from '$lib/components/IGV.svelte';
    import Versions from '$lib/components/Versions.svelte';
    import type { Sample, Samples } from '$lib/types/api';
    import {onMount} from 'svelte';

    let data : Samples | undefined = $state();
    let interpretation = $state("");
    let saved : boolean = $state(false);

    let selectedSample: Sample | null = $state(null);

    const loadSample = function (sample: Sample) {
        selectedSample = sample;
    }

    onMount(async () => {
      const resp = await fetch('http://daedalus.ncl.ac.uk:8000/samples/batch/1')
      const respJson = await resp.json()
      data = respJson
      console.log(respJson)
    })
  
    const sendInterpretation = async function(selectedSample : Sample | null) {
        const resp = await fetch('http://daedalus.ncl.ac.uk:8000/samples/interpretation', {
            method : 'POST',
            headers : {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({sample_id: selectedSample?.RegId.toString(), interpretation: interpretation})
        });
        const status = await resp.json()

        console.log(status)
        console.log(resp.status)

        if (resp.status == 200 && status.status == 'ok'){
            saved = !saved;
            interpretation = '';

            setTimeout(() => {
                saved = !saved;
            }, 1000)
        }
    }
</script>

<nav class="ml-5 flex items-center gap-2">
    <img src="http://daedalus.ncl.ac.uk:8000/static/LRCG.jpeg" class="w-20" alt="">
    <h3 class=" capitalize font-bold font-sans">|</h3>
    <h3 class=" capitalize font-bold font-sans">Patient Genome Viewer</h3>
    <div class="text-sm ml-auto mr-5">
        <Versions />
    </div>
    
</nav>

<div class="grid grid-cols-[0.3fr_1fr] gap-4 mt-2 mb-5 mx-5 max-h-100">

    <div class="col-start-1 col-span-1 flex flex-col gap-4 max-h-1/2">
        <div class="overflow-y-auto max-h-1/6 border-gray-200 border-2">
            {#each data as sample, idx (idx)}
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
                bind:value={interpretation}
            ></textarea>
            <button onclick={() => sendInterpretation(selectedSample)} class="mt-2 {saved ? 'bg-green-600 hover:bg-green-700' : 'bg-blue-600 hover:bg-blue-700'} text-white py-2 rounded ">{saved ? "Saved!" : 'Save Notes'}</button>
        </div>

    </div>
    <div class="col-start-2 border-2 border-gray-200 overflow-hidden max-h-1/2">
        Selected: {selectedSample?.RegId}
        <!-- <JBrowseViewer sample={selectedSample} /> -->
         <IGV sample={selectedSample} />
    </div>
</div>
