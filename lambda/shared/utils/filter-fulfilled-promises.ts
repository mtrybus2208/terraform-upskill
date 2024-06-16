export const filterFulfilledPromises = <T>(
  promises: PromiseSettledResult<T>[]
): T[] => {
  return promises
    .filter(
      (item): item is PromiseFulfilledResult<T> => item.status === "fulfilled"
    )
    .map((it) => it.value);
};
