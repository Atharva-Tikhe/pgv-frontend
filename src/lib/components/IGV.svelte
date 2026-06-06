<script lang="ts">
    import {onMount} from 'svelte';
    // import igv from 'igv';
    import type {Sample} from '$lib/types/api';

    let {sample} = $props();
    
    let container: HTMLDivElement | null = null;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    let browser: any | null;
    
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    let currentSegmentTrack : any | null = null;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    let currentLRRTrack : any | null = null; 

    // eslint-disable-next-line @typescript-eslint/no-unused-vars, @typescript-eslint/no-explicit-any
    let currentMerged : any | null = null; 

    onMount(async () => {

        const igvModule = await import('igv')
        const igv = igvModule.default

        if (!container) return;

        browser = await igv.createBrowser(container, {
            genome: 'hg38',
            // locus: 'IKZF1',

            tracks: [
                {
                    name: 'RefSeq Genes',
                    type: 'annotation',
                    format: 'gff3',
                    url: 'http://localhost:8000/static/data/GCA_000001405.15_GRCh38_full_analysis_set.refseq_annotation.sorted.gff.gz',
                    indexURL: 'http://localhost:8000/static/data/GCA_000001405.15_GRCh38_full_analysis_set.refseq_annotation.sorted.gff.gz.tbi'
                },

                {
                    type: "annotation",
                    format: "bed",
                    name: "Panel Genes (UKALL)",
                    url: "http://localhost:8000/static/data/gene_calls_browser.bed.gz", 
                    indexURL: "http://localhost:8000/static/data/gene_calls_browser.bed.gz.tbi"
                }

                // {
                //     name: 'Panel Genes',
                //     type: 'annotation',
                //     format: 'bed',
                //     url: 'http://localhost:8000/static/data/panel.bed'
                // }
            ]
        })
    })

    async function swapSampleTracks(sample: Sample) {
        if (!browser || !sample) return 

        if (currentSegmentTrack) {
            browser.removeTrack(currentSegmentTrack)
        }

        if (currentLRRTrack) {
            browser.removeTrack(currentLRRTrack)
        }

        if (currentMerged) {
            browser.removeTrack(currentMerged)
        }

        currentSegmentTrack = await browser.loadTrack({
            id: `seg_${sample.RegId}`,
            name: `Segments ${sample.RegId}`,
            type: 'wig',
            format: 'bigwig',
            url: `http://localhost:8000/static/data/${sample.RegId}_seg.bw`
        })

        currentLRRTrack = await browser.loadTrack({
            id: `lrr_${sample.RegId}`,
            name: `LRR ${sample.RegId}`,
            type: 'wig',
            format: 'bigwig',
            graphType: 'points',
            url: `http://localhost:8000/static/data/${sample.RegId}_lrr.bw`
        })



        currentMerged = await browser.loadTrack({
            name: "Merged",
            height: 50,
            type: 'merged',
            tracks: [
                {
                    id: `lrr_${sample.RegId}`,
                    name: `LRR ${sample.RegId}`,
                    type: 'wig',
                    format: 'bigwig',
                    graphType: 'points',
                    url: `http://localhost:8000/static/data/${sample.RegId}_lrr.bw`
                },
                {
                    id: `seg_${sample.RegId}`,
                    name: `Segments ${sample.RegId}`,
                    type: 'wig',
                    format: 'bigwig',
                    graphType: 'line',
                    color: 'red',
                    url: `http://localhost:8000/static/data/${sample.RegId}_seg.bw`
                }
            ]
        })

        console.log(currentMerged)
    }


    $effect(() => {
        if (sample) {
            swapSampleTracks(sample)
        }
    })

</script>

<div bind:this={container} class="h-full w-full"></div>
