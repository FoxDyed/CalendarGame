export function serializePuzzle(state) {
    const payload = {
        version: 1,
        state
    };
    return JSON.stringify(payload);
}
export function deserializePuzzle(raw) {
    const parsed = JSON.parse(raw);
    if (parsed.version !== 1 || !parsed.state) throw new Error('Invalid puzzle serialization payload');
    return parsed.state;
}
