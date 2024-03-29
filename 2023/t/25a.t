#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Test::More;
use Storable qw/dclone/;

if($ENV{CI}){
  note "This test requires Graph::Dijkstra which I have not installed in the CI environment";
  pass("FREE SQUARE");
  done_testing();
  exit;
}

require Graph::Dijkstra;

plan tests => 2;

subtest "Test $0" => sub{
  my $data = "
jqt: rhn xhk nvd
rsh: frs pzl lsr
xhk: hfx
cmg: qnr nvd lhk bvb
rhn: xhk bvb hfx
bvb: xhk hfx
pzl: lsr hfx nvd
qnr: nvd
ntq: jqt hfx bvb xhk
nvd: lhk
lsr: lhk
rzs: qnr cmg lsr rsh
frs: qnr lhk lsr
  ";

  my $graph = makeConnections($data);
  my $newGraph = dclone($graph);
  #makeThreeCuts($graph);
  # Cut the network into two with three cuts
  $graph->removeEdge({sourceID=>"hfx", targetID=>"pzl"});
  $graph->removeEdge({sourceID=>"bvb", targetID=>"cmg"});
  $graph->removeEdge({sourceID=>"nvd", targetID=>"jqt"});

  #my $mermaid = formatMermaid($graph);
  #print $mermaid;
  #

  my $groups = resolveGroups($graph);
  my $product = 1;
  for my $g(@$groups){
    $product *= scalar(@$g);
  }
  is($product, 54, "product of group counts");
  is(scalar(@$groups), 2, "number of groups");

  # Test the automated cuts
  my ($groups2, $edges) = makeThreeCuts($newGraph);
  my @obs = sort @$edges;
  my @exp = sort ("bvb,cmg", "hfx,pzl", "jqt,nvd");
  is_deeply(\@obs, \@exp, "Actual connections cut");
};

subtest "Real $0" => sub{
  local $/ = undef;
  my $data = <DATA>;
  $data =~ s/^\s+|\s+$//g; # whitespace trim on each line

  my $graph = makeConnections($data);
  my ($groups, $edges) = makeThreeCuts($graph);
  my $product = 1;
  for my $g(@$groups){
    $product *= scalar(@$g);
    note "num in group: ".scalar(@$g);
  }
  is($product, 592171, "product of group counts");
};

sub makeThreeCuts{
  my($graph) = @_;
  my @node = sort map{$$_{id}} $graph->nodeList();
  my $numNodes = scalar(@node);

  # Loop through some random nodes.
  # Find the furthest nodes from each random node.
  # Count how often different edges turn up. 
  # The most common edges could be the ones to cut.
  my %edgeCount;
  for(my $i=0;$i<$numNodes;$i++){
    my %solution = (originID=>$node[$i]);
    my $dist = $graph->farthestNode(\%solution);
    next if($dist < 2); # Let's just keep with longer distances
    for my $pathID(sort{$a <=> $b} keys(%{ $solution{path} })){
      for my $edgeHash(@{ $solution{path}{$pathID}{edges} }){
        my($source, $destination) = sort {$a cmp $b} ($$edgeHash{sourceID}, $$edgeHash{targetID});
        $edgeCount{"$source,$destination"}++;
      }
    }
  }
  # Array of edges found most commonly in long paths
  my @mostCommonEdges = sort{$edgeCount{$b} <=> $edgeCount{$a}} keys(%edgeCount);
  #die Dumper \%edgeCount, \@mostCommonEdges;
  my $numEdges = scalar(@mostCommonEdges);
  for(my $i=0; $i<$numEdges; $i++){
    for(my $j=$i+1; $j<$numEdges; $j++){
      for(my $k=$j+1; $k<$numEdges; $k++){
        note "Cloning graph for cuts";
        my $newGraph = dclone($graph);
        note "Done cloning graph";
        my @edgesToCut = ($mostCommonEdges[$i], $mostCommonEdges[$j], $mostCommonEdges[$k]);
        note "Cutting: ".join("; ", @edgesToCut);
        for my $edge(@edgesToCut){
          my($source, $target) = split(/,/, $edge);
          $newGraph->removeEdge({sourceID=>$source, targetID=>$target});
        }
        my $groups = resolveGroups($newGraph);
        my $numGroups = scalar(@$groups);
        if($numGroups < 2){
          next;
        }
        if($numGroups > 2){
          note "Somehow cut too many nodes with: @edgesToCut";
          next;
        }
        if($numGroups == 2){
          note "  Num groups: $numGroups";
          #note "    @$_" for(@$groups);
          note "    Found that these give two groups when cut! @edgesToCut";
          return ($groups, \@edgesToCut) if(wantarray);
          return $groups;
        }
      }
    }
  }

  die "Could not cut into two groups";

}

sub findMostDistantNodes{
  my($graph) = @_;

  my %farthestNode;

  my @node = sort map{$$_{id}} $graph->nodeList();
  my $numNodes = scalar(@node);
  note "Looking through $numNodes nodes...";
  for(my $i=0;$i<$numNodes;$i++){
    my %solution = (originID=>$node[$i]);
    my $pathCost = $graph->farthestNode(\%solution);
    if($solution{count} == 1){
      #note "Found a single solution for $node[$i] with weight $pathCost";
      $farthestNode{$node[$i]} = {path=>$solution{path}{1}{edges}, sourceID=>$node[$i], destinationID=>$solution{path}{1}{destinationID}};
    }
  }
  return \%farthestNode;
  note Dumper \%farthestNode;
  ...;
}

