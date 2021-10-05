#!/bin/zsh

# find note by name
fn() (
  cd $NOTE_DIR
  
  IFS=$'\n' out=("$(fzf-tmux --query="$1" --exit-0)")
  key=$(head -1 <<<"$out")
  file=$(head -2 <<<"$out" | tail -1)
  if [ -n "$file" ]; then
    ${EDITOR:-vim} "$file"
  fi

  # navigate back to previous folder
  cd -
)

# browse notes with ranger
rn() (
  cd $NOTE_DIR
  ranger
)

# find string in all notes
fin() {
  cd $NOTE_DIR

  RG_PREFIX="rga --files-with-matches"
  local file
  file="$(
    FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
      fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 25 {q} {}" \
      --phony -q "$1" \
      --bind "change:reload:$RG_PREFIX {q}" \
      --preview-window="70%:wrap"
  )" 
  if [ -n "$file" ]; then
    ${EDITOR:-vim} "$file"
  fi

  # navigate back to previous folder
  cd -
}

# create new note
nn()(
  # help message
  if [ $# -lt 1 ]; then
    echo -e "\nUsage:\n$0 [filename tag] \n"
    exit 1
  fi

  cd $NOTE_DIR

  if ! [ -z "$2" ]
  then
    echo "Creating note $1 with tag #$2."
    FILENAME="$2/$(date +"%Y-%m-%d")_$1.txt"
    echo $FILENAME
    mkdir -p $2 
    touch $FILENAME

    #writing scaffold
    echo "# vim: syntax=markdown" >> $FILENAME
    echo "" >> $FILENAME
    echo "---" >> $FILENAME
    echo "title: $1" >> $FILENAME
    echo "date: $(date +"%d.%m.%Y")" >> $FILENAME
    echo "tag: #$2" >> $FILENAME
    echo "---" >> $FILENAME
    echo "" >> $FILENAME
    echo "" >> $FILENAME

    # open note
    ${EDITOR:-vim} "$file"
  else
  cd $NOTE_DIR
    local dir
    dir=$(find . -path '*/\.*' -prune -o -type d -print 2>/dev/null | fzf +m)
    if [ -z "$dir" ]
    then
      echo "Tag not found. Either provide a valid tag or specify new tag directly."
      echo -e "\nUsage:\n$0 [filename tag] \n"
      exit 1
    else
      echo "Creating note $1 with tag #$dir."
      FILENAME="$dir/$(date +"%Y-%m-%d")_$1.txt"
      mkdir -p $dir 
      touch $FILENAME

      #writing scaffold
      echo "# vim: syntax=markdown" >> $FILENAME
      echo "" >> $FILENAME
      echo "---" >> $FILENAME
      echo "title: $1" >> $FILENAME
      echo "date: $(date +"%d.%m.%Y")" >> $FILENAME
      echo "tag: #$(echo $dir | cut -d '/' -f 2)" >> $FILENAME
      echo "---" >> $FILENAME
      echo "" >> $FILENAME
      echo "" >> $FILENAME

      # open note
      if [ -n "$FILENAME" ]; then
        ${EDITOR:-vim} "$FILENAME"
      fi
    fi
  fi
  
  # navigate back to previous folder
  cd -
)

qn()(
  file_name="$(date +"%Y-%m-%d")_quicknote"
  nn $file_name
)

wn()(
  day=$(echo "Mon\nTue\nWed\nThu\nFri\nSat\nSun\n" | fzf --cycle --ansi)
  file_name="_weekly"
  nn $file_name
)

nd()(
  file_name="$(date +"%Y-%m-%d")_decision"
  
  cd $NOTE_DIR
  local dir
  dir=$(find . -path '*/\.*' -prune -o -type d -print 2>/dev/null | fzf +m)
  if [ -z "$dir" ]
  then
    echo "Tag not found. Either provide a valid tag or specify new tag directly."
    echo -e "\nUsage:\n$0 [filename tag] \n"
    exit 1
  else
    echo "Creating decision journal node $1 with tag #$dir."
    FILENAME="$dir/$file_name.txt"
    mkdir -p $dir 
    touch $FILENAME

    #writing scaffold
    echo "# vim: syntax=markdown" >> $FILENAME
    echo "" >> $FILENAME
    echo "---" >> $FILENAME
    echo "title: $1" >> $FILENAME
    echo "date: $(date +"%d.%m.%Y")" >> $FILENAME
    echo "tag: #$(echo $dir | cut -d '/' -f 2)" >> $FILENAME
    echo "---" >> $FILENAME
    echo "" >> $FILENAME
    echo "" >> $FILENAME
    echo "# Mental/Physical State" >> $FILENAME
    echo "" >> $FILENAME
    echo "Energized | Focused | Relaxed | Confident | Tired | Accepting | Accomodating | Anxious | Resigned | Frustrated | Angry" >> $FILENAME
    echo "" >> $FILENAME
    echo "# The situation / Context" >> $FILENAME
    echo "" >> $FILENAME
    echo "# The problem statement or frame" >> $FILENAME
    echo "" >> $FILENAME
    echo "# The variables that govern the situation include" >> $FILENAME
    echo "" >> $FILENAME
    echo "# The complications/complexities as I see them" >> $FILENAME
    echo "" >> $FILENAME
    echo "# Alternatives that were seriously considered and not chosen were" >> $FILENAME
    echo "" >> $FILENAME
    echo "# Explain the range of outcomes" >> $FILENAME
    echo "" >> $FILENAME
    echo "# What I expect to happen and the actual probabilities are" >> $FILENAME
    echo "" >> $FILENAME
    echo "# The outcome" >> $FILENAME
    echo "" >> $FILENAME
    echo "# Review Date" >> $FILENAME
    echo "" >> $FILENAME
    echo "- $(date -v +6m 2> /dev/null) (6 months after decision date)" >> $FILENAME
    echo "" >> $FILENAME
    echo "# What happened and what I learned" >> $FILENAME
    echo "" >> $FILENAME
    echo "# review DONE?" >> $FILENAME
    echo "" >> $FILENAME
    echo "FALSE" >> $FILENAME

    # open note
    if [ -n "$FILENAME" ]; then
      ${EDITOR:-vim} "$FILENAME"
    fi
  fi
  
  # navigate back to previous folder
  cd -
)

# global note location
export NOTE_DIR='~/Private/vim-simplenote/content'

