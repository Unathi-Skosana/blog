#!/usr/bin/env bash

function title {
  # $1 - file
  printf '%s\n' "$(rg "title" -m 1 "$1" | sed -e 's/^[a-z]*:\|\"//g')"
}

function format_date {
  # $1 - date
  printf '%s\n' "$(date -d "$1" +%m/%d/%Y)"
}

function read_time {
  # $1 - number of words (assumption : 200 words per min)
  printf '%s\n' "$(awk "BEGIN {printf \"%.2f\n\", "$1"/200}") Min"
}

function post_link_wrapper {
  # $1 - id
  # $2 - title
  # $3 - date
  # $4 - time

  printf '%s\n' "
  <div class='p'>
    <div class='time'>
      <div class='date'>$3</div>
      <div class='date'>— $4</div>
    </div>
    <h3 class='t'>
      <a href='/posts/$1'>$2</a>
    </h3>
  </div>
  "
}

function header {
  # 1 - page title

  printf '%s\n' "
  <!DOCTYPE html>
  <html lang='en'>
  <head>
    <!-- Global site tag (gtag.js) - Google Analytics -->
    <script async src='https://www.googletagmanager.com/gtag/js?id=UA-167451864-1'></script>
    <script>
      window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());

      gtag('config', 'UA-167451864-1');
    </script>
    <script type='module' src='https://googlechromelabs.github.io/dark-mode-toggle/src/dark-mode-toggle.mjs'></script>
    <script src='https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.11.1/katex.min.js'></script>
    <script>document.addEventListener('DOMContentLoaded', function () {
    var mathElements = document.getElementsByClassName('math');
    for (var i = 0; i < mathElements.length; i++) {
      var texText = mathElements[i].firstChild;
      if (mathElements[i].tagName == 'SPAN') {
      katex.render(texText.data, mathElements[i], {
        displayMode: mathElements[i].classList.contains('display'),
        throwOnError: false,
        fleqn: false
      });
    }}});
    </script>

    <meta charset='UTF-8'>
    <meta name='viewport' content='initial-scale=1'>
    <meta content='#ffffff' name='theme-color'>
    <meta name='HandheldFriendly' content='true'>
    <meta property='og:title' content='Unathi Skosana'>
    <meta property='og:type' content='website'>
    <meta property='og:description' content='Nondescript'>
    <meta property='og:url' content='https://untitld.xyz'>

    <link rel='stylesheet' href='/static/css/syntax.css'>
    <link rel='stylesheet' href='/static/css/style.css'>
    <link rel='stylesheet' href='/static/css/light.css' media='(prefers-color-scheme: light), (prefers-color-scheme: no-preference)'>
    <link rel='stylesheet' href='/static/css/dark.css' media='(prefers-color-scheme: dark)'>
    <link rel='icon' type='image/x-icon' sizes='16x16' href='/static/favicon/micro-16.png'>
    <link rel='icon' type='image/x-icon' sizes='32x32' href='/static/favicon/micro-32.png'>
    <link rel='icon' type='image/x-icon' sizes='64x64' href='/static/favicon/micro-62.png'>
    <link rel='icon' type='image/x-icon' sizes='128x128' href='/static/favicon/micro-128.png'>

    <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.11.1/katex.min.css' />
    <!--[if lt IE 9]>
      <script src='//cdnjs.cloudflare.com/ajax/libs/html5shiv/3.7.3/html5shiv-printshiv.min.js'></script>
    <![endif]-->

    <title>Untitld — $1</title>
  </head>

  <body>
    <header class='nav-header'>
      <h1 class='logo'>
        <a href='/'  aria-label='mu' target='_blank' rel='noopener noreferrer'>
          <img src='/static/favicon/micro-128.png' width='32' height='32' alt='mu' />
        </a>
      </h1>
      <ul class='navigation'>
        <li><a href='/about/'>About</a></li>
        <li><a href='/projects/'>Projects</a></li>
        <li><a href='/academia/'>Academia</a></li>
        <li><a href='/misc/'>Misc</a></li>
        <li>
          <dark-mode-toggle
            id='dark-mode-toggle-1'
            dark='Dark'
            light='Light'
            permanent='true'
            />
        </li>
      </ul>
    </header>
  "
}


