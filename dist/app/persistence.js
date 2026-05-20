const KEY = 'calendar-puzzle-v1';
export function saveState(state) {
    localStorage.setItem(KEY, JSON.stringify(state));
}
export function loadState() {
    const raw = localStorage.getItem(KEY);
    if (!raw) return null;
    try {
        const parsed = JSON.parse(raw);
        if (!parsed.puzzle?.pieces?.every((p)=>Array.isArray(p.cells))) return null;
        return parsed;
    } catch  {
        return null;
    }
}
