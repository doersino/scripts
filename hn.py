# Lists posts matching a search term (e.g. "ask hn") among the 500 most recent
# Hacker News submissions in chronological order (i.e. newest last; since your
# terminal probably scrolls along with this script's output).

import argparse
import requests
import json
import concurrent.futures
import datetime

# https://stackoverflow.com/questions/4842424/list-of-ansi-color-escape-sequences
ERROR = "\033[31m"
SUCCESS = "\033[32m"
META = "\033[37m"
LINK = "\033[4;34m"  # cmd + double click to open in macos terminal
OFF = "\033[0m"

def load_new(n=500):
    # https://github.com/HackerNews/API
    ids = requests.get("https://hacker-news.firebaseio.com/v0/newstories.json").json()
    return ids[:n]

def load_post(id):
    details = requests.get(f"https://hacker-news.firebaseio.com/v0/item/{id}.json", timeout=10).json()
    return details

def load_posts(ids):
    ret = []

    # https://docs.python.org/dev/library/concurrent.futures.html#threadpoolexecutor-example
    threads = min(50, len(ids))
    with concurrent.futures.ThreadPoolExecutor(max_workers=threads) as executor:
        posts = {executor.submit(load_post, id): id for id in ids}
        for future in concurrent.futures.as_completed(posts):
            id = posts[future]
            try:
                post = future.result()
            except Exception as e:
                print(ERROR + "!", end="", flush=True)
            else:
                if post is not None:
                    print(SUCCESS + ".", end="", flush=True)
                    ret.append(post)
                else:
                    print(ERROR + "!", end="", flush=True)

    print(OFF)
    return ret

def sort_posts(posts, reverse=False):
    return sorted(posts, key=lambda post: post["time"], reverse=not reverse)

def filter_posts(posts, search=""):
    return [post for post in posts if search.lower() in post["title"].lower()]

def limit_posts(posts, limit=-1):
    return posts[:limit]

def pretty_post(post):
    ago = datetime.datetime.now() - datetime.datetime.fromtimestamp(post["time"])
    hours, minutes = map(int, str(ago).split(":")[:2])
    ago = ""
    if hours != 0:
        s = "" if hours == 1 else "s"
        ago = f"{hours} hour{s} "
    s = "" if minutes == 1 else "s"
    ago += f"{minutes} minute{s} ago"

    comments = post["descendants"]
    s = "" if comments == 1 else "s"
    comments = f"{comments} comment{s} "

    hot_if_at_least_n_comments = 3
    hot_if_n_comments_per_hour = 0.5
    superhot_if_n_comments_per_hour = 7
    hyperdyperhot_if_n_comments_per_hour = 16
    hot = ""
    fractional_hours = 60.0 / (60 * hours + minutes + 0.1)  # + 0.1 to prevent division by zero on very new posts
    if post["descendants"] >= hot_if_at_least_n_comments and post["descendants"] >= hot_if_n_comments_per_hour / fractional_hours:
        if post["descendants"] >= superhot_if_n_comments_per_hour / fractional_hours:
            hot += "🔥"
        if post["descendants"] >= hyperdyperhot_if_n_comments_per_hour / fractional_hours:
            hot += "🔥"
        hot += "🔥 "

    print()
    print(f"{hot}{META}{ago} 〜 {comments}{OFF}")
    print(post["title"])
    print(f"{LINK}https://news.ycombinator.com/item?id={post['id']}{OFF}")
    #print(post)

def pretty_posts(posts):
    for post in posts:
        pretty_post(post)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("search", type=str, help="string to filter posts by, e.g. 'ask hn' (case-insensitive)")
    parser.add_argument("-n", "--number", type=int, default=500, help="maximum number of posts to fetch (<= 500)")
    parser.add_argument("-l", "--limit", type=int, default=500, help="limit of number of posts to print")
    args = parser.parse_args()
    #print(args)

    ids = load_new(args.number)
    posts = load_posts(ids)
    posts = sort_posts(posts, reverse=True)
    posts = filter_posts(posts, args.search)
    posts = limit_posts(posts, args.limit)

    pretty_posts(posts)

main()
