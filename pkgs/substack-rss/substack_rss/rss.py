import os
import xml.etree.ElementTree as ET
import email.utils
from datetime import datetime, timezone
from feedgen.feed import FeedGenerator

def parse_existing_rss(rss_file_path: str) -> list[dict]:
    """Parses existing RSS feed.xml to extract posts for history preservation."""
    items = []
    if not os.path.exists(rss_file_path):
        return items
    try:
        tree = ET.parse(rss_file_path)
        root = tree.getroot()
        channel = root.find("channel")
        if channel is None:
            return items
        
        # XML namespaces
        ns = {"content": "http://purl.org/rss/1.0/modules/content/"}
        
        for item_node in channel.findall("item"):
            title_node = item_node.find("title")
            link_node = item_node.find("link")
            desc_node = item_node.find("description")
            pub_date_node = item_node.find("pubDate")
            
            # Try to get content:encoded, fall back to content
            content_encoded = item_node.find("content:encoded", ns)
            if content_encoded is None:
                content_encoded = item_node.find("{http://purl.org/rss/1.0/modules/content/}encoded")
            content_node = item_node.find("content")
            
            link = link_node.text if link_node is not None else ""
            title = title_node.text if title_node is not None else ""
            description = desc_node.text if desc_node is not None else ""
            
            content = ""
            if content_encoded is not None and content_encoded.text:
                content = content_encoded.text
            elif content_node is not None and content_node.text:
                content = content_node.text
                
            published_date = None
            if pub_date_node is not None and pub_date_node.text:
                try:
                    tup = email.utils.parsedate_tz(pub_date_node.text)
                    if tup:
                        val = email.utils.mktime_tz(tup)
                        published_date = datetime.fromtimestamp(val, tz=timezone.utc)
                except Exception as e:
                    print(f"Failed to parse date '{pub_date_node.text}': {e}")
            if not published_date:
                published_date = datetime.now(timezone.utc)
                
            items.append({
                "title": title,
                "canonical_url": link,
                "description": description,
                "content": content,
                "published_date": published_date,
            })
    except Exception as e:
        print(f"Error parsing existing RSS feed {rss_file_path}: {e}")
    return items

def generate_rss_feed(items: list[dict], rss_file_path: str, base_url: str):
    """Generates a new RSS XML file using feedgen with the provided list of items."""
    # Ensure directory exists
    dir_name = os.path.dirname(rss_file_path)
    if dir_name:
        os.makedirs(dir_name, exist_ok=True)
        
    fg = FeedGenerator()
    fg.id(base_url)
    fg.title("Substack RSS Feed")
    fg.link(href=base_url, rel="self")
    fg.description("Automated RSS feed generated from forwarded Substack links")
    fg.language("en")

    for item in items:
        fe = fg.add_entry()
        fe.id(item["canonical_url"])
        fe.title(item["title"])
        fe.link(href=item["canonical_url"])
        fe.description(item["description"])
        
        # Set full sanitized markdown content inside content:encoded
        fe.content(item["content"], type="html")
        
        # Ensure pubDate is timezone-aware
        pub_date = item["published_date"]
        if pub_date.tzinfo is None:
            pub_date = pub_date.replace(tzinfo=timezone.utc)
        fe.pubDate(pub_date)
        
    fg.rss_file(rss_file_path, pretty=True)

def add_post_to_feed(post_data: dict, rss_file_path: str, base_url: str, max_items: int = 50):
    """Integrates a new scraped post into the RSS feed, saving history up to max_items."""
    # Load existing items
    existing_items = parse_existing_rss(rss_file_path)
    
    # Create the new item
    new_item = {
        "title": post_data["title"],
        "canonical_url": post_data["canonical_url"],
        "description": post_data["description"],
        # Content is the sanitized markdown
        "content": post_data["markdown"],
        "published_date": post_data["published_date"],
    }
    
    # Merge items, removing duplicates by canonical_url
    merged_dict = {}
    for item in existing_items:
        merged_dict[item["canonical_url"]] = item
        
    # Overwrite/add the new item
    merged_dict[new_item["canonical_url"]] = new_item
    
    # Convert back to list and sort by date descending
    merged_items = list(merged_dict.values())
    
    # Ensure all published_dates are timezone-aware for sorting
    for item in merged_items:
        if item["published_date"].tzinfo is None:
            item["published_date"] = item["published_date"].replace(tzinfo=timezone.utc)
            
    merged_items.sort(key=lambda x: x["published_date"], reverse=True)
    
    # Truncate to max_items
    merged_items = merged_items[:max_items]
    
    # Generate feed
    generate_rss_feed(merged_items, rss_file_path, base_url)
