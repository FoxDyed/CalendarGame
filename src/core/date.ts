export function isValidPuzzleDate(monthIndex: number, day: number): boolean {
  return Number.isInteger(monthIndex) && Number.isInteger(day) && monthIndex >= 0 && monthIndex < 12 && day >= 1 && day <= 31;
}
