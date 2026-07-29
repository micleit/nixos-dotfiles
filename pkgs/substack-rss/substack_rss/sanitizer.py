import re

def strip_markdown_images(text: str) -> str:
    """Strips Markdown images: ![alt](url) -> ''."""
    pattern = r'!\[.*?\]\(.*?\)'
    return re.sub(pattern, '', text)

def convert_hyperlinks(text: str) -> str:
    """Converts hyperlinks: [text](url) -> text."""
    pattern = r'\[(.*?)\]\(.*?\)'
    return re.sub(pattern, r'\1', text)

def remove_html_tags(text: str) -> str:
    """Removes residual HTML tags: <p> -> ''."""
    pattern = r'<[^>]*>'
    return re.sub(pattern, '', text)

def clean_whitespace(text: str) -> str:
    """Cleans extra whitespace and compresses multiple newlines."""
    # Remove trailing spaces on lines first (turns lines with only spaces into empty lines)
    text = re.sub(r'[ \t]+\n', '\n', text)
    # Compress multiple newlines to at most two newlines
    text = re.sub(r'\n{3,}', '\n\n', text)
    # Clean leading/trailing spaces
    return text.strip()

def sanitize_markdown(text: str) -> str:
    """Runs all sanitization steps in order."""
    text = strip_markdown_images(text)
    text = convert_hyperlinks(text)
    text = remove_html_tags(text)
    text = clean_whitespace(text)
    return text
