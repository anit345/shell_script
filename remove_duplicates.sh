#!/bin/bash
dir=$1
echo "finding duplicates in the directory: $dir" 
#creating a file with checksum details
find $dir -type f -exec md5sum {} \; > checksum_file
#finding the number of duplicates in the directory using checksum
cat checksum_file | awk -F" " '{print $1}'|sort|uniq -d > duplicates_file
number_of_duplicates=`cat duplicates_file |wc -l`
echo "number of dulicates in the directory: $number_of_duplicates"
cat duplicates_file | while read line
do
   #creating a file with the names of files with the duplicate data
   cat checksum_file | grep $line| sort|awk -F" " '{print $2}'> files_names_file
   echo "duplicate files slot : "
   cat files_names_file
   #calculating the count od duplicate files
   file_no=`cat files_names_file | wc -l`
   #getting the name of the file which is first in the alphebatically order
   src_file=`cat files_names_file | head -1`
   file_no=$(($file_no - 1))
   temp=$file_no
   while [ $file_no -gt 0 ]
      do
        #getting the name of the file which is the duplicate of the source file
	file_name=`cat files_names_file|tail -$file_no|head -1`
        #removing the duplicate file
        rm $file_name
        echo "removed the file $file_name"
        #creating hardlink of the duplicate file
	if [ $temp -eq $file_no ]
          ln $src_file $file_name
          echo "created the hard link for the file $file_name"
	fi 
        file_no=$(($file_no - 1))
      done
    
done
#removing temperary files generated in the run time
rm checksum_file duplicates_file files_names_file
