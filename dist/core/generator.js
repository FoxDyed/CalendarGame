import { createInitialState, randomize, setDate } from './puzzle.js';
import { solveWithAStar } from './solver.js';
const MONTH_LENGTHS = [
    31,
    28,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31
];
export function generateAllDateCases() {
    const dates = [];
    for(let m = 0; m < 12; m += 1){
        for(let d = 1; d <= MONTH_LENGTHS[m]; d += 1)dates.push({
            monthIndex: m,
            day: d
        });
    }
    return dates;
}
export function generateCandidate(seedRng) {
    const state = createInitialState();
    randomize(state, seedRng);
    return state;
}
export function generateSolvableBoardForDate(seedRng, date, retries = 40) {
    const target = createInitialState();
    setDate(target, date.monthIndex, date.day);
    for(let i = 0; i < retries; i += 1){
        const candidate = generateCandidate(seedRng);
        setDate(candidate, date.monthIndex, date.day);
        const solved = solveWithAStar(candidate, target);
        if (solved.solvable) return candidate;
    }
    throw new Error(`Could not generate solvable board for ${date.monthIndex + 1}/${date.day}`);
}
export function validateGeneratorForYear(seedRng) {
    const unsolved = [];
    const invalid = [];
    const cases = generateAllDateCases();
    for (const date of cases){
        try {
            const candidate = generateSolvableBoardForDate(seedRng, date, 15);
            const target = createInitialState();
            setDate(target, date.monthIndex, date.day);
            const solved = solveWithAStar(candidate, target);
            if (!solved.solvable) unsolved.push(date);
        } catch  {
            invalid.push(date);
        }
    }
    return {
        generated: cases.length,
        unsolved,
        invalid
    };
}
