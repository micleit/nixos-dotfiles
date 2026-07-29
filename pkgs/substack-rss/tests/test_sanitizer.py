import sys
import os

# Add parent directory to path so we can import substack_rss
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from substack_rss.sanitizer import sanitize_markdown

def test_sanitizer():
    sample_markdown = """
# Substack Article Title

Welcome to the newsletter. Here is some text with [a link to a page](https://example.com/some/path) in the middle.

Check out this image:
![Awesome illustration of NixOS](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F1234.png)

We also have some residual HTML tags like <div class="caption">Image Caption</div> and <br/> breaks.

    
Let's see if multiple blank lines are compressed properly.


Thank you for reading!
"""
    expected_output = """# Substack Article Title

Welcome to the newsletter. Here is some text with a link to a page in the middle.

Check out this image:


We also have some residual HTML tags like Image Caption and  breaks.

Let's see if multiple blank lines are compressed properly.

Thank you for reading!"""

    sanitized = sanitize_markdown(sample_markdown)
    print("--- ORIGINAL ---")
    print(sample_markdown)
    print("--- SANITIZED ---")
    print(sanitized)
    print("-----------------")

    # Assertions
    assert "![Awesome illustration of NixOS]" not in sanitized
    assert "https://substackcdn.com" not in sanitized
    assert "a link to a page" in sanitized
    assert "https://example.com/some/path" not in sanitized
    assert "<div" not in sanitized
    assert "Image Caption" in sanitized
    assert "\n\n\n" not in sanitized

    print("All tests passed successfully!")

if __name__ == "__main__":
    test_sanitizer()
