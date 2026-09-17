export const DEFAULT_KEYWORD_MAX_LENGTH = 50

export function resolveKeywordMaxLength (instanceconfig) {
  const n = parseInt(instanceconfig?.keywordMaxLength, 10)
  return Number.isFinite(n) && n > 0 ? n : DEFAULT_KEYWORD_MAX_LENGTH
}
