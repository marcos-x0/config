#! /usr/bin/env bash

# TODO: add logic to display tar without bookmark
# must improve this logic
# 1. show bookmark and or tag and no description
# 2. description only appear if bookmark or tag are missing
#

JJ_0="$(jj log -r@ -n1 --ignore-working-copy --no-graph --color always -T '
  separate(" ",
    change_id.shortest(6),
    if(bookmarks, 
      if(tags,
        concat(
          raw_escape_sequence("\x1b[1;34m") ++ " ", raw_escape_sequence("\x1b[0m"),
          bookmarks.join(" | "),
          raw_escape_sequence("\x1b[1;34m") ++ " ", raw_escape_sequence("\x1b[0m"),
          tags.map(|x| if(
            x.name().substr(0, 10).starts_with(x.name()),
            x.name().substr(0, 10),
            x.name().substr(0, 9) ++ "…")
          ).join(" "),
        ),
        concat(
          raw_escape_sequence("\x1b[1;34m") ++ " ", raw_escape_sequence("\x1b[0m"),
          bookmarks.join(" | ")
        )
      ),
  
      concat(
        raw_escape_sequence("\x1b[1;32m") ++ if(empty, "󰟢 "),
        raw_escape_sequence("\x1b[1;32m") ++ if(description.first_line().len() == 0,
          "󰇘",
          if(
            description.first_line().substr(0, 24).starts_with(description.first_line()),
            description.first_line().substr(0, 24),
            description.first_line().substr(0, 23) ++ "…"
          )
        ) ++ raw_escape_sequence("\x1b[0m")
      )
    ),
    
    if(conflict, "conflict"),
    if(divergent, "divergent"),
    if(hidden, "hidden"),
    if(immutable, "immutable"),
  )
')"

# commit_id.shortest(6),

# JJ_OUT="$(jj log -r@ -n1 --no-graph -T '' --stat | tail -n1)"

# JJ_MODIFIED=$(echo "$JJ_OUT" | sed 's; .*;•;')
# JJ_ADDED=$(echo "$JJ_OUT" | sed -e 's; [^(][^(]*(;;' -e 's;),.*;;')
# JJ_REMOVED=$(echo "$JJ_OUT" | sed -e 's;.*(+), ;;' -e 's; [^(][^(]*(;;' -e 's;),.*;;' -e 's;);;')

# JJ_1="$(tput bold)$(tput setaf 242)[$(tput setaf 37)$JJ_MODIFIED $(tput setaf 70)$JJ_ADDED $(tput setaf 9)$JJ_REMOVED$(tput setaf 242)]$(tput sgr0)"
# echo "$JJ_1" "$JJ_0"
echo "$JJ_0"
