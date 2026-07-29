from setuptools import setup, find_packages

setup(
    name="substack-rss",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[
        "python-telegram-bot",
        "feedgen",
        "requests",
        "beautifulsoup4",
        "markdownify",
    ],
    entry_points={
        "console_scripts": [
            "substack-bot=substack_rss.bot:main",
        ],
    },
)
