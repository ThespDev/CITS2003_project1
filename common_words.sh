#! /usr/bin/env bash

w_flag (){
  highest_name=""
  #arbitrarily high value is used for initial -lt comparison 
  highest_rank=999999999999999
  for file in $1/*.txt
  do
    #sorts words into amount of times used
    #then uses grep with -n to find the line number
    #formatting it with awk and cut 
    rank=$(tr -cs "[a-zA-Z]" '\n' < $file | sort | uniq -c | sort -k 1nr | grep -w -n $2 | awk '{print $1}' | cut -d: -f 1)
    #if the word isn't found and the result is empty, set the rank to the initially large value
    if [[ -z $rank ]]
    then
      rank=999999999999999
    fi
    if [[ $rank -lt $highest_rank ]]
    then
      highest_rank=$rank
      highest_name=$(basename $file)
    fi
  done
  #if the word was not found
  if [[ $highest_rank == 999999999999999 ]]
  then
    echo "The word $2 was not found in any of the files"
    exit 1
  else
    echo "The most significant rank for the word $2 is $highest_rank in the file $highest_name"
  fi
}

nth_flag () {
  for file in $1/*.txt
  do
    #sorted wordlist saved into a file from which the nth common word can be found with head and tail
    tr -cs "[a-zA-Z]" '\n' < $file | sort | uniq -c | sort -k 1nr > tempfile1.txt
    wordFromFile=$(head 'tempfile1.txt' -n $2 | tail -n 1 | awk '{print $2}')
    echo "$wordFromFile" >> tempfile2.txt
  done
  #From the lists of nth common words, finding the most common of them and the times it appears
  wordAndCount=$(sort "tempfile2.txt" | uniq -c | sort -k 1nr | head -n 1)
  nthCount=$(echo $wordAndCount | awk '{print $1}')
  nthWord=$(echo $wordAndCount | awk '{print $2}')
  rm tempfile1.txt tempfile2.txt
  echo "The ${2}th most common word is '$nthWord' across $nthCount files" 

}

#For a blank argument, provide a usage
if [[ ! -n $1 ]]
then
  1>&2 echo "Usage: common_words [-w word | -nth N] <directory of text files>"
  exit 1
fi

if [[ $1 == '-w' ]]
then
  #error for if the directory argument is invalid
  if [[ ! -d $3 ]]
  then
    1>&2 echo "Argument given is not a directory"
    exit 1
  fi
  #calls function with the file as the 1st param and the word as the 2nd
  w_flag $3 $2

elif [[ $1 == '-nth' ]] 
then
  #error for if the directory argument is invalid
  if [[ ! -d $3 ]]
  then
    1>&2 echo "Argument given is not a directory"
    exit 1
  fi

  #calls function with the file as the first param and the word as the 2nd
  nth_flag $3 $2

else
  #if no argument provided: do nth_flag but with a second param of 1
  nth_flag $1 1
fi
  


