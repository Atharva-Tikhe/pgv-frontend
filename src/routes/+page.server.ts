import type { Sample } from "$lib/types/api"
import {readFile} from 'fs/promises';


export async function load() {

    const json = await readFile("static/samples_b1.json", 'utf-8');
    const samples : Sample[] = JSON.parse(json);
    console.log(samples); 
    return {
        samples: samples
    }

}