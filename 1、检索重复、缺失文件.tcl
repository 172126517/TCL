#### 1、指定要检索的文件目录，检索同一个文件夹内的 *.ts 文件
#### 2、删除重复(duplicate)的 *.ts 文件 （重复文件的文件名含有下划线，正则表达式为：\d+_\d+.ts）
#### 3、按从 1~n 的顺序查找缺失(missing)文件 （文件夹内的文件命名为 1.ts 2.ts 3.ts ……）
proc reorde_file {dir} {
    # 1、获取指定目录下的文件列表
    cd $dir
    if {[file exist check.log]} {
        file delete check.log
        set checkRes_file [open check.log a]
    } else {
        set checkRes_file [open check.log a]
    }
    puts "The current directory: [pwd]"
    puts $checkRes_file "The current directory: [pwd]"
    set file_list [dir]
    puts "All file in the directory: \n$file_list"
    puts $checkRes_file "All file in the directory: \n$file_list"
    set fileNum_list []
    # 2、删除重复的 *.ts 文件
    foreach ele $file_list {
        if {[regexp {\d+_\d+.ts} $ele file_name]} {
            file delete $file_name
            puts "The duplicate file: $file_name"
            puts $checkRes_file "The duplicate file: $file_name"
        } elseif {[regexp {(\d+).ts} $ele file_name file_num]} {
            lappend fileNum_list $file_num
        }
    }
    set sortFileNum_list [lsort -real $fileNum_list]
    puts "$sortFileNum_list"
    puts $checkRes_file "$sortFileNum_list"

    # 3、查找缺失文件
    set length [llength $sortFileNum_list ]
    set i 1
    foreach fileNum $sortFileNum_list {
        puts "$i $fileNum"
        puts $checkRes_file "$i $fileNum"
        if {[expr $i - $fileNum] == -1} {
            set fileNum [expr $fileNum - 1]
            puts "The missing file: $fileNum.ts"
            puts $checkRes_file "The missing file: $fileNum.ts"
            # 保存缺失文件log
            set file_miss [open miss_file.log a]
            puts $file_miss "$fileNum.ts"
            close $file_miss
            incr i 2
        } else {
            incr i 1
        }
    }
    puts "$dir Check finish!"
    puts $checkRes_file "$dir Check finish!"
    close $checkRes_file
}


# 清除所有 check.log 文件
proc rmlog {swith} {
    global full_dir
    if {$swith == 0} {
        cd $full_dir
        set dir_list [lreplace [dir] -1 0]
        foreach dir $dir_list {
            cd $dir
            if {[file exist check.log]} {
                file delete check.log
                puts $dir
                cd ..
            } else {
                cd ..
            }
        }
        puts {"(ノ≧∀≦)ノ"}
        puts "remove success!"
    } else {
        puts {[・_・?]}
        puts "if you want remove all 'check.log' files! \nplease make use of the command 'rmlog 0'"
    }
}


set full_dir {E:\ic_video}
cd $full_dir
set dir_list [lreplace [dir] -1 0]
set missFile_list []
foreach dir $dir_list {
    reorde_file $dir
    if {[file exist miss_file.log]} {
        lappend missFile_list $dir
        file delete miss_file.log
        cd ..
    } else {
        cd ..
    }
}

cd $full_dir
set checkRes_file [open check.log a]
puts $checkRes_file {"ヾ(๑╹◡╹)ﾉ"}
puts "All check finish!"
puts $checkRes_file "All check finish!"
puts "Have missing file of directory!"
puts $checkRes_file "Have missing file of directory! (T＿T)"
foreach dir $missFile_list {
    puts "$dir"
    puts $checkRes_file "$dir"
}
close $checkRes_file