#!/usr/bin/env perl
# ApacheのCombined Log FormatをJSONに変換する
use feature 'say';
use strict;
use warnings;
$|=1;

# Apache Combilend Log Format
my @format=(qw( host id user datetime request status size referer ua ));

my %me=(
	'Jan'=>1,'Feb'=>2,'Mar'=>3,'Apr'=>4,' May'=>5, 'Jun'=>6,
	'Jul'=>7,'Aug'=>8,'Sep'=>9,'Oct'=>10,'Nov'=>11,'Dec'=>12
);

my @lines=();
foreach(<STDIN>) {
	# 読込
    my @ar; s#\[(\d{2}/\w{3}/\d{4}:\d{2}:\d{2}:\d{2}\s[+-]\d{4})\]#"$1"#;
    push(@ar,$+) while m{"([^\"\\]*(?:\\.[^\"\\]*)*)"\s?|([^\s]+)\s?|\s}gx;   
    push(@ar,undef) if substr($_,-1,1) eq ' '; my %fmt=();
	for(my $i=0;$i<=$#format;$i++) { $fmt{$format[$i]}=$ar[$i] }

	# 日付
	my $datetime=$fmt{datetime};
	if($datetime=~m#^(\d{2})/(\w{3})/(\d{4}):(\d{2}):(\d{2}):(\d{2}) (\+|\-)(\d{2})(\d{2})#) {
		$fmt{datetime}=sprintf("%04d/%02d/%02d %02d:%02d:%02d%s%02d:%02d",$3,$me{$2},$1,$4,$5,$6,$7,$8,$9);
	}

	# リクエスト
	my @req=split(/ /,$fmt{request});
	$fmt{requests}={ method=>$req[0], path=>$req[1], protocol=>$req[2] };

	# JSON
	my @line=(); foreach(@format) { push @line,qq{"$_":"$fmt{$_}"}; }
	{
		my @req=(); foreach(qw( method path protocol )) { push @req,qq{"$_":"$fmt{requests}->{$_}"}}
		push @line,'"requests":{'.join(',',@req).'}';
	}
	push @lines,'{'.join(',',@line).'}';
}
say '['.join(",",@lines).']';

