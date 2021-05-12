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
    FILENAME="$2/$1.md"
    echo $FILENAME
    mkdir -p $2 
    touch $FILENAME

    #writing scaffold
    echo "" >> $FILENAME
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
      FILENAME="$dir/$1.md"
      mkdir -p $dir 
      touch $FILENAME

      #writing scaffold
      echo "" >> $FILENAME
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
  file_name="quicknote_$(date +"%Y-%m-%d")"
  nn $file_name
)

wn()(
  day=$(echo "Mon\nTue\nWed\nThu\nFri\nSat\nSun\n" | fzf --cycle --ansi)
  file_name="weekly_$(date -v +$day +"%Y-%m-%d")"
  nn $file_name
)

# global note location
export NOTE_DIR='/Users/florianj/Private/vim-simplenote/content'

