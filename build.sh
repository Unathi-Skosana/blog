#!/usr/bin/env bash

function title {
  # $1 - file
  # Extracts title from file metadata
  printf '%s' "$(rg "title" -m 1 "$1" | sed -e 's/^[a-z]*:\|\"//g' | xargs)"
}

function description {
  # $1 - file
  # Extracts description from file metadata
  printf '%s' "$(rg "description" -m 1 "$1" | sed -e 's/^[a-z]*:\|\"//g' | xargs)"
}

function format_date {
  # $1 - date
  printf '%s' "$(date -d "$1" +%m/%d/%Y)"
}

function read_time {
  # $1 - number of words (assumption : 200 words per min)

  # Rounded to nearest half
  printf '%s' "$(awk "BEGIN {printf \"%.1f\", int("$1"/100)/2}")"
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
      <div class='date'>— $4 Min</div>
    </div>
    <h3 class='t'>
      <a href='/posts/$1' title='$2'>$2</a>
    </h3>
  </div>
  "
}

function header {
  # 1 - page title
  # 2 - page description

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
    <script type=\"text/javascript\">
      document.addEventListener('DOMContentLoaded', function() {
        var path = location.pathname.split('/')[1]
        var el = document.querySelector('header ul li a[href=\'/' + path +
        '/\']');
        el.classList.add('active');
      });
    </script>
    <meta charset='UTF-8'>
    <meta name='viewport' content='initial-scale=1'>
    <meta content='#ffffff' name='theme-color'>
    <meta name='HandheldFriendly' content='true'>
    <meta property='og:title' content='$1'>
    <meta property='og:description' content='$2'>
    <meta property='og:url' content='https://untitld.xyz'>
    <meta property='og:type' content='website'>
    <meta property='og:image' content='/static/favicon/micro-128.png'>

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
        <a href='/'  aria-label='mu'>
          <img src='/static/favicon/micro-128.png' width='32' height='32' alt='mu' />
        </a>
      </h1>
      <ul class='navigation'>
        <li><a href='/about/' title='about me'>About</a></li>
        <li><a href='/projects/' title='side quests'>Projects</a></li>
        <li><a href='/academia/' title='academia'>Academia</a></li>
        <li><a href='/misc/' title='miscellaneous'>Misc</a></li>
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

function pagination {
  # $1 - prev
  # $2 - next
  # $3 - state ~ dev/prod

  if [ "$3" = "--prod" ]; then
    draft=$(rg "draft" -m 1 "$1" | sed -e 's/^[a-z]*:\|\"//g' | xargs)
    if [ "$draft" = "true" ]; then
      unset $1
    fi
  fi

  if [ "$3" = "--prod" ]; then
    draft=$(rg "draft" -m 1 "$2" | sed -e 's/^[a-z]*:\|\"//g' | xargs)
    if [ "$draft" = "true" ]; then
      unset $2
    fi
  fi

  printf '%s\n' "<div class='pagination'>"

  if  [[ ! -z "$1" ]]
  then
    prev_link=$(basename "${1##*/}" .md)
    prev_title=$(title "$1")
    printf '%s\n' "<a href='/posts/$prev_link' title='$prev_title'>
      <span>Prev</span>
      <span>$prev_title</span>
    </a>"
  fi

  if  [[ ! -z "$2" ]]
  then
    next_link=$(basename "${2##*/}" .md)
    next_title=$(title "$2")
    printf '%s\n' "<a href='/posts/$next_link' title='$next_title'>
      <span>Next</span>
      <span>$next_title</span>
    </a>"
  fi

  printf '%s\n' "</div>"

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
      <div class='m'>
        <em>$3</em>
        <span>|</span>
        <em>$2 minute read</em>
      </div>
      <div class='c'>
        $(pandoc --katex --quiet -t html --highlight-style monochrome $4)
      </div>
    </div>
  </div>
  "
}

function footer {
  printf '%s\n' "
  <footer>
    <hr/>
    <div class='social'>
      <a href='https://github.com/Unathi-Skosana' aria-label='github'
      title='github'>
        <img src='/static/images/github.svg' />
      </a>
      <a href='https://twitter.com/_DeLicht' aria-label='twitter'
      title='twitter'>
        <img src='/static/images/twitter.svg' />
      </a>
      <a href='mailto:ukskosana@gmail.com' aria-label='mail' title='mail'>
        <img src='/static/images/mail.svg' />
      </a>
      <a href='https://untitld.xyz/index.xml' aria-label='rss' title='rss'>
        <img src='/static/images/rss.svg' />
      </a>
    </div>
  </footer>
  "
}

function rss {
  posts=$(find "./content/posts" -mindepth 1 -maxdepth 3 -type f -iname "*.md")
  items=""
  for f in $posts; do

    if [ "$1" = "--prod" ]; then
      draft=$(rg "draft" -m 1 "$f" | sed -e 's/^[a-z]*:\|\"//g' | xargs)
      if [ "$draft" = "true" ]; then
        printf '%s\n' "\$ Skipping draft post $f..."
        continue
      fi
    fi

    id="$(basename "${f##*/}" ".md")"
    post_title="$(rg "title" -m 1 "$f" | sed -e "s/^[a-z]*:\|\'//g" | xargs)"
    dt="$(rg "date" -m 1 "$f" | sed -e "s/^[a-z]*:\|\'//g" | xargs)"
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

#rm -rf "./build/static"
#rm -rf "./build/posts/"
#mkdir -p "./build/posts"
#mkdir -p "./build/static"

cp -r "./static" "./build"

# posts
mapfile -d $'\0' posts < <(find "./content/posts" -mindepth 1 -maxdepth 3 -type f -iname "*.md" -print0)
for (( i = 0; i < ${#posts[*]}; ++i )); do
  f=${posts[$i]}
  next=${posts[$i+1]}
  prev=${posts[$i-1]}

  if [ "$1" = "--prod" ]; then
    draft=$(rg "draft" -m 1 "$f" | sed -e 's/^[a-z]*:\|\"//g' | xargs)
    if [ "$draft" = "true" ]; then
      printf '%s\n' "\$ Skipping draft post $f..."
      continue
    fi
  fi

  id=$(basename "${f##*/}" .md)
  stats=$(wc "$f")
  words=$(printf '%s\n' "$stats" | awk '{print $2}')
  r_time=$(read_time "$words")
  post_title=$(title "$f")
  post_description=$(description "$f")
  dt=$(rg "date" -m 1 "$f" | sed -e 's/^[a-z]*:\|\"//g' | xargs)
  post_date=$(format_date "$dt")
  post_link=$(post_link_wrapper "$id" "$post_title" "$post_date" "$r_time")

  printf '%s\n' "$post_link" >> "./build/index.html"

  mkdir -p "./build/posts/$id"

  printf '%s\n' "\$ Building post $id ..."

  printf '%s\n' "$(header "$post_title" "$post_description")" > "./build/posts/$id/index.html"

  printf '%s\n' "$(post "$post_title" "$r_time" "$post_date" "$f")" >> "./build/posts/$id/index.html"

  printf '%s\n' "$(pagination "$prev" "$next" "$1")" >> "./build/posts/$id/index.html"

  printf '%s\n' "$(footer)" >> "./build/posts/$id/index.html"

  printf '%s\n' "
    </body>
  </html>" >> "./build/posts/$id/index.html"
done;


# pages
pages=$(find "./content" -mindepth 1 -maxdepth 1 -type f -iname "*.md")
for f in $pages; do
  id=$(basename "${f##*/}" .md)
  page_title=$(title "$f")
  page_description=$(description "$f")

  printf '%s\n' "\$ Building page $id ..."

  mkdir -p "./build/$id"

  printf '%s\n' "$(header "$page_title" "$page_description")" > "./build/$id/index.html"

  printf '%s\n' "$($id "$f")" >> "./build/$id/index.html"

  printf '%s\n' "$(footer)" >> "./build/$id/index.html"

  printf '%s\n' "
    </body>
  </html>" >> "./build/$id/index.html"
done;

# close off home page
printf '%s\n' "</div>" >> "./build/index.html"
printf '%s\n' "$(footer)" >> "./build/index.html"

printf '%s\n' "
    </div>
  </body>
</html>" >> "./build/index.html"


# building rss feeds
printf '%s\n' "\$ building RSS feeds ..."
printf '%s\n' "$(rss)" > "./build/index.xml"
