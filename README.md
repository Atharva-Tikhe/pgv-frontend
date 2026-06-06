# Patient Genome Viewer (PGV) - Svelte

A modern, web-based application for visualizing and interpreting genomic data. Built with Svelte 5, this tool provides clinicians and researchers with an interactive interface to explore patient samples, visualize genomic tracks, and record clinical interpretations.

## Features

- **Sample Management**: Easily browse through patient samples organized by batches.
- **Interactive Genome Viewing**: Integrated with [IGV.js](https://github.com/igvteam/igv.js) for high-performance genomic visualization.
- **Dynamic Track Loading**: Automatically loads relevant genomic tracks (LRR and Segments) in BigWig format for the selected patient.
- **Clinical Interpretations**: Integrated note-taking system to record and save interpretations for each sample.
- **Responsive Design**: Built with Tailwind CSS for a modern, responsive user interface.
- **Dockerized Environment**: Ready for containerized deployment with Docker and Docker Compose.

## Tech Stack

- **Framework**: [Svelte 5](https://svelte.dev/) (Runes)
- **Build Tool**: [Vite](https://vitejs.dev/)
- **Styling**: [Tailwind CSS](https://tailwindcss.com/)
- **Genomic Visualization**: [IGV.js](https://igv.org/)
- **Type Safety**: [TypeScript](https://www.typescriptlang.org/)

## Getting Started

### Prerequisites

- Node.js (v20 or later recommended)
- Docker and Docker Compose (for containerized setup)

### Local Development

1.  **Clone the repository**:
    ```bash
    git clone <repository-url>
    cd pgv-svelte
    ```

2.  **Install dependencies**:
    ```bash
    npm install
    ```

3.  **Run the development server**:
    ```bash
    npm run dev
    ```
    The application will be available at `http://localhost:5173`.

### Docker Setup

The project includes a `docker-compose.yml` file to orchestrate the frontend and its backend dependency.

1.  **Build and start the containers**:
    ```bash
    docker-compose up --build
    ```
    The frontend will be accessible at `http://localhost:3000`.

*Note: Ensure the backend service (`pgv-backend`) is available at the expected path as defined in `docker-compose.yml`.*

## Project Structure

- `src/lib/components/`: Reusable Svelte components (IGV viewer, Sidebar, etc.).
- `src/routes/`: SvelteKit routes and API endpoints.
- `static/`: Static assets and local data files.

## Configuration

The application expects a backend API to be running (default: `http://localhost:8000`). This is used for fetching sample lists and saving interpretations.
