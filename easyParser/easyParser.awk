#!/usr/bin/awk -f

function printLines(number) {
    for (i=1;i<=number;i++) {
        printf "%s", "-";
    }
    printf "\n";
}

function printErr() {
    printLines(80);
            printf "\033[31m%s\033[0m\n", "Options we can use: -> (--range for range, like ./easyParser.awk --range 2 5 given_file where 2 and 5 are start and end lines)\n \
                   -> (--last for last lines, like ./easyParser.awk --last 2 given_file, where 2 are the last two lines)\n \
                   -> (-first same as above but first lines like --first 5 where 5 are 5 first lines) \n \
                   -> (--count with the following pattern --count file or using input from another command only --count \n \
                   -> (all options used with a file as input can be used also on an input from command send it through pipe.";
    printLines(80);
    exit;
}

function validation(min_args,max_args) {
    
    if (ARGV[i] == "--range") {
        if (((min_args < 3) || (max_args > 4))) {
            printErr();
        }
    } else if ((ARGV[i] == "--last") || (ARGV[i] == "--first")) {
        if (min_args < 2) {
            printErr();
        }
    } else if (ARGV[i] == "--count") {
         if (min_args < 1) {
            printErr();
        }
    }
}

function printArr(starting,ending) {
    printLines(80);
    for (i=starting; i<=ending; i++) {
        printf "%s\n", elements[i];
    }
    printLines(80);
    printf "\033[31m%s %d\033[0m\n\n", "Number of lines in standard input/file:", FNR
}

function range_corection() {
    if (end > FNR) {
        end=FNR;
    } else if (start > FNR) {
        start=1;
    }
}

function delete_arg(how_many) {
    for (k=1; k<=how_many;k++) {
        delete ARGV[k];
    }
}

function minify_after_care(choose,strt,nd,del_num) {
    start=strt;
    end=nd;
    option=choose;
    if (del_num == 3) {
        delete_arg(3);
    } else if (del_num == 2) {
        delete_arg(2);
    } else if (del_num == 1) {
        delete_arg(1);
    }
}

BEGIN {
    for (i=1; i<=ARGC; i++) {
        switch (ARGV[i]) {
            case "--range" :
                validation(ARGC-1,ARGC-1);
                minify_after_care("--range",ARGV[i+1],ARGV[i+2],3);
                break;
            case "--last" :
                validation(ARGC-1,ARGC-1);
                minify_after_care("--last",1,ARGV[i+1],2);
                break;
            case "--count" :
                validation(ARGC-1,ARGC-1);
                minify_after_care("--count",1,2,1);
                break;
            case "--first" :
                validation(ARGC-1,ARGC-1);
                minify_after_care("--first",1,ARGV[i+1],2)
                break;
            default :
                option="none";
                delete_arg(ARGC);
                exit;
        }
        break
    }    
}

{ elements[FNR]=$0; }

END {
    switch (option) {
        case "--range" :
            range_corection();
            printArr(start,end);
            break;
        case "--last" :
            if (end > FNR) {
                printArr(1, FNR);
            } else if (end < FNR) {
                lines_printing=(FNR-(end-1));
                printArr(lines_printing,FNR);
            }
            break;
        case "--count" :
            printLines(80);
            for (i in elements) {
                printf "%s. %s\n",i , elements[i];
            }    
            printLines(80);
            break;
        case "--first" :
            printArr(start,end);
            break;        
        case "none" :
           printErr();
           break;    
    }
}
