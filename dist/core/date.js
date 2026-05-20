const MONTHS = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
];
const MONTH_LENGTHS = [
    31,
    29,
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
export function monthIndexToLabel(monthIndex) {
    if (!Number.isInteger(monthIndex) || monthIndex < 0 || monthIndex > 11) {
        throw new Error(`Invalid monthIndex: ${monthIndex}`);
    }
    return MONTHS[monthIndex];
}
export function isValidPuzzleDate(monthIndex, day) {
    return Number.isInteger(monthIndex) && Number.isInteger(day) && monthIndex >= 0 && monthIndex < 12 && day >= 1 && day <= MONTH_LENGTHS[monthIndex];
}
export function dayToIndex(day) {
    if (!Number.isInteger(day) || day < 1 || day > 31) {
        throw new Error(`Invalid day: ${day}`);
    }
    return day - 1;
}
export function daysInPuzzleMonth(monthIndex) {
    if (!Number.isInteger(monthIndex) || monthIndex < 0 || monthIndex > 11) {
        throw new Error(`Invalid monthIndex: ${monthIndex}`);
    }
    return MONTH_LENGTHS[monthIndex];
}