sub resolveGroups{
  my($graph) = @_;

  my %group;

  my @node = sort map{$$_{id}} $graph->nodeList();
  my $numNodes = scalar(@node);
  # Query each node to see if it can be linked into a group
  for(my $i=0;$i<$numNodes;$i++){
    my $query = $node[$i];
    next if($group{$query});
    my $foundSeed = 0;
    # Check each other node to see if it shares an edge with the query
    for(my $j=0; $j<$numNodes; $j++){
      next if($i==$j);

      # To find out if nodes are adjacent fastest, first just see if there is
      # an edge.
      # If not, find out if there is any shortest distance between them.
      my $dist = $graph->adjacent({sourceID=>$query, targetID=>$node[$j]});
      if(!$dist){
        $dist = $graph->shortestPath({originID=>$query, destinationID=>$node[$j]});
      }
      if($dist){
        # If it shares an edge, see if a group has already been set up with this seed
        if($group{$node[$j]}){
          push(@{ $group{$node[$j]} }, $query);
          $foundSeed = 1;
          last;
        }
      }
    }
    # If the edge doesn't already exist, then make a new group and seed it with this node
    if(!$foundSeed){
      $group{$query} = [$query];
    }
  }

  my @group = values(%group);

  return \@group;
}

sub formatMermaid{
  my($graph) = @_;
  my $mermaid = "flowchart TD\n";

  my @node = sort map{$$_{id}} $graph->nodeList();
  for(my $i=0;$i<@node;$i++){
    for(my $j=$i+1; $j<@node; $j++){
      if($graph->edgeExists({sourceID=>$node[$i], targetID=>$node[$j]})){
        # TODO add weigth in | weight | format
        $mermaid .= "  $node[$i] <--> $node[$j]\n";
      }
    }
  }
  return $mermaid;
}

sub makeConnections{
  my($data) = @_;

  my $graph = Graph::Dijkstra->new();

  for my $line(split(/\n/, $data)){
    $line =~ s/^\s+|\s+$//g;
    next if($line =~ /^$/);

    $line =~ s/://;
    my($ref, @component) = split(/\s+/, $line);

    for my $c(@component){
      $graph->node( {id=>$c} );
      $graph->node( {id=>$ref} );
      $graph->edge( {sourceID=>$c, targetID=>$ref, weight=>1, directed=>"undirected"} );
    }
  }

  return $graph;
}

