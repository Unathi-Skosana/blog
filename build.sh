#!/usr/bin/env bash

function optimize {
  find "./build/static/" -type f \
      \( -name '*.png' -or -name '*.jpg' -or -name '*.jpeg' \) \
      -exec echo {} \; \
      -exec convert -auto-orient {} {}.webp \; \
      -exec rm {} \; \
      -exec sh -c "echo {}.webp | sed 's/\.[^.]*\.[^.]*$/.webp/' | xargs mv {}.webp" \; \

  find "./build/static/" -type f \
      -name "*.css" ! -name "*.min.*" \
      -exec echo {} \; \
      -exec uglifycss --output {}.min {} \; \
      -exec rm {} \; \
      -exec mv {}.min {} \;
}

function getposts {
  rg -m 1 -N "date: " ./content/posts | sed 's/:date://g' | \
    awk '{print $2","$3","$1}' | sort -n | awk -F ',' '{printf "%s\0",$3}'
}

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
    <h2 class='t'>
      <a href='/posts/$1' title='$2'>$2</a>
    </h2>
  </div>
  "
}

function header {
  # 1 - page title
  # 2 - page description
  # 3 - katex switch
  # 4 - syntax switch

  katex_assets=""
  syntax_assets=""
  if [ "$3" -eq "1" ]; then
    katex_assets=$(printf '%s\n'  "
    <! --- katex --->
      <link rel='stylesheet' href='https://cdn.jsdelivr.net/npm/katex@0.12.0/dist/katex.min.css'>
      <script defer src='https://cdn.jsdelivr.net/npm/katex@0.12.0/dist/katex.min.js'></script>
      <script defer src='https://cdn.jsdelivr.net/npm/webfontloader@1.6.28/webfontloader.js'></script>
      <script>
        document.addEventListener('DOMContentLoaded', function () {
          var mathElements = document.getElementsByClassName('math');
          for (var i = 0; i < mathElements.length; i++) {
            var texText = mathElements[i].firstChild;
            if (mathElements[i].tagName == 'SPAN') {
              katex.render(texText.data, mathElements[i], {
                displayMode: mathElements[i].classList.contains('display'),
                throwOnError: false,
                fleqn: false
            });
          }
        }});
        window.WebFontConfig = {
          custom: {
            families: ['KaTeX_AMS', 'KaTeX_Caligraphic:n4,n7', 'KaTeX_Fraktur:n4,n7',
              'KaTeX_Main:n4,n7,i4,i7', 'KaTeX_Math:i4,i7', 'KaTeX_Script',
              'KaTeX_SansSerif:n4,n7,i4', 'KaTeX_Size1', 'KaTeX_Size2', 'KaTeX_Size3',
              'KaTeX_Size4', 'KaTeX_Typewriter'],
          },
        };
      </script>
      "
    )
  fi

  if [ "$4" -eq "1" ]; then
    syntax_assets=$(printf '%s\n' "<link rel='stylesheet' href='/static/css/syntax.css'>")
  fi

  printf '%s\n' "
  <!DOCTYPE html>
  <html lang='en'>
    <head>
      <!--- dark/light mode switch --->

      <script type='module' src='https://googlechromelabs.github.io/dark-mode-toggle/src/dark-mode-toggle.mjs'></script>

      <!--- highlight current nav item --->

      <script>
        // top navigation
        document.addEventListener('DOMContentLoaded', function() {
          var path = location.pathname.split('/')[1]
          var el = document.querySelector('header ul li a[href=\'/' + path +
          '/\']');
          if (el) el.classList.add('active');



          // table of content navigation
          const observer = new IntersectionObserver(entries => {
              entries.forEach(entry => {
                const id = entry.target.getAttribute('id');
                var el = document.querySelector('nav li a[href=\'\#' + id + '\']')
                if (entry.intersectionRatio > 0) {
                  if (el) el.parentElement.classList.add('active');
                } else {
                  if (el) el.parentElement.classList.remove('active');
                }
              });
            });

            // Track all sections that have an `id` applied
            document.querySelectorAll('section[id]').forEach((section) => {
              observer.observe(section);
            });
        });
      </script>

      <!--- Global site tag (gtag.js) - Google Analytics --->

      <script async src='https://www.googletagmanager.com/gtag/js?id=UA-167451864-1'></script>
      <script>
        window.dataLayer = window.dataLayer || [];
        function gtag(){dataLayer.push(arguments);}
        gtag('js', new Date());
        gtag('config', 'UA-167451864-1');
      </script>

      $katex_assets

      <!--- meta --->

      <meta charset='UTF-8'>
      <meta name='viewport' content='initial-scale=1'>
      <meta content='#ffffff' name='theme-color'>
      <meta name='HandheldFriendly' content='true'>
      <meta property='og:title' content='$1'>
      <meta property='og:description' content='$2'>
      <meta property='og:url' content='https://untitld.xyz'>
      <meta property='og:type' content='website'>
      <meta property='og:image' content='/static/favicon/micro-128.png'>

      <!--- favicon --->

      <link rel='icon' type='image/x-icon' sizes='16x16' href='/static/favicon/micro-16.png'>
      <link rel='icon' type='image/x-icon' sizes='32x32' href='/static/favicon/micro-32.png'>
      <link rel='icon' type='image/x-icon' sizes='64x64' href='/static/favicon/micro-62.png'>
      <link rel='icon' type='image/x-icon' sizes='128x128' href='/static/favicon/micro-128.png'>

      <!--- user styles --->

      <link rel='stylesheet' href='/static/css/style.css'>
      <link rel='stylesheet' href='/static/css/light.css' media='(prefers-color-scheme: light), (prefers-color-scheme: no-preference)'>
      <link rel='stylesheet' href='/static/css/dark.css' media='(prefers-color-scheme: dark)'>
      $syntax_assets

    <title>Untitld — $1</title>

    </head>
    <body>
      <a id='banner' title='stop gbv' target='_blank' rel='noopener noreferrer' href='https://twitter.com/ZoLekkaa/status/1298705551497535488?s=20'>
      No more silence. End the genocide against women and LGBTQI+.</a>
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
          $(pandoc --quiet -t html $1)
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
    $(pandoc --quiet -t html $1)
    </div>
  </div>
  "
}


