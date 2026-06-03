# GEMINI.md

## Project Overview

This project is an internal bioinformatics sample review portal built with SvelteKit and JBrowse 2.

The application allows a user to:

1. Browse a list of samples.
2. Select a sample from a sidebar.
3. View sample metadata.
4. View and edit interpretation/review notes.
5. View genomic data in an embedded JBrowse 2 Linear Genome View.

The portal is intended for a small number of users and does not require a separate backend framework such as FastAPI.

---

# Technology Stack

## Frontend

* SvelteKit
* TypeScript
* Tailwind CSS (optional)

## Genome Browser

* JBrowse 2
* Embedded using the React Linear Genome View component

## Storage

Initially:

* Sample metadata stored in JSON
* Notes may be stored in SQLite later

Genomic tracks are stored as static files:

* BigWig (.bw)
* VCF.gz (+ .tbi)
* BAM/CRAM (+ indexes)

These files are served via HTTP by SvelteKit.

---

# High-Level UI Layout

```text
+---------------------------------------------------+
| Sidebar                    | JBrowse             |
|----------------------------|                     |
| Sample List                |                     |
|                            |                     |
|----------------------------|                     |
| Metadata                   |                     |
|                            |                     |
|----------------------------|                     |
| Notes                      |                     |
| [textarea]                 |                     |
| [Save]                     |                     |
+---------------------------------------------------+
```

The left panel contains:

* Sample list
* Sample metadata
* Notes editor

The right panel contains:

* Embedded JBrowse instance

---

# Important Architectural Decision

There is ONE JBrowse instance.

We do NOT create one JBrowse session per sample.

We do NOT reload the page when a sample changes.

We do NOT recreate the entire browser configuration on every sample change.

Instead:

* Annotation tracks remain loaded permanently.
* Sample-specific tracks are replaced dynamically.

---

# Static Annotation Tracks

These tracks remain loaded for the entire lifetime of the application.

Examples:

* GENCODE genes
* RefSeq genes
* Panel genes
* Cytobands
* Other reference annotations

These tracks are loaded once during JBrowse initialization.

They should never be removed when changing samples.

---

# Dynamic Sample Tracks

These tracks depend on the currently selected sample.

Examples:

* Coverage BigWig
* BAM/CRAM alignments
* VCF variants
* CNV tracks

When a new sample is selected:

1. Remove previous sample tracks.
2. Add new sample tracks.
3. Keep annotation tracks unchanged.

Example:

```text
Sample A
---------
Coverage_A.bw
Variants_A.vcf.gz

↓

User selects Sample B

↓

Remove:
Coverage_A
Variants_A

Add:
Coverage_B
Variants_B
```

---

# Data Flow

## Initial Page Load

Server:

```text
samples.json
    ↓
+page.server.ts
    ↓
load()
    ↓
page data
```

Client:

```text
page data
    ↓
Sidebar
Metadata Panel
JBrowse
```

---

# Sample Selection Flow

```text
User clicks sample
        ↓
selectedSample updated
        ↓
Metadata panel updates
        ↓
Notes panel updates
        ↓
JBrowse track swap
```

No page reload.

No browser refresh.

---

# Sample Metadata Format

Example:

```json
[
  {
    "id": "P001",
    "diagnosis": "B-ALL",
    "bigwig": "/tracks/P001.bw",
    "vcf": "/tracks/P001.vcf.gz"
  }
]
```

The paths are HTTP URLs served by the application.

They are NOT filesystem paths.

Good:

```json
"/tracks/P001.bw"
```

Bad:

```json
"/data/samples/P001.bw"
```

---

# JBrowse Integration

JBrowse should be isolated in a dedicated component.

Example:

```text
src/lib/components/JBrowseViewer.svelte
```

The component receives:

```ts
sample
```

as a prop.

When the sample changes:

```text
sample prop changes
        ↓
update JBrowse tracks
```

The goal is to update only the sample-specific tracks.

---

# Important Constraints

1. Do not recreate the entire JBrowse instance on every sample change.

2. Do not reload the page.

3. Do not create one static JBrowse session file per sample.

4. Annotation tracks remain persistent.

5. Only sample-specific tracks should be swapped.

6. Keep architecture simple and maintainable.

7. Prefer SvelteKit-native data loading patterns before introducing APIs.

---

# Future Enhancements

Potential future features:

* SQLite-backed notes
* User authentication
* Sample filtering/search
* Saved genomic locations
* Multiple reviewers
* Review status tracking
* Variant annotation panels
* Report generation

Current focus is a minimal, working sample review portal.
