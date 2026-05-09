declare module 'vitest' {
  export type MockedFunction<T extends (...args: any[]) => any> = T & {
    mockResolvedValue(value: Awaited<ReturnType<T>>): void;
    mockRejectedValue(value: unknown): void;
  };

  export function describe(name: string, fn: () => void): void;
  export function it(name: string, fn: () => void | Promise<void>): void;
  export function beforeEach(fn: () => void | Promise<void>): void;
  export function expect(value: unknown): {
    toBe(expected: unknown): void;
    toContain(expected: unknown): void;
    toBeTruthy(): void;
  };
  export const vi: {
    fn: () => (...args: unknown[]) => unknown;
    mocked: <T extends (...args: any[]) => any>(value: T) => MockedFunction<T>;
    resetAllMocks: () => void;
    mock: (path: string, factory: () => unknown) => void;
  };
}
