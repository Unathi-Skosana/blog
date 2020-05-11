#!/usr/bin/env bash

title() {
  echo $(rg "title" -m 1 "$1" | sed -e 's/^[a-z]*:\|\"//g')
}

format_date() {
  dt=$(rg "date" -m 1 "$1" | sed -e 's/^[a-z]*:\|\"//g')
  echo $(date -d "$dt" +%m/%d/%Y)
}

post_link_wrapper() {
# 1 - id
# 2 - title
# 3 - date

  echo -ne "
  <div class=\"p\">
    <div class=\"date\">$3</div>
    <h3 class=\"t\">
      <a href=\"/posts/$1\">$2</a>
    </h3>
  </div>
  "
}

read_time() {
  minu="$(eva -f 1 $1/150 | xargs)"
  echo "$minu"
}

cat > "./build/index.html" << EOF
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta property="og:url" content="https://untitld.now.sh">
    <meta property="og:description" content="Nondescript">
    <meta property="og:type" content="website">
    <meta property="og:title" content="Unathi Skosana">
    <meta name="HandheldFriendly" content="true">
    <meta content="#ffffff" name="theme-color">
    <meta name="viewport" content="initial-scale=1">
    <meta charset="UTF-8">
    <title>Untitld — Home</title>
    <link rel="icon" type="image/x-icon" sizes="128x128" href="/favicon/micro-128.png">
    <link rel="icon" type="image/x-icon" sizes="64x64" href="/favicon/micro-62.png">
    <link rel="icon" type="image/x-icon" sizes="32x32" href="/favicon/micro-32.png">
    <link rel="icon" type="image/x-icon" sizes="16x16" href="/favicon/micro-16.png">
    <link rel="stylesheet" href="/dark.css" media="(prefers-color-scheme: dark)">
    <link rel="stylesheet" href="/light.css" media="(prefers-color-scheme: light), (prefers-color-scheme: no-preference)">
    <link rel="stylesheet" href="/style.css">
    <script type="module" src="https://googlechromelabs.github.io/dark-mode-toggle/src/dark-mode-toggle.mjs"></script>
  </head>
  <body>

    <!-- header !-->
    <header class="nav-header">
      <h1 class="logo">
        <a href="/">
          <img src="/favicon/micro-128.png" width="32" height="32"/>
        </a>
      </h1>

      <ul class="navigation">
        <li><a href="/about/">About</a></li>
        <li><a href="/academia/">Academia</a></li>
        <li><a href="/misc/">Misc</a></li>
        <li><a href="/projects/">Projects</a></li>
        <li>
        <dark-mode-toggle
          id="dark-mode-toggle-1"/>
        </li>
      </ul>
    </header>

    <!-- posts --!>

    <div class="content">
      <div class="posts">
EOF

mkdir -p "./build/posts"
rm -rf "./build/posts/"

# posts
posts=$(find "./content/posts" -mindepth 1 -maxdepth 3 -type f -iname "*.md")
for f in $posts; do

  id=$(basename "${f##*/}" .md)
  stats="$(wc "$f")"
  words="$(echo "$stats" | awk '{print $2}')"
  r_time=$(read_time "$words")
  post_title="$(title "$f")"
  post_date="$(format_date "$f")"
  post_link=$(post_link_wrapper "$id" "$post_title" "$post_date")

  echo -ne $post_link >> "./build/index.html"
  mkdir -p "./build/posts/$id"


  echo "\$ Building post $id ..."
  echo "\$ Copying assets ..."

  posts_assets=$(find "./content/posts/$id" -maxdepth 1 -mindepth 1 -type f ! -iname "*.md")
  for a in $posts_assets;do
    cp $a "./build/posts/$id/"
  done;


  esh -s /bin/bash \
    -o "./build/posts/$id/index.html" \
    "./post.esh" \
    title="$post_title" \
    read_time="$r_time" \
    date="$post_date" \
    file="$f"
done;


# pages
pages=$(find "./content" -mindepth 1 -maxdepth 1 -type f -iname "*.md")
for f in $pages; do
  id=$(basename "${f##*/}" .md)
  page_title="$(title "$f")"

  echo "\$ Building page $id ..."

  mkdir -p "./build/$id"
  esh -s /bin/bash \
    -o "./build/$id/index.html" \
    "./$id.esh" \
    title="$page_title" \
    file="$f"
done;

# building rss feeds
echo "\$ building RSS feeds ..."

esh -s /bin/bash \
    -o "./build/index.xml" \
    "./rss.esh"

cat >> "./build/index.html" << EOF
        <footer>
          <div class="separator"></div>
          <a href="https://github.com/Unathi-Skosana">Github</a>
          <a href="https://twitter.com/UnathiSkosana">Twitter</a>
          <a href="mailto:ukskosana@gmail.com">Mail</a>
          <a href="mailto:ukskosana@gmail.com">RSS</a>
          <a href="https://creativecommons.org/licenses/by-nc-sa/4.0/">
            <img class="cc" src="https://d33wubrfki0l68.cloudfront.net/94387e9d77fbc8b4360db81e72603ecba3df94a7/632bc/static/cc.svg">
          </a>
        </footer>
      </div>
    </div>
  </body>
</html>
EOF
