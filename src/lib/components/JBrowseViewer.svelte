<script lang="ts">
    import { onMount } from 'svelte';
    import { createRoot } from 'react-dom/client';
    import { createElement } from 'react';

    // import {createViewState, JBrowseLinearGenomeView} from '@jbrowse/react-linear-genome-view2';

    import type { Sample } from '$lib/types/api';

    interface Props {
        sample: Sample | null;
    }

    let { sample }: Props = $props();

    let container: HTMLDivElement | null = null;
    let root: ReturnType<typeof createRoot>;
    let viewState: any;

    const COVERAGE_TRACK_ID = 'sample_coverage';
    const LRR_TRACK_ID = 'sample_lrr';

    onMount(async () => {
        const jbrowse = await import ('@jbrowse/react-linear-genome-view2')
        const createViewState = jbrowse.createViewState;
        const JBrowseLinearGenomeView = jbrowse.JBrowseLinearGenomeView;

        // import {createViewState, JBrowseLinearGenomeView} from '@jbrowse/react-linear-genome-view2';

        const assembly = {
            name: "hg38",
            sequence: {
                type: "ReferenceSequenceTrack",
                trackId: "GRCh38-ReferenceSequenceTrack",
                adapter: {
                    type: "BgzipFastaAdapter",
                    uri: "https://jbrowse.org/genomes/GRCh38/fasta/hg38.prefix.fa.gz",
                },
            },
            refNameAliases: {
                adapter: {
                    type: "RefNameAliasAdapter",
                    uri: "https://jbrowse.org/genomes/GRCh38/hg38_aliases.txt",
                },
            },
            cytobands: {
                adapter: {
                    type: "CytobandAdapter",
                    uri: "https://jbrowse.org/genomes/GRCh38/cytoBand.txt",
                },
            },
        
        };

        const refseqTrack = {
            type: "FeatureTrack",
            trackId: "ncbi_genes",
            name: "NCBI RefSeq Genes",
            assemblyNames: ["hg38"],
            adapter: {
                type: "Gff3TabixAdapter",
                uri: "https://jbrowse.org/genomes/GRCh38/ncbi_refseq/GCA_000001405.15_GRCh38_full_analysis_set.refseq_annotation.sorted.gff.gz",
            },
        }

        const panelGenesTrack = {
            type: 'FeatureTrack',
            trackId: 'panel_genes',
            name: 'Panel Genes',
            assemblyNames: ['hg38'],
            adapter: {
            type: 'BedTabixAdapter',
            bedGzLocation: {
                uri: '/data/gene_calls_browser.bed.gz',
            },
            index: {
                location: {
                uri: '/data/gene_calls_browser.bed.gz.tbi',
                },
            },
            },
        };

    

        // const jbrowse = await import(
        //     '@jbrowse/react-linear-genome-view2'
        // );

        // import {createViewState, JBrowseLinearGenomeView} from '@jbrowse/react-linear-genome-view2';
        // const createViewState = jbrowse.createViewState;
        // const JBrowseLinearGenomeView = jbrowse.JBrowseLinearGenomeView;

        viewState = createViewState({
            assembly,
            tracks: [
            refseqTrack,
            panelGenesTrack,
            ],
            location: '1:1..1000000',
            defaultSession: {
                name: "My session",
                view: {
                    id: "linearGenomeView",
                    type: "LinearGenomeView",
                    init: {
                    assembly: "hg38",
                    loc: "10:29,838,565..29,838,850",
                    tracks: ["ncbi_genes","panel_genes"],
                    },
                },
            },

        });

        root = createRoot(container);

        root.render(
            createElement(JBrowseLinearGenomeView, {
            viewState,
            }),
        );

        console.log(viewState.navLocString())

        if (sample) {
            loadSampleTracks(sample);
        }
    });

    function loadSampleTracks(sample: Sample) {
        const { view } = viewState.session;
        
        console.log('loading .. ' + sample.RegId)
        removeTrack(COVERAGE_TRACK_ID);
        removeTrack(LRR_TRACK_ID);

        const coverageTrack = {
            type: 'QuantitativeTrack',
            trackId: COVERAGE_TRACK_ID,
            name: `Coverage ${sample.RegId}`,
            assemblyNames: ['hg38'],
            adapter: {
            type: 'BigWigAdapter',
            bigWigLocation: {
                uri: `/data/${sample.RegId}_seg.bw`,
            },
            },
        };
    
          const lrrTrack = {
            type: 'QuantitativeTrack',
            trackId: LRR_TRACK_ID,
            name: `LRR ${sample.RegId}`,
            assemblyNames: ['hg38'],
            adapter: {
            type: 'BigWigAdapter',
            bigWigLocation: {
                uri: `/data/${sample.RegId}_lrr.bw`,
            },
            },
        };
        
        viewState.jbrowse.addTrackConf(coverageTrack);
        viewState.jbrowse.addTrackConf(lrrTrack);

        view.showTrack(COVERAGE_TRACK_ID);
        view.showTrack(LRR_TRACK_ID);
    }

    function removeTrack(trackId: string) {
        const track = viewState?.jbrowse?.tracks?.find(
            (t: any) => t.trackId === trackId,
        );

        if (!track) return;

        viewState.session.view.hideTrack(trackId);
        viewState.jbrowse.removeTrackConf(track);
    }

    $effect(() => {
        if (!viewState || !sample) return;

        loadSampleTracks(sample);
    });

</script>

<div
  bind:this={container}
></div>

<!-- <div>placeholder</div> -->