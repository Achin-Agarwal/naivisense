String toTitleCase(String text) {
  return text
      .trim()
      .split(RegExp(r'\s+'))
      .map(
        (word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}
