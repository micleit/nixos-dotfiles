import re
import requests
from bs4 import BeautifulSoup
from urllib.parse import urlparse
from markdownify import markdownify as md
from datetime import datetime

# Standard headers to avoid blocking
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.5",
}

def extract_slug_and_domain(url: str) -> tuple[str, str]:
    """Extracts the post slug and netloc domain from a Substack URL."""
    parsed = urlparse(url)
    domain = parsed.netloc
    # Slug is the part after /p/
    match = re.search(r'/p/([^/]+)', parsed.path)
    slug = match.group(1) if match else ""
    return slug, domain

def scrape_post_api(url: str) -> dict | None:
    """Attempts to fetch post data using the internal Substack JSON API."""
    slug, domain = extract_slug_and_domain(url)
    if not slug or not domain:
        return None
    
    api_url = f"https://{domain}/api/v1/posts/{slug}"
    try:
        response = requests.get(api_url, headers=HEADERS, timeout=10)
        if response.status_code == 200:
            data = response.json()
            title = data.get("title") or ""
            description = data.get("subtitle") or data.get("description") or ""
            post_date_str = data.get("post_date") or ""
            
            # Format published date to datetime object
            published_date = None
            if post_date_str:
                try:
                    # e.g., 2023-10-15T12:00:00.000Z
                    published_date = datetime.fromisoformat(post_date_str.replace("Z", "+00:00"))
                except ValueError:
                    published_date = datetime.utcnow()
            else:
                published_date = datetime.utcnow()
                
            body_html = data.get("body_html") or ""
            
            return {
                "title": title,
                "description": description,
                "published_date": published_date,
                "body_html": body_html,
                "canonical_url": data.get("canonical_url") or url,
            }
    except Exception as e:
        print(f"API scraping failed for {url}: {e}")
    return None

def scrape_post_html(url: str) -> dict | None:
    """Falls back to BeautifulSoup parsing of the page HTML."""
    try:
        response = requests.get(url, headers=HEADERS, timeout=10)
        if response.status_code != 200:
            return None
        
        soup = BeautifulSoup(response.text, "html.parser")
        
        # 1. Extract title
        title_tag = soup.find("meta", property="og:title")
        title = title_tag["content"] if title_tag else (soup.title.string if soup.title else "")
        
        # 2. Extract description
        desc_tag = soup.find("meta", property="og:description")
        description = desc_tag["content"] if desc_tag else ""
        
        # 3. Extract publication date
        date_tag = soup.find("meta", property="article:published_time")
        published_date = None
        if date_tag:
            try:
                published_date = datetime.fromisoformat(date_tag["content"].replace("Z", "+00:00"))
            except ValueError:
                pass
        if not published_date:
            published_date = datetime.utcnow()
            
        # 4. Extract body HTML using common Substack selectors
        body_html = ""
        # Substack post content container order of preference
        selectors = [
            "div.available-content-outer", # Free part of paid articles
            "div.post-content",
            "div.markup",
            "div.post-body",
            "article"
        ]
        
        for selector in selectors:
            element = soup.select_one(selector)
            if element:
                body_html = str(element)
                break
                
        # If no specific container found, use the body or raw text
        if not body_html:
            body_html = str(soup.body) if soup.body else response.text

        return {
            "title": title,
            "description": description,
            "published_date": published_date,
            "body_html": body_html,
            "canonical_url": url,
        }
    except Exception as e:
        print(f"HTML scraping failed for {url}: {e}")
    return None

def scrape_substack_post(url: str) -> dict | None:
    """Scrapes a Substack post by trying the JSON API first, then HTML fallback."""
    # Attempt API first
    result = scrape_post_api(url)
    if result and result.get("body_html"):
        # Convert HTML to markdown
        result["markdown"] = md(result["body_html"])
        return result
    
    # Fallback to HTML
    result = scrape_post_html(url)
    if result:
        result["markdown"] = md(result["body_html"])
        return result
        
    return None