function about {
  # $1 - file

  printf '%s\n' "
    <div class='content'>
      <div class='s p'>
        <div class='b'>
          $(pandoc --quiet -t html --highlight-style monochrome $1)
        </div>
      </div>
    </div>
  "
}


function academia {
  # $1 - file

  printf '%s\n' "
  <div class='content'>
    <div class='misc'>
    $(pandoc --quiet -t html --highlight-style monochrome $1)
    </div>
  </div>
  "
}


function misc {
  # $1 - file

  printf '%s\n' "
  <div class='content'>
    <div class='misc'>
    $(pandoc --quiet -t html --highlight-style monochrome $1)
    </div>
  </div>
  "
}

function projects {
  # $1 - file

  printf '%s\n' "
  <div class='content'>
    <div class='pro'>
    $(pandoc --quiet -t html --highlight-style monochrome $1)
    </div>
  </div>
  "
}

function post {
  # $1 - title
  # $2 - read time
  # $3 - date
  # $4 - file

  printf '%s\n' "
  <div class='content'>
    <div class='s p'>
      <h1>$1</h1>
      <div class='b'>
        <div class='time'>
          <span>
            <svg
              width='24'
              height='24'
              viewBox='0 0 24 24'
              fill='none'
              xmlns='http://www.w3.org/2000/svg'
            >
              <path d='M9 7H11V12H16V14H9V7Z' fill='currentColor' />
              <path
                fill-rule='evenodd'
                clip-rule='evenodd'
                d='M22 12C22 17.5228 17.5228 22 12 22C6.47715 22 2 17.5228 2 12C2 6.47715 6.47715 2 12 2C17.5228 2 22 6.47715 22 12ZM20 12C20 16.4183 16.4183 20 12 20C7.58172 20 4 16.4183 4 12C4 7.58172 7.58172 4 12 4C16.4183 4 20 7.58172 20 12Z'
                fill='currentColor'
              />
            </svg>
            $2
          </span>
          <span>
            <svg
              width='24'
              height='24'
              viewBox='0 0 24 24'
              fill='none'
              xmlns='http://www.w3.org/2000/svg'
            >
              <path
                d='M8 9C7.44772 9 7 9.44771 7 10C7 10.5523 7.44772 11 8 11H16C16.5523 11 17 10.5523 17 10C17 9.44771 16.5523 9 16 9H8Z'
                fill='currentColor'
              />
              <path
                fill-rule='evenodd'
                clip-rule='evenodd'
                d='M6 3C4.34315 3 3 4.34315 3 6V18C3 19.6569 4.34315 21 6 21H18C19.6569 21 21 19.6569 21 18V6C21 4.34315 19.6569 3 18 3H6ZM5 18V7H19V18C19 18.5523 18.5523 19 18 19H6C5.44772 19 5 18.5523 5 18Z'
                fill='currentColor'
              />
            </svg>
            $3
        </span>
        </div>
        $(pandoc --katex --quiet -t html --highlight-style monochrome $4)
      </div>
    </div>
  </div>
  "
}

function footer {
  printf '%s\n' "
  <footer>
    <div class='separator'></div>
    <a href='https://github.com/Unathi-Skosana'>Github</a>
    ·
    <a href='https://twitter.com/UnathiSkosana'>Twitter</a>
    ·
    <a href='mailto:ukskosana@gmail.com'>Mail</a>
    ·
    <a href='mailto:ukskosana@gmail.com'>RSS</a>
  </footer>
  "
}

