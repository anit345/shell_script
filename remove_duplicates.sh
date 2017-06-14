#!/bin/bash
dir=$1
echo "finding duplicates in the directory: $dir" 
script_path=/opt/juspay
#creating a file with checksum details
find $dir -type f -exec md5sum {} \; > $script_path/checksum_file
#finding the number of duplicates in the directory using checksum
cat $script_path/checksum_file | awk -F" " '{print $1}'|sort|uniq -d > $script_path/duplicates_file
number_of_duplicates=`cat $script_path/duplicates_file |wc -l`
echo "number of dulicates in the directory: $number_of_duplicates"
cat $script_path/duplicates_file | while read line
do
   
   #creating a file with the names of files with the duplicate data
   cat $script_path/checksum_file | grep $line| sort|awk -F" " '{print $2}'> $script_path/files_names_file
   echo "duplicate files slot : "
   cat $script_path/files_names_file
   #calculating the count od duplicate files
   file_no=`cat $script_path/files_names_file | wc -l`
   #getting the name of the file which is first in the alphebatically order
   src_file=`cat $script_path/files_names_file | head -1`
   file_no=$(($file_no - 1))
   while [ $file_no -gt 0 ]
      do
        #getting the name of the file which is the duplicate of the source file
	file_name=`cat $script_path/files_names_file|tail -$file_no|head -1`
        #removing the duplicate file
        rm $file_name
        echo "removed the file $file_name"
        #creating hardlink of the duplicate file
        ln $src_file $file_name
        echo "created the hard link for the file $file_name"
        file_no=$(($file_no - 1))
      done
done
#removing temperary files generated in the run time
rm $script_path/checksum_file $script_path/duplicates_file $script_path/files_names_file
