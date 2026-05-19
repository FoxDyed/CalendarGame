const MONTHS = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'] as const;
const MONTH_LENGTHS = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31] as const;

export function monthIndexToLabel(monthIndex: number): string {
  if (!Number.isInteger(monthIndex) || monthIndex < 0 || monthIndex > 11) {
    throw new Error(`Invalid monthIndex: ${monthIndex}`);
  }
  return MONTHS[monthIndex];
}

export function isValidPuzzleDate(monthIndex: number, day: number): boolean {
  return Number.isInteger(monthIndex) && Number.isInteger(day) && monthIndex >= 0 && monthIndex < 12 && day >= 1 && day <= MONTH_LENGTHS[monthIndex];
}

export function dayToIndex(day: number): number {
  if (!Number.isInteger(day) || day < 1 || day > 31) {
    throw new Error(`Invalid day: ${day}`);
  }
  return day - 1;
}

export function daysInPuzzleMonth(monthIndex: number): number {
  if (!Number.isInteger(monthIndex) || monthIndex < 0 || monthIndex > 11) {
    throw new Error(`Invalid monthIndex: ${monthIndex}`);
  }
  return MONTH_LENGTHS[monthIndex];
}