function rss {
  posts=$(find "./content/posts" -mindepth 1 -maxdepth 3 -type f -iname "*.md")
  items=""
  for f in $posts; do
    id="$(basename "${f##*/}" ".md")"
    post_title="$(rg "title" -m 1 "$f" | sed -e "s/^[a-z]*:\|\'//g")"
    dt="$(rg "date" -m 1 "$f" | sed -e "s/^[a-z]*:\|\'//g")"
    post_date="$(format_date "$dt")"
    post_link="http://untitld.xyz/posts/$id/"
    html="$(pandoc -t html "$f")"

    items+="$(printf '%s\n' "
    <item>
      <description>$html</description>
      <link>$post_link</link>
      <pubDate>$post_date</pubDate>
      <guid>$post_link</guid>
    </item>
    ")"
  done


  printf '%s\n' "
  <rss version='2.0' xmlns:atom='http://www.w3.org/2005/Atom'>
    <channel>
      <title>untitld</title>
      <link>http://untitld.xyz</link>
      <description>physics, writing, programming, design</description>
      <atom:link href='http://untitld.xyz/index.xml' rel='self' type='application/rss+xml' />
      <image>
        <title>untitld</title>
        <url>http://untitld.xyz/static/favicon/micro-128.png</url>
        <link>http://untitld.xyz.sh</link>
      </image>
      <language>en-us</language>
      <copyright>Creative Commons BY-NC-SA 4.0</copyright>
      $items
    </channel>
  </rss>
  "
}

printf '%s\n' "$(header Home)"  >  "./build/index.html"

printf '%s\n' "
  <!-- posts --!>
  <div class='content'>
    <div class='posts'>
" >> "./build/index.html"

printf '%s\n' "\$ Purging previously built posts..."

rm -rf "./build/static"
rm -rf "./build/posts/"
mkdir -p "./build/posts"
mkdir -p "./build/static"

cp -r "./static" "./build"

# posts
posts=$(find "./content/posts" -mindepth 1 -maxdepth 3 -type f -iname "*.md")
for f in $posts; do

  id=$(basename "${f##*/}" .md)
  stats=$(wc "$f")
  words=$(printf '%s\n' "$stats" | awk '{print $2}')
  r_time=$(read_time "$words")
  post_title=$(title "$f")
  dt=$(rg "date" -m 1 "$f" | sed -e 's/^[a-z]*:\|\"//g')
  post_date=$(format_date "$dt")
  post_link=$(post_link_wrapper "$id" "$post_title" "$post_date" "$r_time")

  printf '%s\n' "$post_link" >> "./build/index.html"

  mkdir -p "./build/posts/$id"

  printf '%s\n' "\$ Building post $id ..."

  printf '%s\n' "$(header "$post_title")" > "./build/posts/$id/index.html"

  printf '%s\n' "$(post "$post_title" "$r_time" "$post_date" "$f")" >> "./build/posts/$id/index.html"
done;


# pages
pages=$(find "./content" -mindepth 1 -maxdepth 1 -type f -iname "*.md")
for f in $pages; do
  id=$(basename "${f##*/}" .md)
  page_title=$(title "$f")

  printf '%s\n' "\$ Building page $id ..."

  mkdir -p "./build/$id"

  printf '%s\n' "$(header "$page_title")" > "./build/$id/index.html"

  printf '%s\n' "$($id "$f")" >> "./build/$id/index.html"

  printf '%s\n' "$(footer)" >> "./build/$id/index.html"

  printf '%s\n' "
    </body>
  </html>" >> "./build/$id/index.html"
done;

# close off home page
printf '%s\n' "</div>" >> "./build/$id/index.html"
printf '%s\n' "$(footer)" >> "./build/$id/index.html"

printf '%s\n' "
    </div>
  </body>
</html>" >> "./build/index.html"


# building rss feeds
printf '%s\n' "\$ building RSS feeds ..."
printf '%s\n' "$(rss)" > "./build/index.xml"
