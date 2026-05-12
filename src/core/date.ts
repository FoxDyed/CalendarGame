const MONTHS = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'] as const;

export function monthIndexToLabel(monthIndex: number): string {
  if (!Number.isInteger(monthIndex) || monthIndex < 0 || monthIndex > 11) {
    throw new Error(`Invalid monthIndex: ${monthIndex}`);
  }
  return MONTHS[monthIndex];
}

export function isValidPuzzleDate(monthIndex: number, day: number): boolean {
  return Number.isInteger(monthIndex) && Number.isInteger(day) && monthIndex >= 0 && monthIndex < 12 && day >= 1 && day <= 31;
}

export function dayToIndex(day: number): number {
  if (!Number.isInteger(day) || day < 1 || day > 31) {
    throw new Error(`Invalid day: ${day}`);
  }
  return day - 1;
}