function misc {
  # $1 - file

  printf '%s\n' "
  <div class='content'>
    <div class='misc'>
    $(pandoc --quiet -t html $1)
    </div>
  </div>
  "
}

function projects {
  # $1 - file

  printf '%s\n' "
  <div class='content'>
    <div class='pro'>
    $(pandoc --quiet -t html $1)
    </div>
  </div>
  "
}

function photos {
  # $1 - file

  col1=$(find "static/images/photos/column1/" -mindepth 1 -maxdepth 1 -type f)
  col2=$(find "static/images/photos/column2/" -mindepth 1 -maxdepth 1 -type f)
  col3=$(find "static/images/photos/column3/" -mindepth 1 -maxdepth 1 -type f)


  c1=""
  for p in $col1; do
    c1+="$(printf '%s\n' "
    <img src='/$p' style='width:100%'/>
  ")"
  done;

  c2=""
  for p in $col2; do
    c2+="$(printf '%s\n' "
    <img src='/$p' style='width:100%'/>
  ")"
  done;

  c3=""
  for p in $col3; do
    c3+="$(printf '%s\n' "
      <img src='/$p' style='width:100%'/>
    ")"
  done;


  printf '%s\n' "
  <div class='misc'>
    <h2>Gallery</h2>
  </div>
  <p>...under constuction...</p>
  <br/>
  <div class='row'>
    <div class='column'>$c1</div>
    <div class='column'>$c2</div>
    <div class='column'>$c3</div>
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
      set -- "" $2
    fi

    draft=$(rg "draft" -m 1 "$2" | sed -e 's/^[a-z]*:\|\"//g' | xargs)
    if [ "$draft" = "true" ]; then
      set -- $1 ""
    fi
  fi

  printf '%s\n' "<div class='pagination'>"

  if  [[ ! -z $1 ]];
  then
    prev_link=$(basename "${1##*/}" .md)
    prev_title=$(title "$1")
    printf '%s\n' "<a href='/posts/$prev_link' title='$prev_title'>
      <span>Prev</span>
      <span>$prev_title</span>
    </a>"
  fi

  if  [[ ! -z $2 ]];
  then
    next_link=$(basename "${2##*/}" .md)
    next_title=$(title "$2")
    printf '%s\n' "<a href='/posts/$next_link' title='$next_title' style='margin-left:auto;'>
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

  toc=""
  flag=$(rg "toc" -m 1 "$4" | sed -e 's/^[a-z]*:\|\"//g' | xargs)
  if [ "$flag" = "true" ]; then
    toc="$(pandoc --toc --quiet -t html --template=static/templates/toc.html $4)"
  fi

  printf '%s\n' "
  <div class='content'>
    $toc
    <div class='s p'>
      <h1>$1</h1>
      <div class='m'>
        <em>$3</em>
        <span>|</span>
        <em>$2 minute read</em>
      </div>
      <div class='c'>
        $(pandoc --katex --quiet --section-divs -t html $4)
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
          title='github' target='_blank' rel='noopener noreferrer'>
          <img src='/static/images/github.svg' />
      </a>
      <a href='https://twitter.com/_DeLicht' aria-label='twitter'
          title='twitter' target='_blank' rel='noopener noreferrer'>
          <img src='/static/images/twitter.svg' />
      </a>
      <a href='mailto:ukskosana@gmail.com' aria-label='mail' title='mail'
        target='_blank' rel='noopener noreferrer'>
        <img src='/static/images/mail.svg' />
      </a>
      <a href='https://untitld.xyz/index.xml' aria-label='rss' title='rss'
        target='_blank' rel='noopener noreferrer'>
        <img src='/static/images/rss.svg' />
      </a>
    </div>
  </footer>
  "
}

