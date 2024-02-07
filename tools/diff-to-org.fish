function DIFF2ORG
    awk '
    BEGIN{
    print "** [%][/] 進捗";
    endsrc = "";
    }
    /^diff/ { next }
    /^---/ {
    printf( "%s", endsrc );
    print( "*** TODO [%][/]" , $0 );
    print;
    endsrc = "";
    next;
    }
    /^\+\+\+/ { print ; next }
    /^@@/{
    printf( "%s", endsrc );
    print( "- [ ]", $0 ) ;
    print( "    #+BEGIN_SRC diff" );
    endsrc = "    #+END_SRC\n";
    next
    }
    { print "    " $0 }
    END {
    printf( "%s", endsrc );
    }
    '
end
