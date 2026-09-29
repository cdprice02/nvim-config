from collections import Counter


def word_counts(text: str) -> Counter[str]:
    """Count how often each word appears."""
    return Counter(text.split())
