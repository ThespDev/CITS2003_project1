#! /usr/bin/env bash

#A second argument of 0 indicates a country, 1 indicates a year
find_data () {
  input=$(python3 title_case.py "$1" | tr -d [' '])
  #clean input is made for display purposes at the very end
  clean_input=$(python3 title_case.py "$1")
  if [[ $2 -eq 0 ]]
  then
    #This process allows me to not worry about invalid inputs being grepped as all the names are squeezed
    #as well as the input above
    sort -k 4 -t, -n "incedenceOfMalaria.csv" | cut -d, -f 1 | tr -d [' '] | grep -w -i -n "$input" | tail -n1 > t1.txt
    lineNum=$(cut -d: -f 1 't1.txt')
    if [[ -z $lineNum ]]
    then
      echo "The year or country you entered is not contained in the data"
      exit 1
    fi
    sort -k 4 -t, -n "incedenceOfMalaria.csv" | head -n $lineNum | tail -n 1 > templine.txt
    rm "t1.txt"
  elif [[ $2 -eq 1 ]]
  then
    sort -k 4 -t, -n "incedenceOfMalaria.csv" | grep -w $1 | tail -n 1 > templine.txt
  fi
  
  incidence=$(tail -n1 "templine.txt" |cut -d, -f4)
  year=$(tail -n1 "templine.txt"|cut -d, -f3)
  country=$(tail -n1 "templine.txt"|cut -d, -f1)
  rm "templine.txt"

  if [[ -z $incidence ]] 
  then
    echo "The year or country you entered is not contained in the data"
    exit 1
  else
    cut "incedenceOfMalaria.csv" -d, -f 4 | grep -n $incidence > hitcount.txt
    loopnum=$(wc -l "hitcount.txt" | cut -d ' ' -f 1)
    #this handles if there are multiple hits
    if [[ $loopnum -gt 1 ]]
    then
      countryarr=()
      yeararr=()
      for i in {1..$loopnum}
      do
        head -n $i hitcount | tail -n 1 > looptemp1.txt
        lineNum=$(cut -d: "looptemp1.txt")
        head "incedenceOfMalaria.csv" -n $lineNum | tail -n 1 > looptemp2.txt
        countryarr+=($(cut "looptemp2.txt" -d, -f 1))
        yeararr+=($(cut "looptemp2.txt" -d, -f 4))
      done
      rm "looptemp1.txt" "looptemp2.txt" "hitcount.txt"
      if [[ $2 -eq 0 ]]
      then
        echo "For the country $clean_input, the years with the highest incidence rate of $incidence per 1,000 were:"
        for i in $yeararr
        do
          echo $i
        done
      elif [[ $2 -eq 1 ]]
      then
        echo "For the year $clean_input, the countries with the highest incidence rate of $incidence per 1,000 were:"
        for i in $countryarr
        do
          echo $i
        done
      else
        rm "hitcount.txt" 
        if [[ $2 -eq 0 ]]
        then
          echo "For the country $clean_input, the year with the highest incidence was $year, with a rate of $incidence per 1,000"
        else
          echo "For the year $clean_input, the country with the highest incidence was $country, with a rate of $incidence per 1,000"
        fi  
      fi
    fi
    if [[ $2 -eq 0 ]]
    then
      echo "For the country $clean_input, the year with the highest incidence was $year, with a rate of $incidence per 1,000"
    else
      echo "For the year $clean_input, the country with the highest incidence was $country, with a rate of $incidence per 1,000"
    fi
  fi
}

if [[ ! -n $1 ]]
then
  #valid usage in case of blank args
  echo "Usage: malaria_incidence <country/year>"
elif [[ $1 =~ [1-9][0-9][0-9][0-9] ]]
then
  #year given as first arg, 1 for the function to know it's a year input
  find_data "$1" 1
elif [[ $1 =~ [a-zA-Z]*  ]]
then
  #country given as first arg, 0 for the function to know it's a country input
  find_data "$1" 0
fi
