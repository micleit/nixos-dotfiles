import os
import re
from telegram import Update
from telegram.ext import ApplicationBuilder, CommandHandler, MessageHandler, filters, ContextTypes

from substack_rss.scraper import scrape_substack_post
from substack_rss.sanitizer import sanitize_markdown
from substack_rss.rss import add_post_to_feed

# Regex to check for Substack URL (typically contains /p/ and substack.com or custom domain)
SUBSTACK_URL_PATTERN = re.compile(r'https?://[^\s/$.?#].[^\s]*/p/[^\s]+')

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Sends greeting message when the command /start is issued."""
    await update.message.reply_text(
        "Hi! Send me a Substack post link (containing `/p/`), and I will scrape it, "
        "sanitize the markdown (removing images and stripping link URLs), and add it to the RSS feed."
    )

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Handles text messages and looks for Substack links."""
    text = update.message.text
    if not text:
        return
    
    match = SUBSTACK_URL_PATTERN.search(text)
    if not match:
        return
        
    url = match.group(0)
    # Strip any trailing characters or query params (like ?utm_source=...)
    url = url.split('?')[0]
    
    await update.message.reply_text(f"Scraping Substack post: {url}...")
    
    try:
        # 1. Scrape the post
        post_data = scrape_substack_post(url)
        if not post_data:
            await update.message.reply_text("Error: Failed to scrape post. Make sure the article is public and exists.")
            return
            
        # 2. Sanitize content
        sanitized_markdown = sanitize_markdown(post_data["markdown"])
        post_data["markdown"] = sanitized_markdown
        
        # 3. Read environment variables
        base_url = os.environ.get("BASE_URL", "http://localhost:8080")
        rss_file_path = os.environ.get("RSS_FILE_PATH", "/var/lib/substack-rss/feed.xml")
        
        # Feed base URL (could be the URL where the feed is served, or the caddy URL)
        feed_url = f"{base_url.rstrip('/')}/feed.xml"
        
        # 4. Add to RSS feed
        add_post_to_feed(post_data, rss_file_path, base_url)
        
        title = post_data.get("title", "Untitled")
        await update.message.reply_text(
            f"Successfully added '{title}' to the feed!\n"
            f"Feed URL: {feed_url}"
        )
    except Exception as e:
        await update.message.reply_text(f"An error occurred while processing: {str(e)}")

def main():
    token = os.environ.get("TELEGRAM_BOT_TOKEN")
    if not token:
        print("Error: TELEGRAM_BOT_TOKEN environment variable is not set.")
        return
        
    app = ApplicationBuilder().token(token).build()
    
    app.add_handler(CommandHandler("start", start))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    
    print("Bot is starting...")
    app.run_polling()

if __name__ == "__main__":
    main()
