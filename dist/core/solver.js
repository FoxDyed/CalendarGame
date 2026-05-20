import { legalMoves, movePiece } from './puzzle.js';
function hashState(state) {
    return state.pieces.map((p)=>`${p.id}:${p.x},${p.y}`).join('|');
}
function clone(state) {
    return JSON.parse(JSON.stringify(state));
}
function heuristicDistance(state, target) {
    return state.pieces.reduce((sum, p, i)=>{
        const t = target.pieces[i];
        return sum + Math.abs(p.x - t.x) + Math.abs(p.y - t.y);
    }, 0);
}
function reconstructPath(prev, startHash, endHash) {
    const path = [];
    let cursor = endHash;
    while(cursor !== startHash){
        const step = prev.get(cursor);
        path.push(step.move);
        cursor = step.parent;
    }
    return path.reverse();
}
export function solveToInitial(state, target) {
    return solveWithAStar(state, target).steps;
}
export function solveWithAStar(state, target) {
    const startTime = performance.now();
    const start = clone(state);
    const startHash = hashState(start);
    const targetHash = hashState(target);
    if (startHash === targetHash) return {
        solvable: true,
        steps: [],
        explored: 0,
        elapsedMs: 0,
        score: 0
    };
    const gScore = new Map([
        [
            startHash,
            0
        ]
    ]);
    const fScore = new Map([
        [
            startHash,
            heuristicDistance(start, target)
        ]
    ]);
    const open = [
        {
            state: start,
            hash: startHash
        }
    ];
    const prev = new Map();
    const closed = new Set();
    let explored = 0;
    while(open.length){
        open.sort((a, b)=>(fScore.get(a.hash) ?? Infinity) - (fScore.get(b.hash) ?? Infinity));
        const current = open.shift();
        if (closed.has(current.hash)) continue;
        closed.add(current.hash);
        explored += 1;
        if (current.hash === targetHash) {
            const steps = reconstructPath(prev, startHash, targetHash);
            return {
                solvable: true,
                steps,
                explored,
                elapsedMs: performance.now() - startTime,
                score: steps.length + (fScore.get(current.hash) ?? 0)
            };
        }
        for (const m of legalMoves(current.state)){
            const next = clone(current.state);
            movePiece(next, m.pieceId, m.delta);
            const nextHash = hashState(next);
            const tentativeG = (gScore.get(current.hash) ?? Infinity) + 1;
            if (tentativeG >= (gScore.get(nextHash) ?? Infinity)) continue;
            prev.set(nextHash, {
                parent: current.hash,
                move: m
            });
            gScore.set(nextHash, tentativeG);
            fScore.set(nextHash, tentativeG + heuristicDistance(next, target));
            open.push({
                state: next,
                hash: nextHash
            });
        }
    }
    return {
        solvable: false,
        steps: [],
        explored,
        elapsedMs: performance.now() - startTime,
        score: Infinity
    };
}
export function generateHint(state, target) {
    const solved = solveWithAStar(state, target);
    return {
        hint: solved.steps[0] ?? null,
        remainingSteps: solved.steps.length,
        score: solved.score
    };
}
export function replaySolution(state, steps) {
    const timeline = [
        clone(state)
    ];
    for (const step of steps){
        const snapshot = clone(timeline[timeline.length - 1]);
        movePiece(snapshot, step.pieceId, step.delta);
        timeline.push(snapshot);
    }
    return timeline;
}
export function applySolveSteps(state, steps) {
    return steps.every((s)=>movePiece(state, s.pieceId, s.delta));
}
export function solverValidationHarness(seedStates, target) {
    let solved = 0;
    for (const sample of seedStates){
        const working = clone(sample);
        const result = solveWithAStar(working, target);
        if (!result.solvable) continue;
        if (applySolveSteps(working, result.steps) && hashState(working) === hashState(target)) solved += 1;
    }
    return {
        solved,
        unsolved: seedStates.length - solved
    };
}
