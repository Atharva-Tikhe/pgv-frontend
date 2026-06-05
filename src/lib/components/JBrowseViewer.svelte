<script lang="ts">
    import { onMount, onDestroy } from 'svelte';
    import { createRoot } from 'react-dom/client';
    import { createElement } from 'react';
    import {
        createViewState,
        JBrowseLinearGenomeView,
    } from '@jbrowse/react-linear-genome-view';
    import type { Sample } from '$lib/types/api';

    interface Props {
        sample: Sample | null;
    }

    let { sample }: Props = $props();

    let container: HTMLDivElement;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    let root: any;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    let viewState: any = $state();

    // Static Track IDs
    const GENCODE_TRACK_ID = 'gencode_v49_annotation';

    // JBrowse Configuration
    const assembly = {
        name: 'hg38',
        sequence: {
            type: 'ReferenceSequenceTrack',
            trackId: 'hg38-ReferenceSequenceTrack',
            adapter: {
                type: 'BgzipFastaAdapter',
                fastaLocation: { uri: '/data/hg38.fa.gz' },
                faiLocation: { uri: '/data/hg38.fa.gz.fai' },
                gziLocation: { uri: '/data/hg38.fa.gz.gzi' },
            },
        },
    };

    const tracks = [
        {
            type: 'FeatureTrack',
            trackId: GENCODE_TRACK_ID,
            name: 'GENCODE v49',
            assemblyNames: ['hg38'],
            category: ['Annotation'],
            adapter: {
                type: 'Gff3TabixAdapter',
                gffGzLocation: { uri: '/data/gencode.v49.annotation.sorted.gff3.gz' },
                index: {
                    location: { uri: '/data/gencode.v49.annotation.sorted.gff3.gz.tbi' },
                },
            },
        },
    ];

    onMount(() => {
        viewState = createViewState({
            assembly,
            tracks,
            location: '1:1..100000', // Default location
            defaultSession: {
                name: 'Sample Review Session',
                view: {
                    id: 'linearGenomeView',
                    type: 'LinearGenomeView',
                    tracks: [
                        {
                            type: 'FeatureTrack',
                            configuration: GENCODE_TRACK_ID,
                            displays: [
                                {
                                    type: 'LinearBasicDisplay',
                                    configuration: `${GENCODE_TRACK_ID}-LinearBasicDisplay`,
                                },
                            ],
                        },
                    ],
                },
            },
        });

        root = createRoot(container);
        render();
    });

    onDestroy(() => {
        if (root) {
            root.unmount();
        }
    });

    function render() {
        if (root && viewState) {
            root.render(createElement(JBrowseLinearGenomeView, { viewState }));
        }
    }

    // Effect to handle sample changes
    $effect(() => {
        if (viewState && sample) {
            updateSampleTracks(sample);
        }
    });

    function updateSampleTracks(newSample: Sample) {
        const { session } = viewState;
        const { view } = session;

        // 1. Identify and remove previous sample-specific tracks
        // We'll use a naming convention like 'sample_{RegId}_track'
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const tracksToRemove = viewState.jbrowse.tracks.filter((t: any) => 
            t.trackId.startsWith('sample_')
        );

        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        tracksToRemove.forEach((t: any) => {
            view.hideTrack(t.trackId);
            viewState.jbrowse.removeTrackConf(t);
        });

        // 2. Add new sample tracks
        const coverageTrackId = `sample_${newSample.RegId}_coverage`;
        const variantTrackId = `sample_${newSample.RegId}_variants`;

        const coverageTrack = {
            type: 'QuantitativeTrack',
            trackId: coverageTrackId,
            name: `Segments (${newSample.RegId})`,
            assemblyNames: ['hg38'],
            category: ['Sample Data'],
            adapter: {
                type: 'BigWigAdapter',
                bigWigLocation: { uri: `/data/${newSample.RegId}_seg.bw` },
            },
        };


        viewState.jbrowse.addTrackConf(coverageTrack);

        // 3. Show the new tracks
        view.showTrack(coverageTrackId);
        view.showTrack(variantTrackId);

        render();
    }
</script>

<div bind:this={container} class="w-full h-full border border-gray-300">
    {#if !viewState}
        <div class="flex items-center justify-center h-full">
            <p class="text-gray-500">Initializing JBrowse...</p>
        </div>
    {/if}
</div>

<style>
    /* Ensure the container has a defined height */
    div {
        min-height: 600px;
    }
</style>
