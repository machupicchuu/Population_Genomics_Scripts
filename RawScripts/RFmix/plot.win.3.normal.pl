#!/usr/bin/perl
use strict;
use warnings;

my $in=shift;#"M54.21.rfmix.0.Viterbi.txt.withPos.gz";
# M54.21.rfmix.0.Viterbi.txt.withPos.gz

# chr length
my %length;
open(I,"../ref/UMD3.1.fasta.Length.stat.list");
while(<I>){
    chomp;
    my @a=split(/\s+/);
    #$a[0] =~ s/Chr//;
    $length{$a[0]}=$a[1];
}
close I;
# pop sample size
my %pop;
open(I,"00.print.ind.pop.pl.txt.count");
while(<I>){
    chomp;
    my @a=split(/\s+/);
    $pop{$a[0]}=$a[1];
}
close I;

$in =~ /\/([^\/]+)\.(\d+)\.rfmix/;
my $pop=$1;
my $chr="Chr$2";
my $chrlength=$length{$chr}/1000000;
my $popsamplesize=$pop{$pop};
#print "$pop\t$chr\t$chrlength\t$popsamplesize\n"; die;


#my @color=("black","#A6CEE3","#1F78B4","#B2DF8A","#33A02C","#FB9A99","#E31A1C","#FDBF6F","#FF7F00"); # 8anc color
my @color=("black","#E31A1C","#1F78B4");

my %h;
my $total=0;
open(I,"zcat $in|");
open(R,"> $in.r");
open(LOG,"> $in.log");
print R "
pdf(\"$in.pdf\",width=4.8,height=3)
plot(c(0, $chrlength), c(0, $popsamplesize), type = \"n\", xlab=\"Positions (Mb)\", ylab=\" \", main = \"$chr\")
";
while(<I>){
    chomp;
    my @a=split(/\s+/);
    
    my $start=$a[0];
    my $end=$a[1];
    my $length=$end-$start+1;
    $total += $length;
    
    for(my $i=2;$i+1<@a;$i+=2){
        my $id=$i/2;
        my $hap1=$i;
        my $hap2=$i+1;

        $h{$id}{1}+=0;
        $h{$id}{2}+=0;
        $h{$id}{3}+=0;
        $h{$id}{4}+=0;
        $h{$id}{5}+=0;
        $h{$id}{6}+=0;
        $h{$id}{7}+=0;
        $h{$id}{8}+=0;
	
        $h{$id}{$a[$hap1]}+=$length;
        $h{$id}{$a[$hap2]}+=$length;
	
	# haplotype 1 
	my $ymin1=$hap1-2;
	my $ymax1=$ymin1+1;
	my $anc1=$a[$hap1];
	my $color1=$color[$anc1];
	#print R "+annotate(\"rect\",xmin=$start/1000000,xmax=$end/1000000,ymin=$ymin1,ymax=$ymax1,fill=\"$color1\")";
	print R "rect($start/1000000,$ymin1/2,$end/1000000,$ymax1/2,col=\"$color1\",border=NA)\n";
	# haplotype 2
	my $ymin2=$ymax1;
	my $ymax2=$ymin2+1;
	my $anc2=$a[$hap2];
	my $color2=$color[$anc2];
	#print R "+annotate(\"rect\",xmin=$start/1000000,xmax=$end/1000000,ymin=$ymin2,ymax=$ymax2,fill=\"$color2\")";
	print R "rect($start/1000000,$ymin2/2,$end/1000000,$ymax2/2,col=\"$color2\",border=NA)\n";
    }

}
close I;
print LOG "Total length with SNP assignment:\t$total\n";
close LOG;
#print R "+labs(x=\"Position (Mb)\",y=\" \",title=\" \")+theme_bw()+theme(axis.text.y=element_blank(),axis.ticks.y=element_blank(), panel.grid =element_blank(),panel.grid.major=element_blank(),panel.grid.minor=element_blank(),  panel.border=element_blank(),axis.line.x = element_line(colour = \"black\",size = 0.5))";
print R "\ndev.off()\n";
close R;


#print "#id anc1 anc2 anc3\n";
open(O,"> $in.winPer");
foreach my $k1(sort{$a<=>$b} keys %h){
    my @tmp;
    foreach my $k2(sort{$a<=>$b} keys %{$h{$k1}}){
        my $count=$h{$k1}{$k2};
        my $percent=$count/($total*2);
	push(@tmp,$percent);
        #print O " $percent";
    }
    print O join("\t",@tmp),"\n";
}
close O;
`/ifshk4/BC_PUB/biosoft/PIPE_RD/Package/R-3.1.1/bin/Rscript $in.r`;
