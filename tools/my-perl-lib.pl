# #!/usr/bin/env perl -Mutf8 -CSD
#
# use strict;
# use warnings;
# #use utf8;
# use Encode::Locale;
#
# use File::Basename 'basename', 'dirname';
# use File::Path     'mkpath';
# use File::Path;
# # use File::Slurp; # perl -MCPAN -e'install File::Slurp'
# use List::Util 'max';
# use POSIX;
# #use Switch;     # perl -MCPAN -e'install Switch'
# use open qw( :std :encoding(UTF-8) );
# binmode STDIN,  ":utf8";
# binmode STDOUT, ":utf8";
# binmode STDERR, ":utf8";
# #binmode STDOUT, ":encoding(console_out)";
#
sub debug_array_dump {
    my ( $my_debug, $my_id_1, $my_id_2, @my_array ) = ( @_ );

    if ( $my_debug > 0 ) {
        for ( my $i = 0 ; $i <= $#my_array ; $i++ ) {
            print STDERR "$i $my_id_1$my_array[$i]$my_id_2\n";
        }
    }
}

sub re_blocked_parenthesis {
    # 多重・入れ子な括弧のパターン生成

    # 実際はこのほかの正規表現と組み合わせることになるが
    #「(」「)」で括られていること忘れるな

    # アイデアは以下の URL を参考にした
    # https://www.hyuki.com/dig/paren.html
    # バランスしたカッコの正規表現問題 - 結城浩

    # https://perldoc.jp/docs/perl/5.26.1/perlre.pod
    # perlre - Perl の正規表現
    # 「Lookaround Assertions」
    #   → 「(?PARNO) (?-PARNO) (?+PARNO) (?R) (?0)」
    my ( $open, $close ) = ( @_ );
    my $except_pattern = join('', $open, $close);
    my $re = qr{
                   (                    # paren group 1 (full function)
                       (                # paren group 2 (parens)
                           [$open]
                           (            # paren group 3 (contents of parens)
                               (?:
                                   (?> [^$except_pattern]* )
                                   # Non-parens without backtracking
                               |
                                   (?2) # Recurse to start of paren group 2
                               )*
                           )
                           [$close]
                       )
                   )
           }x;

    return $re;
}

our $PARENTHESIS      = &re_blocked_parenthesis( '('  , ')'  );
our $PARENTHESISKANJI = &re_blocked_parenthesis( '（' , '）' );
our $SQUARE_BRACKETS  = &re_blocked_parenthesis( '\[' , '\]' );
our $CURLY_BRACKETS   = &re_blocked_parenthesis( '{'  , '}'  );
our $ANGLE_BRACKETS   = &re_blocked_parenthesis( '<'  , '>'  );
our $WAJI             = qr{\p{sc=han}\p{sc=hira}\p{sc=kana}ー};
our $WAJIX            = qr{\p{scx=han}\p{scx=hira}\p{scx=kana}};
our $WAJIX2           = qr{\p{scx=han}\p{scx=hira}\p{scx=kana}０-９（）};

#sub my_substr0 {
#    my ($img, $ptn ) = ( @_ );
#
#    if ( $img =~ /$ptn/ ) {
#        $_ = $1;
#        s/\\\\(hfill )*.*//;
#        s/\\hspace[*]*[{][^{}]*[}]$//;
#        s/\\\\*$//;
#        s/^[ 　]*//;
#        s/[ 　]$//;
#    } else {
#        $_ = "";
#    }
#    return $_;
#}
#
#sub my_substr2 {
#    $_ = &my_substr0( @_ );
#    s/^.//;
#    s/.$//;
#    return $_;
#}
#
my $re = join(
              "",
              "(", "\\\\ruby[^\{]*" , ")", #
              "(", $CURLY_BRACKETS  , ")", #2
              "(", $CURLY_BRACKETS  , ")", #
              "(", ".*"             , ")", #
             );

sub mysub {
    ($_) = @_;
    s/[{]*\\換字[{](.)[}][}]*/$1/g;
    s/[{|}]//g;
    s/$/　　　　　　　　　　　　/;
    s/^(.{7}).*/$1/;
    s/　/  /g;
    $_;
}

$_ =~ s/%.*//;
$_ =~ /$re/;

$b2 = &mysub($2);
$b3 = &mysub($6);

printf "%s\t%s\t%-12s %s\t%s\t%s\t%s\n", $b2, $b3, $1, $2, $6, $10;