__DATA__
msr: bcd
ssq: sbl kxh
bdq: psc qxt fxm
qrt: skh lcr
lxm: jqb zgd kxg
qfm: bbq brm
sdb: mcv gqt rmx ngn tbj
vft: nxt tfb
nsc: gvg tvt pcr bkj
krt: cds bbh
mfv: rlf dbl vtc
mqs: pnl pkp ccl
bmb: pkc jpk fzc vjn
zzg: hln gbd gzv
mkl: jtm
gcj: hbk xsv dgn
rxz: jrc dkc zbv
rnd: tfg btq tdv vtz
ncf: jnf szj nmd
cvc: hbl tpf
jdx: clj mjk jtm
blh: ljb rnr hrz
rkb: znx jnn
xcp: lrf qzm
xrs: xjr
kkj: hdc
ggm: cxf kht
cvh: dmx jzr cld pmx ndf
dzt: cqd kqb
czz: mfd dpj vjm
szp: rcp dvd
vls: fdk qtg
nfm: csk rvc
pbq: dgp ctq
zdh: vff jtl ltv
csj: cck jdz lbz rkb
grk: qmh xxm dxg
blt: tmf tfb
skv: qqp chq gnf lmb
xgl: mlc jhq fbq nkl
jvt: kzq
pxs: dfk zzx xxz kkj zdm
ljz: ssn tsz mlc bjf
mrh: kqb grk
sbg: jfg jtf
hjr: vpz
dvk: fzf tkr
cxb: cpg hpq
rfn: vpq qkk
vkl: xnl rbp jqf qsl
jpq: jpz
nmd: lkq
hrk: dxq pjj
xnd: dgn bfh bqt
hrz: thv
mmx: pmv
xjf: mbm mdg fbc
cmn: dnf qvb bzn bnk vqk
ctv: mlx ztd sld
gqc: dnj brm jfc vbb
pzc: hqg zrr vbb xlb
jzr: nkl ftg
ttl: rmm dnl bqs mzh
fdk: nnv
xrn: slm
rqm: tfg plt
xmr: skp pkr nfm zjr
gsr: ltx chc bcp ksx
kpn: qvb
xnz: fdl pmt nvv rsg
phk: lln pcl
ppn: pmv kgz phc
cjz: pcl
fcz: fmt pgt
qrr: xlk
rtb: plb dpj vqv
rlf: blj lfj mpt
nsf: vzm
kdv: rqx rbh rbk sjc nth
fkp: slm nzx jrd psx
bvx: sdf zzd
mfx: tps vjm phk vjd
lzs: mbm
cld: pds
fnj: szz
zph: rxs srp nzg tdq
qdh: kjl cnc nsf cxl sxv
vkg: xdj
dkc: rxj nfh
ldl: grp
dpz: fln ndv
dts: cqz gqr zpm tkr
czl: zrp jtf xrr txd
kjt: jqk nxs bkv xsz
ccq: dlv qxt
nsv: jnf mhb ttb vbb
lxv: dch rrf vvf
dbn: mfq tnf qrt
lcl: rgz gcz lbv
nxd: hnp zkr
fvl: xjn
lnp: sgf
tqp: lnl fqr hcq
zbr: fcm pfz bvx kml
jdh: xzr
vxp: smc gkv jrc
zbc: lgg brx vpz
zbp: tvq srp
ghm: pfp sdr cld nzt pcl
ljn: zlq crx lqb frd
fnp: xpf pmv
lck: hrm jzz fmt
mth: xsx pvf zlm
rqg: jrr hcm lbt
zxx: pkp mlc xcp pht tlf
hdg: mlp gvv cns xdj
nth: vtg bkf xzp
tlt: bqs ksd
lpp: vxc qdj cpn kpn
cln: ktf vdk mfr sqs
rkh: xqk bbq
lxl: fdc dlk gdh jrx
fhk: zvz
gzh: djc qmr
jnd: pmh cds
rmr: qlx jdj vpp
mmk: fcv srl xpn
qsr: bfx pxt fkx rlh
lqr: xrr hfg xhg
qbc: nrr rqg nvb qlx rnx
fpj: cqx smc mcq dts
rkd: msr vvj bjr kfm zxp sbl
htf: mlb mcb xlb pkc
xhh: ssf cns
nfd: ggm
dkx: rnr fqr qvr nvr mfk
hjz: lqm cpg
jbl: qbq
hqn: zdg mcb qmp
spt: pzg knd hpk
ttv: tzd nnm fhn xfm
vqt: nht pbn jnv
kzx: xdk zqh lhf dhq
cfj: qsl vdk glm
nvb: tdt
gkv: mlb bhs hdm
psc: xvc
bcj: brg
tgc: tsq gvv zqh zpl
gmk: bzm mlb xmj
fjs: fzb bsb cvm
qfq: mqf jjf mkq fsd
pqn: cjq
gnq: lbt bcp hfx dfr rdr
tgt: mfr bsb vxc jpq
jsx: qgf xqs hnq
vhv: vlq vtg fxp
vqk: kcf crq
kqt: xxz pnt szt xnx hxn
tct: bcj scc kbl
mcn: qrc nfd cqx dhl
ksz: fdt jfk slj hfg cnc
sdf: hlt
bfx: pzj sbl zbv mpt
ntf: qqq jpq phl
mtg: bzk pmh ckm txx clj
gzp: fqn vgd
xcf: fkq bkl nqz sgc
dsp: ggd bjf
khq: fhk hnv
cbz: lqs hfl pds mhg hmz
ntg: qjh qxz zvz
kmn: phk qzm gzp brm
tbv: pzm txh
qrp: zsv
sgc: mkb jqf bjk
tbc: cfc fll pxb zvz
dqn: nzl xlc
tkz: mjk mmv
lnh: rpm xqp
hsr: lrr rvf bfn
xvb: jvb lhr
mbm: xjn
ptc: ppp mnp
gjb: zvz
jfg: grd
fsp: xmb dgx
lrc: jtl
zxp: cgd tnj rqr
mdb: ghc
xmb: mjz mnt
qcv: gcj ctv cpn lbv ccq sld
cdj: czv qdr kcv
gfb: vdk
bfk: cqd mlp vtz cbp
xsx: jhq jdx dcj
bns: vnr kxh
bzn: vlq
grl: szp grp zbp pnz
tbh: flh fxm spm dkl
cgz: lzs fxk lnx zbc
bdf: cvl tlf xth gns
nzg: llz lrc xdj
gmt: plt tln lpp gcz
gxd: bgq dhk pbn nmm
pzj: jvb
lfd: ggm
vkx: slj cdv ztd
zpd: fnx fcp dgb
cks: bzm
rpl: dbn qcx tdq xfh
vvx: ndh sqf lrf fln
srt: pld lhs jrb zxz
vdv: qcx tdt
vzm: qlq
xtb: szj
rnh: jjr
mlz: vjd blk
crr: qmp gns
qqq: lks
ljk: fhq zjr
jxj: tcn rdq qbm
lxc: nlr lzl nxz trg
fdl: xjr lrr
fll: xxc
xld: dlk kcv
mfk: pnt lks
fcm: jpq jpz
flg: kmx qjh fnm
gnr: vls
nnt: plj ljb vdl
jgm: svp csk
kff: tzk hsz cck kcv
mnx: cdl vdl dnq
nhs: qmh bkv fdk qfd
lrf: bnj
tbk: hcm kvx
pvh: vgd vdn cms
mcv: jjf fmh jfg
bll: tkq dnf mlp
sgh: pll bbt jnv
lxx: jbf
rzb: ffp lrc xdk
xbm: szj cks ngb snz
ljd: fvz lkg kcf
njs: dgp zhk spl zdg bcd hjz xrs
knr: pzg mmv zsv mmk xlg
clj: xmp
tfr: jkg nvd fdl qls
fqr: mdb lbv qgf
vcd: tpp qqp zxs
vkf: crr jvb nfh qfm cts
xlc: pmf rqx
vpn: hcm drz skh lxr
hcz: zhp pqx fvl
ljt: fqn mvs
hpk: vkz
pfd: tnj xcp
pmx: tqc
qrv: tjj tkx bfn bzq mlz
xfv: plb
bgj: ljt qgj dhl
hnb: ckq qqr klm fcm
sld: ghc
stj: dbl
czr: gff
rhj: fmq xgr mjz zjr
tjj: qlt ckx rxh
bfb: jzr xfv mzf gsc
qlx: bqf
ctf: mkq
jrd: hpq
zms: zdt kht krc mph dbj
jjf: brx czr
tvq: brx xvc
bbt: grk
bqd: nsc rdb xpl zdx
tdq: tmb cnc vdl
fnc: lcj ncp dvd pkr
gdr: gjx ssm psk hkd tfg
qxz: hjc vfd
tmf: vpz nlp
sbr: pjj vhk trz
pqg: ggd bqs smd nlf
nks: xxm
hrm: bcp dnx
rlh: fnp jdf
frh: nkh xhg
psx: fpg jbt
lhf: hdq fdg
mzt: hsc kcv
nxt: drn rgz
nht: khq vdl xdb
nsx: dch
lpz: zpl qpp lxr ptl hpp
flv: kqr rrb pkr mfq
gvr: kbs qlq
lrs: jbf dth jlr sdr spz lnb fpg
mqx: qpp
nvp: czr tfb kfl hkd crx
tmb: bpt ttk
rvn: gvv fnm vft
bvp: gtd grx rqq
dnx: crq
zjp: tqc mmx
tlk: fqn hrp pzm xxs lvg
flh: sxn ktf
nlp: lcr
fzc: rlh
nkh: dnq brf xgr
bzq: bkj xqk
svf: vdv nrl vcd tqp ljd ghl
vzr: mnp
llk: tpp qpp qvq bqf
rdq: phc mhb dlz
bzk: zqr mvf sdr
fkq: fhk fmt
knv: rrs
bpt: plj
lmf: stt fmf xfh zpk mjd
zxs: dlv bqh
xhm: tlk dlt zdc
mmv: fbt
rfx: qdj fxp mqf
zlk: xpl vdn jnn zdt
xpf: xpn mnp
cpb: lbt qlb fjs bkl
jnf: lmz
tjs: cdl zjr spm
blg: gbx mnp
jtm: prv
vlb: ggj zjx
qjr: jdh hjd vpf srl gzz
kfb: hcn fps jzk lbt
lqq: gcb vtc csz jrd
ltx: jfv
mbk: dvd pnz brf
mqk: mqt tzd mfk vfd
hsz: jrb
tzp: nrm lnp zkq
rcp: sdf kcf
ljb: mjz gjx
cpg: vkz
vkr: mlx zhl rzq
lsz: tcg gpj sjq nmm
qgc: xmn nrn bzq kfm cnj pvf xmp
mfq: flg pdh
xtk: nnv
kvr: pld ftg chr ppn
bkl: dkl
plt: nxd qjx
lkr: bjf snz pzk
fgh: hfk nqc pnt hlt
hqh: lsl fsd
hbq: tlj gpn npj ngp
mkh: pkj sxp qgn
cqj: xqc qzm nrm nsd
ffv: qzt tkr nnp hjv pdb jxj
glm: ldl lsv
xdk: kqr csk
sgf: jhz cds
sdr: zlc jrx
ftr: ssm vdk vqg
xpm: jql tkh
zhl: sgh fhl
kdh: ksm ntb zmq tbj mjn
qgf: jtl
bmd: cvc fhq ngp
lqs: xlg qff jdz
dhh: jmb
nkl: lvv nrm fcp
lvp: lbq msc cjz mmp
kfm: tzp hdm
rnk: bcp
xfh: jpz
fcv: kcp zlc
sdz: gxp jkf vbb glz
tkx: xpn
vpz: xxc
gcb: lbb zlk nrn
fmf: zrf ccp vff zdm hqr
kqm: vpt lld xxz
fbp: fxp qjj nnv qvb
dvd: szz cct
sgz: skh
qbm: fbt krt
gbd: csz cds
vvj: bjr qrp
tqh: xjr frn dpg dlv
bsj: zzh fsd hfr bmd
vrd: fqs jfv jtf zmc
gns: cjz gpq
pkj: sgf
zkr: fpc
pgh: tlj pcr pvh
rdb: zqm ljf trg
ksd: nmn
tdv: krq dbb lpl
lkv: bns kcv
hjh: hfr kcz
zlq: kbp zhp
pgc: qrr mkb dhq ftm
gdh: ssl tqc
pxt: gqr xkh
qjh: ktf tmh fxm
jck: hsz kfz kht gcv
jkc: knh mqx plt xsf
dbb: vpp llz nlq rcp
rpx: pxn pgt qbt phl
zlm: tsz ccl nvv rnh
nnn: dgx xxm fdg
xpz: kqb
qfd: fmv hjh kvg
mgl: dhh
htt: vns tnf zng sxz tmh
jkf: lkr
vtg: sgz xxc
jxv: gpn rgn jdf rjn
srl: pvf
ghz: dzv
xtp: ctq cgd
gtt: vpn bbt spm kzg
vvc: plh fcd ffp fmv
dgm: gzv rxz chr vgg
sht: fsp tds nks xqs
dsm: xpz vvf hvx jsx
mzh: lkz nmd
vqg: vjz fgb
qvq: khn mnc tfc rgz
pdb: bbq rgx
qcx: pbk
kbq: cct qxz fvz
mxl: nqt zlq zkr
qlt: nzx jmb czv
rrb: ptp cbp
bbc: dfj ltm jkc psz
zmr: lkq lln stj
cvt: khq nsf vtg
bvl: bnj
dlg: rsr cds
cxf: zdg jrb
gpl: cxl tfv lld
spd: hfg qxt
fmj: rbp dnt kqm ftm
rqr: prv lnh
pbx: zfj vnq qgn
hxq: ggr dnl jmc rqp msr
vjd: hnz vvj
bpg: cmf pkc plb ckx
xkh: gzv zpm
xjj: jkh nzt pcr sgs
lrr: gxp ndv
qdj: cdl
vgg: zsk kcc nfh mtg
kbv: vdk klm hcn tpf
vhk: vkg
hxn: psk sgz
cfg: bjf sxp lvv kmz
xgm: qmp ppp
jms: hcm
nxq: phv zbx nbt mlh
dnn: ngb lkk xlb
vpq: hfr
gpj: lcg vqt bbt
jpn: jnd qrp bns
zss: xqp jnf xmj fbt zjx
plh: rhj kkj
zlc: fpg
bcm: ttm bcd
qlb: dbh
pjr: rbh xsl ngn thv
rhn: srh rdr tnp bdq
mqz: vqv lmz
fcd: bdl
jgp: xpl crr tbv lgc
gjp: tkq lks
cts: qgb tvt prv
fmq: hnp grd
qch: vrk
rxp: sgz hdq mqx
ptl: llz fhk ldl hnp
ngd: cnc hrk zvl
fnq: hdc
ccp: sbm fgb tvq
ntb: bkl
tzs: nmn mkl zqr cgd
zjx: zgd
dgx: jvt
pnt: lcl
ddf: fkx ddl hln fbk
dhp: gmt zzh xdh bjk kfl
tzd: qmh vpz mmq
rhf: mkq mnx
blk: nzx
vqv: mhb
nlr: cmf cnj sfj xrs
mzq: kht
xjr: lkz zqq
vnf: gmk cbd
ddv: qfg srr ljm jdj
fbk: trg dhh qzt
rtc: szt bmf bkf bln gfb sgg
txd: xhg dqn nxs hpp
bqt: vrg
prk: mqh kcc fnp
fcp: jjr
vkb: mqh hpq tps lhs
zqh: rfn nlp
sqf: jdf zxz jlr mmx
jhg: ksx nqt cjm fqs snd mzj zmc
qqr: tjs kzm
zrr: dlz sqz vzq
bjk: vkg mqf
dth: vcn mkh lnb
nrh: mqh
fpp: tmh qgp mfk xjn
hsc: jhz pcm
rmx: psz rrf cpn
pkz: gcv pmz gsv fzc dcs
dtc: vpq nxs drz nxd
xzh: blk lbb cmf
ngn: jrl csk fkq
jkb: hpq zdx mkl jdf
nqt: tbk
crf: bsb cxl dhk rxs
bkq: szj chr czz
tfg: qzc fsd
gnp: tkx jkg tmq fzf
jhq: zdt
hfk: nnn htc qqr
nhn: ckq jvt rbd flh
cqn: dpj sgs ghz dgb
tgl: hlt qrr hnv cbs
lrx: txh qfx
bqh: skh
hkd: vqk
dtg: ltm rnx rqm dlv
dfc: dgx lgg pfz ccp xxm
gzr: srh sgh lzb fxk
trc: sfv jms xdh
nnc: brg sqz dkt pmh
mpb: vrk pkc
vsq: vgd phk nzx
hnf: xtb qmr nnr gzh zcb
mvf: nvd pfp lhr
mpf: zsk lnp cjz
tfc: hrn
kzg: psk jgm
lkk: cms
mhg: msc
zpk: czc dgx ftr bqt
shr: kvx zjr sbg
rxh: mgl
mqt: bzf ssf ttk
kxg: fnx blv rmm
nrn: cts jgp
fhn: fvl tkq hnp
tjp: rvn bln hrv rcp
bln: zkr
zfq: rqr bzm xqp
mdj: ckx rxh gqf tzm
zxc: hjr knh mbm
ggc: cck ddn ngp cms qnm jsr
ssm: zzh tkh
tpp: mmq tdt tmb
hrp: nmd
fxj: blh gmd fnq cct
lkg: tds xlk bqh
ncp: kcz tmh zvz
sjc: sxn
vpt: fpc ncm plt
qzc: dfj qjx fxm crq
shl: ktq ddn xld pzj nsd tqh
zng: vkx tfv
jzg: mpt tlf jxs qzm
gsv: bvl zsv vtc
rvc: jvt tnf
ddn: dpg lkq
fps: vzn fcz rnk
lcg: kpn mnt
rbh: cdl mbm pqx
rts: zkq djc bhj
kzm: ztm
zbv: pzk
mcb: rkb
kcc: mqh pmt tcq
dlt: fdf mzs gdg
zmc: fdx vgh
rpm: vcn
tnd: pnl fcv gsv xqk
ptp: nbb
zdt: lln
lbq: gqr lgc
zvl: tkh nvb
nss: pxn jvf drz qlb mqf tpp
xlg: tsz
bzm: tps
bhj: mzf pkc
cvl: xqp
lnl: mqf spd mnc lzb
xrr: phl vxz
dlk: jrd hsz
xcg: ggj phd lkq
hhj: plh ntg pqn zxs
lpk: hjd dkc lrx zml
pnr: kzq xdb ntf xsv
fxk: dxq gff
vzq: nrh pcm
rbk: zzh lxr
dcl: tpf
nrc: vxp rqq pmt ccl qls
pfb: llf svh jzz
mzj: dlf hxn kkb
gzd: fmq btq tnp hbl
smd: glv
gzz: rvf mfd dlz
rrf: mnt
vhd: bkj skt mvs tjf
jsd: vbm qnj vnr bjr
mbj: kpn
hlz: qkt cfg lvp dpz nsz gpf
scb: bcm tlj
kmz: rpm
mrz: rfx tcg qmh tfc
nph: nbc ctq pmh zkq
ncm: qdf kjl sjq
gxp: rjz
nvr: nmm
thv: fcd
stt: pmf drn xzp
xsf: nrr
gjk: ncf mzh tzk
vxn: tmq hrp nvv mpb
chc: ntb grp
bsq: fqk cjq bcp krq
nlq: skp vlq sbm
rnx: cbs mlx vgh ndr
phg: jgm xzk trc rqx
znj: krt xxf xzr
nrl: tgt sxn
sdk: djc cvl bcm qrp dhh gcv
fbq: gqf
glp: zfb lcj klm tln
cqz: dlg gtd
hrv: pqx xpm
rhc: zms prk cxb krc ndv
slm: jrc
dlf: khp kbp
jvd: kcz dzt fdx
fdf: blj
pzm: zgd
vxm: znx tlt qlt gdg
fmv: gff xlc
dpn: hhq jhd tds pqx
hkr: xdj hcm
jpp: thh cks
vfd: fgb dgn
vnq: jjq tzm vnf
dch: fsd
ztd: hfg rnk
nbd: scc gpn vvj
tpf: qvb
pkq: ddf vkz pmx xpn
nkt: njv gqf ckt lgm jrb
pkr: nxd nks
ndf: bzr cxb
dzp: qch lfj vcn
zth: mtb bql qnj pvf jkf
fbc: ktf
dmx: fkx nfj mzf
pnl: jnn
nnv: rdr
sfv: vfz rbp
jrl: gvr mtp szt gcz
hpx: qlq xhj lzs dfj
zst: dkg bsx nfj gbx tzk
fvp: nbt tzm fbq scb
qpz: fkx hjd dzv
mpz: czc jbl lzs dnt
xsl: nzg jlp khq
tmm: lgc vvj jdh pzj mlz
jpk: gpq mzs qgj
dhq: mbj kvx
czc: bfh rbp
qfg: cvm rkq qvr
tlj: dzv
bgq: lzb
zpl: cjq
ckt: qgb jvk tjf lkf
kbk: vzr fdl xrn fxd
hsf: hcm bdl
frd: nmm
sgs: tnj
rjz: tlf
hdv: pdh bkl xjn
mrr: bvp tct kmn
xrb: smd jpp vrk rrs mth
hmz: sqz zgd
cck: gtd ghz
qqg: vlb rbc fpk bfz
qkk: lcj cbs
pvf: qks cld
qvr: jjf jgm
zdb: ctf tdm hdq
ccd: qfx pkj sqz
gzl: fsg vpq dch
fdc: cbd ptc vzq skf jxs
ttk: hpp
tbx: lqb xsf sjz nrr fll pdh qpp
cvm: tbk rbk
jsr: grx nsd slm nrh
xqg: ttb bvl mqz mcn
qzt: rkb
xlr: qtg dxg gnr vbv ltm
ttt: dhh vcn krc
qfx: hgz
cqx: lkk jrm
nqz: ljk sgg kzg lcg
hdl: dkt xsx xrs fpg nmn
nnp: jdh mlh zxf
zqq: czv tkx
bzf: hrv pbk jtf fhq
tkr: gpf
fvz: vvf
psf: stj dkc dpg
lts: spv lqb klm kld qxm
cbr: ddd ckt cqj plb
rdr: lks
xsv: dkl sld
pmh: tkx
pht: jdh gbx dzp
zhp: qdf
gff: fvl
svh: ldl
ljm: jpj hcr xsz xjf
tln: kpn
skt: ttm gdg pdm
dkm: nbt bfz bbq kxh nzt cdj
vrg: dnf cqd kzq
pxn: nvb
rpt: dvk pmz zfj dnj
gzf: zqm txh hfl lfd
crd: hfx hsf fsp
nbt: tsz ttt
ntt: htc vdv bnk mbk
sjk: mzt mvf kgz hnl
ddd: jxs
qdr: lkr
rbc: fdf pdm pzk
lsl: ljg
dlz: qrp txz
kbp: jfv kcg
lbz: jrx ljt
pkc: vgd
qks: glv pcl
fkd: qsl qtg jms fbr
fpk: zjp ghz xxf
rsr: zsk lkz hnz xxs
xlk: rgz
dfj: rgf
lqm: kgz tbv
vns: rgf
ggd: cxf
gjx: qtg rgf
fln: ssn rts
sqh: pkj rqp qch rzp
lbv: cxn
dpg: rqq
gpf: pxt
kbl: zqm gfc sxq
zxf: mhb
zml: mdj znx
njf: sjc hrz nqc kjl
ncz: vpf sgf knd gcv
szh: gqt zxc xgx pnt
mzf: kcv mmx csz
xfm: sjc rvc dlf dqn
rln: qtg dcl psz prc
nsz: xvb ngp
zzd: gfb
gzv: lkz
pxb: zpl qmh crd
lsv: qjx plj pfz
ghl: vdk fdg mqf
fhq: csk
fsg: gfb qgf
lrp: krc xss bbq fjd lmz
ljg: ksm fnk kfl brx
jlp: fnj hfx plt
thx: zbx jdf kfz
cjm: xlk qpx
tnp: nnt sfv
jds: khc jxj bsx ssn
vjs: mjk
prh: xnx pnr xtk fdg
xhj: fnj lgg vgh
nzl: ghc xlc lbv
slv: fll svp cxn
jlr: chr vkz
zrf: qsl rrf zhp kmx
bxp: mmv hdm xxf
mfd: tqc
xss: czd lxm blg
jjp: lhs rkh bql mqs
cnj: mjk rqr
bvm: mjz nmm sjq tpt
dbl: xtb
zhk: hqg lfd lqm
gsc: spt dpj xfv nrm
mcg: xtk
sxv: hhq dxq
qrc: dkt pds rkb
qsk: bnk dnt sxz
zjr: cbs
btq: jzk xqs
ckm: vnr tcq vjs
jlk: rmx kml pnz ljk
zpr: phk bhj xfv tlj
ndv: lgm
ckx: cms
qxx: tbj fcd jzz
zrp: jql hcz rhf
grd: bcp
qgn: qdr mvs
spl: bnj hfl
trk: bnj hsc hpk stj
tlz: hkr qqq jdj
xxc: lnx hbk
bqs: qmp
gsl: xpm xdb bvx dnx
mpk: srh qqb vns dhk
rxj: qnj pdm vkz
pqj: hjh svp vqg pxn
mnc: vkg
zcb: thx ctq mfv
clf: pmv lbb vnr kxf qpz zdc ktq
kld: trz hdc
ggr: bhs jrm gkv zpm fcp
kpc: zfj rlf dvk shq bnj krz vjs fzc hnl
jfk: vfd vbk
klm: tdt
mmp: rxh vnr nrh gqf
kfz: jkh tvt gpf phc
ldq: nbc rqp skf zjx
rcz: xxs tnj sdr rvf
hnl: nrh
rkq: tmf
hgb: scc rgx shq zsk
qpx: hjh hnv dgx
tdz: kqm mqt vdk lck mrh
gpn: czv czz
qpg: mpf jfc lxx
nvk: tsv nzt xtp tcq
zfn: hbl flv gqt qbt
dxl: dhl bfn zqq
hrn: qbq thv
vxz: mlx
khc: ngp mfd
hbl: qlx
fhl: vhk lsv
xct: spz ngb lhr kgz csz mkj
szz: kbp fnm
nqc: bkv grp
dnq: vbv sfr
mlm: vrk xmp kbl
hqg: dlg bdf
cxl: xlk jhd
hcr: mdb kcz fdx xhg
ttm: mzq
zxg: fdx lxv hkd mkq vfz qjj
zmd: mjk rgx jhq ffv
tsq: fdt dnt hjc
bdj: hnq fhk
ddl: qfx dlz
bhs: ggj
xdb: gfb
rsg: hrp zxz txz
plj: vjz
dpd: cbp ppz hhj xdh
vtc: gtd
sxz: mrh gfb
sgg: hqh ltx
jbf: ssn
zdx: mcq jxs mpb
rbd: nnm gnr mnt mkb
xcs: tbn vjz cbs dcl
dkl: crq
hnq: nvr
rnr: svh
gjf: ggd hqg vjn khc xcg dxl dpj
xjg: bgl vtz mpk ncm
xmn: txz glv tsv nfh nbd
qjj: jql dps
khp: skp fgl nth
phv: blk rnh knv
ljf: xxf bjf
hvx: ffp vqm bjk fhl
lvg: tps nrm
hdq: lnx
ttn: qff mlb bfn qbm
slt: llz gjb chc fdk
vjn: qnj gtd ddd
jjq: snz pld gbd
xsz: nks jnv
fjm: lrr hfl dpj zml
gmd: hfx nsx qxx
prv: zdg znx
dcj: vlb gxp
snd: nfm zpl
vkv: ptp zkg bgl xxm vzm
lld: jtl cns
gbx: ftc lpq nnr dnl
jbt: lqs zjp lbz
jvf: qrt hdv kzq
rgn: vdn
nlf: gmk gpq mvf
fkj: blj znj lhs bgj
llf: hjc
xzp: qvb
kqr: vvf
qrq: xpz knh fcz llf
jvc: lsl vzm
vvf: vxc
lqh: dbh xnd xxz rqv qqp
vpp: skp
bft: zpl vpz xhh
xtq: rqv fvl fhq sxv
kmx: nsx ztm
jzk: tbj
glz: jjq nvd
nbh: fmt xgr drn sbm mqx
knd: lxx jnd
jhj: nfd jkh bzr
rmm: qdr bcj
xdm: fnj tdz ctf kzg
xqs: mnt bdl
vpf: cqz rqr
qjx: qsl
xzk: fbr dfj
sqs: pfz fkd bgq bsb
hdm: jbf
lcr: vpq hjh cct
hln: qch npj
prz: fhq bzn xnx tkh
jkl: zdc lkk xgm
rzp: nzt ljf jpn
ffd: lgm mkl xlb
mcq: vrk xtb
mns: snz bhs sqp zqr
tcx: rxp fpc pll
ftc: rvf jjr hqn
bbh: qkt
zqm: blk
spq: qbc dnx cvc lcr
txx: mgl jsr ttn
gqr: bbh
lzl: qzt qkt xlg
pbn: pmf qbq
mdg: frh mnc drn vhv tkq
pll: gjb kbp
fkn: scb lpq gfc qgb nsz
dzz: gqc qkt tjf jrm
rxx: pgt mcg tcx sgh xgx
vtm: mkj dzp lfd ppp ddd
qgj: bvl knv
rdd: rgn sxq fdf brg
tnj: ksd
vjz: bqf
phc: lln xxs xzr
kxf: cbz ckm zbv
svp: kqb
dcs: vzr rkh
tqm: qlb pqn xtk hfr fsg
sqz: ttb
lff: vft prp kcf
vcg: xgm bkq pvq cks
czd: pmt dhl hgz
jdz: cgd
qgp: rkq zbp jzk
tcg: pzv jbh tbj
xxz: qrr
tdm: ftm jzz vxz
frn: jnn zxf ksd
ppz: lld kcg
bql: gng lbq ptc
bfj: pvq nrn lrx xpf
kcp: jhz kxh gqr rjz
tpt: hhq gfb kvx
gvg: lvv lnh npj gdg
xpl: sxp
fmh: bkf sxn xqs
qnm: ndh tsv blv ftc jkf
fqk: fmv rqm tfc glm
cxd: xgx psc gvr hpx
pgp: clj glz ttm pfd
srr: pfz kld
bnk: hdq
jbh: xlk mcv hjr
dgb: pds
jpj: bzl mcg hdc nqt
gnf: vzn ltx hrh rhn
fzb: hqr fbr jvc
shq: phd
crx: xnl fnq nsx
ngp: lvg
xdh: kvx
bdl: cpn mfr
txz: lhr
tdr: mnx bpt nbb vbv
cms: xmp
tbp: srh tds qcx hrz jbl kzm
ttb: jtm
pzb: ssq npj pmx lnb
lnb: vjs
qff: jnf nsd mzs
sjz: vzn hrn tll jtl
rzq: nnm pgc zdh qcp qsk bft
pjj: cxn xvc
fzz: dzt hhq lnx kqr ffp
sfj: dpz jkf pvh
skb: sxp zxz mvs
nxb: pnl lpq jrc fkx
dnf: cfc
fzf: bcj sbl
nnr: lgc tsj
xqk: bbq
hrh: psk blt qpx
qlq: hfg
nbq: kml qqp phl
cxn: skh
zkg: rnr gpl kzm vbv
dfk: xtk ksx mcg
mkj: gxp
lgt: jmb bkq zzg tbv
lmb: kbs bqh slv bzl bbc rrb lhf
cbp: fnq qdj
rgr: tfb lpl nzl vzm
khn: pqx gnr tpf
ksk: qqb dgx blh bmd
jhd: rvc fbr mbj
xnl: srp
bgl: nxs
ftg: nvv cmf
kbs: jbl jfg hlt
rfg: tmq rtb nrh tqh
bfh: mbj lgg
jqf: zvz
fdg: trz
jfc: rgx
bmr: lmz tcn xrn mph
qxc: bgq kml mkb ndr
ndr: fbc krq
bdr: qjh rqv nxt fvz
fdh: sbr mxl vpt hpx
dfh: jkl gzh zsv zbv
njv: bbh
pmz: qks hpk
kvg: bkv nbb hdq
qsf: jfg nks gcj jrl hkr
fgl: zzd flh vff
cbd: cvl mqz
hbs: dsp ccd qgj gfc
pld: mqh mvs
ppp: gzv
cdl: rfn
fbt: qzm
zfb: vqk nbb xvc sjq frd hrk
gqt: hpp
zmx: fnk pbk bln hrm
txh: dbl
ssj: dzv nvd qzm vnf
bfz: zjp gbx
mlp: dch
dbh: fnk rqx
clt: qxx rvl ltm mpk
bzr: lgm brm
htc: gvv vhk fgb
xgx: gjb qxz qdf
rqq: pdm
vgh: trz
drr: xtp nfd zsk mtb knv
fkv: qlh dxq fjs mjd
hqr: pzv hnq xpz
hcq: lsl fbr gjp
jjg: skt ngb bcm szj
cdk: jtf spm jfk mrh nlp jpz
qqp: ztm
tzz: hnl mrr xpf tsj
lvv: xmp tvt
slj: nzl mfr
grx: qfx xzr
zbx: cpg bjr
jhf: tjg krt rnh scc hpq
qzz: xmj qnm ssj fxd mnp
rvl: cvt sdf hcr lff
fpc: bqf
snf: fmf sjc nsf lck
bsx: ddl xzh
vjm: jkg xxf
btn: hsr lrf mcb ndf cxf
bcd: glv
tll: hjc pqn
dps: czr tln ksm nlq
dxg: ccq fxp
mjd: kbq mnt
qgm: vbk grd jnv bdj ptp
zqr: jrc dnl
ztt: kjt cns zkg xfh
jsg: nrl tpp ckq tzd
gzb: dcs mlh zqm kmz cbd
kdx: hsf cbp tlz cjq
dkg: djc xvb
bbq: tlf
jqk: pmf zvz
pvq: qgb sxp dgb
qmr: hjd jmb
mtb: fbq dcs
hjp: zjr brf hlt rdr
nbc: jqb pzm
kkb: kpn khq szp fqr
fhg: gjk cbd nlr lnb
ltv: vlq zlq bzn
pnz: xsf hkr dfr
pqx: svh qtg
vtr: jrx jvb gfc spl
vzn: ssf
sxq: pcr pcm
zzx: qqr xhh spd
zsh: pbk rzb tnf hbl
sqp: jhq bkj tqh
fjd: ftg hgz glv jqb
kbz: zmr fdf xcg pcm
tqr: grd trg mkl zfq
zvd: gzv mlh bxp blg
zjm: xqc dsp gdg chr
ssc: nnm tlz cvc vpq
phd: fqn zqq
vff: srp krq
vqm: rln snd cfj
qqh: lrc chc tpf sjq
lkf: dlz fbt pfd
mph: zkq vjs
dbx: zvl pfb fnk brf
vbm: jkg xkh mzt
hcn: xxz nxt
fxd: rdd dts
dbj: mgl sqz mzq xgm jfc
dhl: qmp
tjg: jjr msr sjk
krz: bzm ljz gzz
dnj: zdc skf
gng: fkn jhj jkg
bzl: pzv gzl kjl
hjv: dlt xqk lnp
rjb: njv xtb qmr mvf
lhr: gpq
prc: ssf jdj
tsv: mlm
jdn: xlc dhk ckq ctf xtk
spz: dkg rkb
tfv: vkg
ssr: qpg vsq nmn zml rmm
ssl: sbl jrc ljt
nxz: jgp tlt ffd zxf
jvb: jqb
ftm: gfb
mtp: gfb gqt stt
zfj: xfv
xth: tvt ssq fpg
tfb: gcz
lzb: knh
xmj: lxx
dhf: dvd vns drz bdj
hnz: lpq
khz: gmk tcn pqg msr hgz tkx
nnx: hmz hjz pgh lfj
fnx: pcr jkh tfd vqv
blv: qrc mmk
ccb: mkj smc shq zpd srl psx
mcz: mbj ljn gjp bkf kkj nsf
ldd: rgf rhf srr vxc cjm
lbg: brg gsv xhm dkt pbx
ccl: dgp hrp rxj
dhk: xdb
cdv: kqb ksx rqv
brc: qfm dcj tkz dgp skb
qqb: nvr vxz qdf
kks: hbq jhq xld pvf
xtv: kfl sbm fvl xnl
zmq: fmh nrr zdb
pfp: lfj xjr
qls: cgd ghz pnl
jrr: tll bpt kcg
qlh: cfc cdl zrf
qbt: ngd dcl zhl
tht: mhg jhz pbq nfd
rjn: kmz lvg pbq rgn
tzm: jrm mzs
jxr: mzs jdf ssn skf
smm: bhj kcp mzq njv
fqf: fhq bqf tln sbg zng
fqs: dxg skp
mjn: xnx kcg bgl
cbt: vpb mfv cvl ccl
ksx: nbq
fnm: nmm ksm
vpb: zjx lkv tfd rqp pdb
prp: vtz flh hbk
jpd: kzg qxt kqb ztd
pzg: bkj pkp
jlj: psz rkq psc lqb
rxk: jvd lqr shr jql rrb llg mdb
lmv: mjn qfd bsj bvm
pzv: szt
dfr: mqx vls
lbt: prc nlq lsl
msc: smd tkz
qxm: pgt zzd fsg
bkf: cqd fnk
txf: ggj ggr lkv jpp
sfr: qbq fdt qxt
smc: gqf rjz
tmq: sgs pkp
fmt: qqq fdt
vbk: lcj ztm
spv: jms vfz jvc zdm
xzj: dkl vkr bll vtg ppz
llg: pdh frd ljd
xzm: kkj blt zdm hnv
ktq: mqs mhg cts
rxs: drn xmb tfv
mpt: hnz
tcn: gdh
tsj: xrn ndv msr
nfj: msc nkl
ndh: fqn tcq
ndb: zlc dkg sbl jdz
rrs: vzr
lbb: mlc
lpl: zpl llf
xqc: psf pkp
mrx: bqt hqh gzr fbc frh
chq: sht qkk vfz pqn
thh: gzp xxs vbm
ksj: ndr rnk ttk jqf
tbn: gnf xnx mjn
qfj: rmr hjr jqk ntb hbk
zpm: pzk
dgn: cfc
jvk: scc qzt pcm
ctd: dnn vdn gxp fzf jdx
ghc: sdf lxr
bpf: tjf lvp blj ttm
tfd: mmk rrs
mmq: jfv
qcp: tdm xzp vpp
bmf: xzk mmq xgr
jmc: tzk jjr rpm


