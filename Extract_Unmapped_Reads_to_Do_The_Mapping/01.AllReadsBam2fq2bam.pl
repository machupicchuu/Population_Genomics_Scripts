# extract unmapped reads to MT chr / 16S database

my $samtools="/home/wanglizhong/bin/samtools.1.3.1";
my $bwa="/ifshk4/BC_PUB/biosoft/PIPE_RD/Package/bwa-0.7.10/bwa";
my $ref="/home/wanglizhong/project/04.zangyi.F13FTSNWKF2248_HUMmuzR/06.unmapped.to.Micro16sDatabase/16Sref/Greengene_2013_5_99_otus.fasta";
my $bowtie2="/ifshk4/BC_PUB/biosoft/PIPE_RD/Package/bowtie2-2.2.5/bowtie2";
# --no-unal

my $outdir="$0.out";
`mkdir $outdir`unless -e $outdir;
`mkdir -p $outdir/tmp`;

open(O,"> $0.sh");
my @f=<bam/*bam>;
foreach my $f(@f){
    $f =~ /\/(.*).recal.rmdup.bam/;
    my $name=$1;
    #print O "$samtools bam2fq $f|gzip -c > $f.unmapped.fq.gz; ";
    #print O "$samtools bam2fq -1 $f.1.fq.gz -2 $f.2.fq.gz $f ;";
    
    # -f 4 unmmapped reads 
    print O "$samtools bam2fq -f 4 $f|$bowtie2 -x $ref -U - -q --phred33 --no-unal --sensitive-local | $samtools sort -O bam -T $outdir/tmp/$id2 -o $outdir/$name.sort.bam; $samtools index $outdir/$name.sort.bam;\n";
    #print O "$bwa mem -t 30 -M -R \'\@RG\\tID:$name\\tLB:$name\\tSM:$name\\tPL:Illumina\\tPU:Illumina\\tSM:$name\\t\' $ref $f.unmapped.fq.gz |$samtools sort -O bam -T $outdir/tmp/$id2 -o  $outdir/$name.sort.bam; $samtools index $outdir/$name.sort.bam;\n";
    #print O "$samtools bam2fq -f 4 $f|$bwa mem -t 30 -M -R \'\@RG\\tID:$name\\tLB:$name\\tSM:$name\\tPL:Illumina\\tPU:Illumina\\tSM:$name\\t\' $ref - | $samtools sort -O bam -T $outdir/tmp/$id2 -o  $outdir/$name.sort.bam; $samtools index $outdir/$name.sort.bam;\n";
}
close O;