#################################
########                #########
########    BUILD       #########
########                #########
#################################

# header and container div for post links
printf '%s\n' "
  $(header "Home" "Homepage" 0 0)
  <!-- posts --!>
  <div class='content'>
    <div class='posts'>
" > "./build/index.html"

if [ "$1" = "--prod" ]; then
  cp -r "./static" "./build" && optimize
else
  cp -r "./static" "./build"
fi;

# iterate over posts
mapfile -d $'\0' posts < <(getposts)
for (( i = 0; i < ${#posts[*]}; ++i )); do
  f=${posts[$i]}
  next=${posts[$i+1]}
  prev=${posts[$i-1]}

  # prevent left-wrapping
  if [ "$i" -eq "0" ]; then
    unset prev
  fi

  # skip draft posts in production
  if [ "$1" = "--prod" ]; then
    draft=$(rg "draft" -m 1 "$f" | sed -e 's/^[a-z]*:\|\"//g' | xargs)
    if [ "$draft" = "true" ]; then
      printf '%s\n' "\$ Skipping draft post $f..."
      continue
    fi
  fi

  # some useful vars
  id=$(basename "${f##*/}" .md)
  stats=$(wc "$f")
  words=$(printf '%s\n' "$stats" | awk '{print $2}')
  r_time=$(read_time "$words")
  post_title=$(title "$f")
  post_description=$(description "$f")
  dt=$(rg "date" -m 1 "$f" | sed -e 's/^[a-z]*:\|\"//g' | xargs)
  post_date=$(format_date "$dt")
  post_link=$(post_link_wrapper "$id" "$post_title" "$post_date" "$r_time")

  # post links for home page
  printf '%s\n' "$post_link" >> "./build/index.html"

  # build posts
  mkdir -p "./build/posts/$id"

  printf '%s\n' "\$ Building post $id ..."

  printf '%s\n' "
      $(header "$post_title" "$post_description" 1 1)
      $(post "$post_title" "$r_time" "$post_date" "$f")
      $(pagination "$prev" "$next" "$1")
      $(footer)
    </body>
  </html>" > "./build/posts/$id/index.html"

  # use webp in production in place for png/jpg/jpg
  if [ "$1" = "--prod" ]; then
    sed -i 's/\(png\|jpg\|jpeg\)/webp/g' "./build/posts/$id/index.html"
  fi
done;


# build other pages

pages=$(find "./content" -mindepth 1 -maxdepth 1 -type f -iname "*.md")
for f in $pages; do
  id=$(basename "${f##*/}" .md)
  page_title=$(title "$f")
  page_description=$(description "$f")

  printf '%s\n' "\$ Building page $id ..."

  mkdir -p "./build/$id"

  printf '%s\n' "
      $(header "$page_title" "$page_description" 0 0)
      $($id "$f")
      $(footer)
    </body>
  </html>" > "./build/$id/index.html"


  # use webp in production in place for png/jpg/jpg
  if [ "$1" = "--prod" ]; then
    sed -i 's/\(png\|jpg\|jpeg\)/webp/g' "./build/$id/index.html"
  fi
done;

# close off home page
printf '%s\n' "
    </div>
    $(footer)
    </div>
  </body>
</html>" >> "./build/index.html"


if [ "$1" = "--prod" ]; then
  sed -i 's/\(png\|jpg\|jpeg\)/webp/g' "./build/index.html"
fi


printf '%s\n' "\$ building error page ..."

printf '%s\n' "
  <!DOCTYPE html>
  <html lang='en'>
    <head>
      <!--- Global site tag (gtag.js) - Google Analytics --->

      <script async src='https://www.googletagmanager.com/gtag/js?id=UA-167451864-1'></script>
      <script>
        window.dataLayer = window.dataLayer || [];
        function gtag(){dataLayer.push(arguments);}
        gtag('js', new Date());
        gtag('config', 'UA-167451864-1');
      </script>

      <!--- meta --->

      <meta charset='UTF-8'>
      <meta name='viewport' content='initial-scale=1'>
      <meta content='#ffffff' name='theme-color'>
      <meta name='HandheldFriendly' content='true'>
      <meta property='og:title' content='$1'>
      <meta property='og:description' content='$2'>
      <meta property='og:url' content='https://untitld.xyz'>
      <meta property='og:type' content='website'>
      <meta property='og:image' content='/static/favicon/micro-128.png'>

      <!--- favicon --->

      <link rel='icon' type='image/x-icon' sizes='16x16' href='/static/favicon/micro-16.png'>
      <link rel='icon' type='image/x-icon' sizes='32x32' href='/static/favicon/micro-32.png'>
      <link rel='icon' type='image/x-icon' sizes='64x64' href='/static/favicon/micro-62.png'>
      <link rel='icon' type='image/x-icon' sizes='128x128' href='/static/favicon/micro-128.png'>

      <!--- user styles --->

      <link rel='stylesheet' href='/static/css/style.css'>

      <title>Untitld — 404</title>

    </head>
    <body>
    <div class='error'>
      <img src='/static/images/error.svg' alt='404' title='Page not found' />
    </div>
  </body>
  </html>
" > "./build/other-404.html"

# building RSS feed
printf '%s\n' "\$ building RSS feeds ..."

for (( i = 0; i < ${#posts[*]}; ++i )); do
  f=${posts[$i]}

  if [ "$1" = "--prod" ]; then
    draft=$(rg "draft" -m 1 "$f" | sed -e 's/^[a-z]*:\|\"//g' | xargs)
    if [ "$draft" = "true" ]; then
      printf '%s\n' "\$ Skipping draft post $f..."
      continue
    fi
  fi

  id=$(basename "${f##*/}" .md)
  words=$(printf '%s\n' "$stats" | awk '{print $2}')
  post_title=$(title "$f")
  post_description=$(description "$f")
  dt=$(rg "date" -m 1 "$f" | sed -e 's/^[a-z]*:\|\"//g' | xargs)
  post_date=$(format_date "$dt")
  post_link=$(post_link_wrapper "$id" "$post_title" "$post_date" "$r_time")
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
    <description>$post_description</description>
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
" > "./build/index.xml"


# use webp in production in place for png/jpg/jpg
if [ "$1" = "--prod" ]; then
  sed -i 's/\(png\|jpg\|jpeg\)/webp/g' "./build/index.xml"
fi
