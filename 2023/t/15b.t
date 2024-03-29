#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Test::More tests=>2;
use List::Util qw/sum/;
use Storable qw/dclone/;

my %ord;
for("a".."z","A".."Z",0..9,"=",",","-"){
  $ord{$_} = ord($_);
}

subtest "Test $0" => sub{
  my $data = "
rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
  ";

  my $instructions = aocSums($data);
  my $finalBoxes   = followInstructions($instructions);

  my $expPower = 145;
  my $power = focalPower($finalBoxes);
  is($power, $expPower, "power");
};

subtest "Real $0" => sub{
  local $/ = undef;
  my $data = <DATA>;
  $data =~ s/^\s+|\s+$//g; # whitespace trim on each line
  my $instructions = aocSums($data);
  my $finalBoxes   = followInstructions($instructions);
  my $power = focalPower($finalBoxes);
  is($power, 262044, "power");
};

sub focalPower{
  my($boxes) = @_;

  my $power = 0;
  for(my $i=0;$i<@$boxes;$i++){
    my $boxInt = $i+1;
    my $numLensSlots = scalar(@{ $$boxes[$i]{order} });
    for(my $j = 0; $j < $numLensSlots; $j++){
      my $lensSlot = $j+1;
      my $boxStr = $$boxes[$i]{order}[$j];
      my $focalLength = $$boxes[$i]{lenses}{$boxStr};
      my $product = $boxInt * $lensSlot * $focalLength;
      $power += $product;
      #note "+= $boxInt * $lensSlot * $focalLength";
    }
  }
  return $power;
}

sub followInstructions{
  my($instructions) = @_;
  
  # an array of 256 boxes from 0 to 255
  my @box;
  my $exampleBox = {
    order => [qw(aa bb)],
    lenses => {
      aa => 2,
      bb => 1,
    },
  };
  my $blankBox = {
    order => [],
    lenses => {},
  };

  for my $I(@$instructions){
    my $boxIdx = $$I{box};
    $box[$boxIdx] //= dclone($blankBox);
    my $boxStr = $$I{boxStr};
    if($$I{move} eq '='){
      # If the lens already exists in this box, then replace
      # the lens without affecting the order
      if(defined $box[$boxIdx]{lenses}{$boxStr}){
        $box[$boxIdx]{lenses}{$boxStr} = $$I{focalLength};
      }
      else {
        push(@{ $box[$boxIdx]{order} }, $boxStr);
        $box[$boxIdx]{lenses}{$boxStr} = $$I{focalLength};
      }
    }

    elsif($$I{move} eq '-'){
      my @order = grep {$_ ne $boxStr} @{ $box[$boxIdx]{order} };
      $box[$boxIdx]{order} = \@order;
      delete($box[$boxIdx]{lenses}{$boxStr});
    }
  }

  # Fill in the other boxes
  for(my $i=0;$i<@box;$i++){
    $box[$i] //= dclone($blankBox);
  }

  return \@box;
}


sub aocSums{
  my($data) = @_;

  my @instruction;

  for my $line(split(/\n/, $data)){
    next if($line =~ /^\s*$/);
    chomp $line;
    for my $str(split(/,/, $line)){

      my $move;
      if($str=~/([=-])/){
        $move=$1;
      }

      my($boxStr, $focalLength) = split(/[=-]/, $str);
      my $hash = hashsum($boxStr);

      push(@instruction, {boxStr=>$boxStr, move=>$move, box=>$hash, focalLength=>$focalLength});
    }
  }

  return \@instruction;
}

sub hashsum{
  my($str) = @_;

  #note "hashing $str";
  
  my $current = 0;
  for my $chr(split(//, $str)){
    #note "letter $chr";
    #$current += $ord{$chr};
    $current += ord($chr);
    #note "  $current after ord";
    $current *= 17;
    #note "  $current after x17";
    $current = $current % 256;
    #note "  $current after mod 256";
  }
  
  return $current;
}
__DATA__
rg=6,knj=6,qhbrv=5,jgj-,znv-,hdxfn=7,fzk-,vl-,hp=5,vxdpxs=6,dmt=1,rxvj=1,zq=9,xdxjn=1,hscb=4,hb=2,hkn-,xk-,gcxq-,rc=6,cjm=4,vh=3,vfp-,hlg-,hrpq-,hpmt=1,fj=1,crbh-,zxm-,vjf=3,rxvj=5,crbh=7,tfnq-,ng-,jrmcp-,nf=2,hb=8,hs=4,rsfz-,rsbv=7,rm=6,mv-,ndz-,jhtf=1,pz-,szhrb=6,lt=7,lsrh=9,tf-,lkc-,snmq=9,pskg=8,tbf-,mk=1,zd-,vbbm=3,cpdtnk-,hntnvb=5,gtf=6,zdqjpg-,ddk=2,ltlq-,hs=2,pfn-,fdk-,mk=6,qxr-,zmh=4,xn-,thhf=8,sg-,bhc-,vbxd-,mddp-,lnj=8,gjm-,hdxfn=4,gkpr=7,lc=6,flf-,dn=8,pg=8,ktgv=9,hcv=5,ndttzn-,vskx=9,kfc-,px=1,qsbvl-,chkhk=3,pcflg-,jgpd=6,lp=1,ph-,jrmcp-,htpjdt-,cv=7,dsdm-,vjx-,fkf-,mz-,vl=6,lp-,fj-,pfn=8,kld-,gdf-,nk=9,sf-,mzj=2,cdm-,rsfz=1,th=9,jgj-,kql-,dsdm=4,gn-,kgx-,bm=4,cf-,jgmq-,mhm-,psfrk-,ch-,tf=5,hpmt-,dmt-,vld=5,vdk=4,xbr-,mzj=1,kq=2,vrc-,cdxlm=1,pxktxc=2,jbp-,cnrlzv-,fr-,kvhx=1,xx=5,sh=1,hfrxnx-,lvg=7,jcc-,crbh=5,dhgfl-,sq-,vjx-,qm-,gdnv-,zcstsg=1,lj=2,ljz=3,zpp-,mzj=1,tr=9,crr-,flq=4,ks=5,hrpq=1,hdzx-,rnj=5,zq=2,pj=8,pfn=6,bc-,sfdrms-,fkf-,szqvlv-,gk=8,gt=7,zzd=6,kj=5,bmm=2,rnj-,djflp=8,jzlmc-,bmcfk=2,nsh=6,sg=3,ftcht-,dskzb-,vl-,cn=5,gdcm-,qjqh=9,fjvs-,mjdj-,klj-,dqt=4,nmlfxt=6,grl=8,brdzm-,szhrb=8,hgzx=9,frb-,gxjpj=6,gjm-,mp=7,glp=9,dhj=9,dqt=2,gszqbt=6,qnpq=8,nd=7,qnbz-,kfx-,cc=7,cc-,sf-,gt-,dt-,hdxfn-,qd=5,nb-,dvt-,cjvj=4,hcv-,txt-,bmm=4,nr-,rq=5,tn=5,pfn-,xhr=2,cn=5,nc=2,kvhx-,kz=9,sqq-,gzt=7,njpm-,jvl-,hfk=1,bhqm-,mhs=5,snmq=6,jz-,kgf-,zld-,jm=9,zhlf=8,ch-,pvr=6,xrv-,kkmf=3,zkjdmg-,gxv-,xh=5,ss-,vbbm-,nvn=6,psp-,qmv-,mbbh=6,ldd-,kpc=3,mq-,vpc-,hb-,qjqh-,fjvs-,zb-,rx-,lps-,nphr-,npf=5,vpc=9,qnk-,fmq=1,vjx=6,cf=5,cpdtnk-,fmq-,hhpfdr=4,gxv=1,nbpvc-,dnx-,rsfz-,cv=6,dc=4,pdzb=9,grl-,jxkd-,pnbm=9,frb=2,cdxlm-,fljtxr-,sg=4,cgrq-,hdm=9,qc-,qnpq=9,tf-,knj-,phlh=4,sk-,qm=4,ljz-,cth=8,kgx=9,hgh-,hb=4,qmv=4,lj=7,mz=6,vd-,sc-,mjmb=3,jk=1,hq=6,jvl-,dhgfl=4,xj=3,zb=3,sqskr=6,hmhf=3,jjktx=9,gxv-,ntsc=8,bjqx-,qc=6,xrx=4,rp=3,fr-,phlh=3,sn=2,lkm-,hcrm=2,pdtz-,kzf=3,pvqjdb=5,zmn=5,dhj=7,ks=2,th=2,kp=1,gdf=8,rsfz-,jjktx=9,dvkt-,gp-,hmhf=8,jq=4,nq-,pfn=7,xccn=3,vbxd=2,bxphd=8,hmhf=4,hf=9,vpdp-,hkn-,grl-,vpc=6,bhmgm=1,xbm=7,qh=2,vbbm=1,kr=7,fdk=8,xkv=2,vh-,ktgv=8,cp-,cz=3,bxphd=9,jg-,mk=6,ktgv-,hcrm-,tfnq=5,vjzl=5,klj=4,fkf=3,xhkgnf=3,bx=2,qrn=3,klj-,tgjc-,ml-,nq=4,pnkhbj=1,jv=2,cpdtnk-,mf-,vh-,sl-,jbp-,kpjzn=7,kpjzn=6,gkpr=4,sfdrms-,sf=2,zdvr=6,bjqx=7,ldd-,gr=3,hdm-,jrmcp-,dhkj=1,hp=1,jsmql-,dh-,mlb-,mq=2,xxv-,vq-,tnd-,tqb=7,scpf=5,sv=4,jq=7,dhkj-,zm-,nb-,ds-,bqf=8,qnk-,kq-,kr-,zgp-,jgmq-,flq-,flf=5,hlg=4,cdm-,gdnv-,jb-,mp=3,xdxjn-,cjm=8,trh=2,mkr-,pfn=7,nv=5,skgz-,xtsq=5,zxm-,ljz-,cgrq-,zzd=5,kfx-,cqjpl=9,fn=1,brdzm-,sfxv-,kpc=4,hrpq=7,mhm-,znh=7,lt-,qnk-,sq-,pdzb-,mhm-,nqvpv=1,jrfq-,brdzm=3,xccn-,qh-,cjm-,nphr=6,qnbz=1,mkr-,fj-,gr-,bh-,ghrs=8,bm=8,jsmql=3,dz-,xc-,kkm-,jxk-,pnkhbj-,qsm=3,dsfz=4,ds-,cz=6,ghrs=1,glp-,mv=1,glp-,nq=4,flf-,vkjv-,cqjpl-,gxjpj=7,zpp=8,kpc=4,dn=5,zsp-,cf-,hrbk=1,sbtf=8,xhr-,xt=1,lnhzc-,trh=5,djflp-,mkr-,qxl=7,xb=6,gdcm-,ksvkx-,skgz-,nb-,zt=2,kj-,rnj=5,nr-,zm=3,zdn=9,hscb-,cpx-,sng-,xj=8,znv-,jrfq=6,thhf=8,cp=7,cdxlm=6,pvf=5,tgjc-,txnqj=7,ltlq-,zgp-,fn-,cb=8,zjf-,kr-,znh-,bxphd-,nsfhs-,hqz=6,zvp-,cht=9,mv=4,cdxlm=2,nmlfxt=4,hcv=8,sn=3,cdxlm=5,hn-,dskzb-,njx-,bh=2,ntsc-,rnj-,bjqx-,cc=5,vq=1,cgrq=5,vpc=8,jg=4,kxx=2,bxphd-,rc=1,tr-,nsfhs-,pg-,xb=8,tfnq=2,nc-,jrmcp=7,vs=1,bm=2,snmq-,hmhf-,sb-,txt-,lv=8,dgrcd=8,rddks-,pvqjdb-,xmx=9,ftcht=6,lg=3,jzlmc-,vxk-,bqf-,dhj=3,kgx=6,dn-,cdm-,jgpd-,td=4,gm-,dd=2,mjmb=8,zq=6,zdn-,dvt-,hqf-,ngc=4,lg=6,mp-,hhpfdr-,dh=7,kg-,vrc-,dx=3,lt-,mf-,tqb=4,ltlq=8,sh=4,sv=4,nnr-,cv-,xf-,nb=9,gnk-,bxphd-,td=9,xrv=8,rlhf=8,gdf-,zq-,txt-,qnxp=1,ngc-,ts-,qdlgh-,jgj=1,bkmr=7,jm-,hfl=5,tnd-,hmhf-,cm=6,qr-,tgjc=6,ftl=5,vxk-,bmp=8,rsbv=1,nr=3,ds-,kgx-,jrfq-,vbxd=8,dd=4,nr=7,vjzl-,ptcxqk-,xn-,qnpq=9,zq-,xccn-,kql=5,dc-,hdm=6,ksvkx=7,vd-,qnbz-,xh=9,jjktx-,md=7,gm=8,qnxp-,nnr-,gk-,qnk-,mk=9,ktgv-,dvkt-,px-,ftl-,xb=9,xb-,chkhk-,ffj-,zrffmj=7,kgx-,kql=7,zh=8,bx=8,ddk=2,hgzx=2,zm=3,gtpx-,kg=2,xbr-,pdzb=3,jxkd=3,txnqj=6,gzt-,zpp=7,pcflg=2,vq-,gm-,bkmr=8,lnhzc=7,jjn-,sfxv-,hfl=9,fr=9,gtf=1,qc=2,qspvk=3,dnx-,mf=6,dh=5,hp-,zgp-,bb-,gszqbt-,xrv-,vskx=8,nsfhs=1,mp-,qjqh=2,tnd-,rq-,khs-,cbr=4,flbhm-,zf=5,rnj-,sxn-,cnrlzv=2,gtpx=2,cm=8,gn=5,dc-,vkj=3,dvnj=1,kgf-,glp-,bm-,sbtf-,mjdj-,tkb=4,kq-,zzd-,bm-,bhc=7,vgt-,jsgjqh-,xrv=3,znh-,phlh-,pdtz=9,sqx=7,hxgp=1,kkx=6,cpdtnk-,nk-,flq=7,qnfb-,hqf-,xlg-,cdxlm-,zpp=9,vs-,pxz-,vxdpxs=2,mbbh=7,mv-,thhf-,xbr=2,ftl=9,ttcm=1,rp-,kz-,hqf-,vkjv=5,lnj=5,jv-,nk=9,sf=7,nv-,lps-,cdm-,nzqg=9,tpk=5,dhj-,dz-,ds=7,jk=8,bjqx=2,cr-,dvt-,jjn-,dskzb=6,rrxck-,sl-,cdm=2,cz-,lv-,dr=5,rcq=7,ds-,bm-,ts-,lvg-,cht=8,mjdj-,nr-,tbf-,gzr-,vbxd=3,jz-,kkx-,tn=8,nzqg=7,zfq=4,scpf=7,zm=7,lp-,cf-,mfdck=9,kr=1,fr=2,fnpj-,dvkt=3,td=5,nq=1,fkf=4,pvf-,kgf-,sb-,hf-,np-,pvqjdb-,vrd=1,frlb-,snmq=3,kgx=1,gtpx=1,zkjdmg=9,frlb=3,pskg-,rxvj=1,nd=9,mv=8,cn=2,gkpr-,vdk-,qc=9,sjl-,cz=4,zdqjpg=8,cnrlzv=9,scpf-,dvnj=5,tf-,frlb-,nk-,dhkj=5,dh=2,jvc=2,ptcxqk=2,lsrh-,tlsf=4,thhf=4,gs=8,sn=3,hmhf=4,cht=6,cp=7,ghks=1,hq=3,cnrlzv-,kfx=8,gdcm=3,vl-,mbf=1,zgp-,pdtz-,znv=3,zdbl=1,nv-,lsgd-,xmx=9,pz=3,fhx=6,jp-,tr-,dnx=3,xf-,pvr-,sl=8,lf=2,xxv-,mfrx=9,njx-,rjbd=2,xrv-,pvr=4,dhgfl=1,vld=6,ffzb-,rp=2,lbkn=9,zt-,thhf=4,ffj-,dhkj-,ls=8,zxm-,tff-,vjx-,ljz=2,cz-,zsp=7,cdm=4,nbpvc=3,bqf=9,rlhf-,zmn=1,cgv-,hfl=6,rv=3,gkpr=5,gzr=3,vkjv=5,lj=5,rm-,bzbn=5,nnr=8,mp-,hdxfn=2,gn-,fljtxr-,qnpq-,lsrh-,ffj=3,ptcxqk-,dd=4,tfnq=4,lg=9,sv=6,ljz=3,flf=2,vcf-,hd=4,dvkt-,jsgjqh=9,gv=9,zcstsg-,lmf=3,zcstsg-,qrn-,vhdv=4,bqf-,xx=5,rs=5,kpjzn=6,qnbz=1,tn-,hs-,nr-,fv-,nzqg-,gszqbt-,phlh-,ph=3,gl=6,sz-,dbf=8,vpc-,sfdrms-,jzlmc=6,dbf-,lg-,spm=5,hqz-,xj-,kr-,mkr-,flf=8,rhsr=1,dd=4,txt=6,psp-,vfp=6,tf-,fn=6,ftl-,hkn-,fv-,vxk-,mk-,rddks=5,qnpq=9,ljz-,jsgjqh-,ng=5,hd=9,mbf-,mj=9,mlb=7,pdtz-,fhx=3,zdqjpg=8,kxx-,hfrxnx-,fqs=9,pvf-,xzt-,xmx=3,lsgd=4,jq-,mv=7,pkhjq=2,rs=1,lmf=9,rsbv-,zt=9,jlz-,vpc=9,cf-,crbh=4,jgj-,qn-,dnx-,vpc-,ntn-,hdm=5,vxk-,ptcxqk-,rjbd-,dc=2,gs=1,vkjv-,vxk=7,jq-,bzzdx=1,qb-,khnxpv-,txnqj=1,ls-,lps-,zth-,bj=2,mbbh-,ml-,vh-,ljz=9,jvc=8,tnd-,ch-,ptcxqk-,hp-,vkjv=5,jgpd-,rz-,rlhf=4,flf-,rqb-,jsgjqh-,rnj-,dd-,gxv-,qnbz-,zt-,ss-,sg-,hgzx-,fljtxr-,pxktxc=9,zdn=6,crr-,flq=4,zdvr=3,tgjc=9,fkf=4,ddk=2,trh-,hkp=6,zm-,qnpq=6,sng=5,zdqjpg=7,jbp=6,szhrb-,hb-,pg=1,htpjdt=8,dgrcd-,mjdj=3,phlh-,grl-,cdm=3,ss-,zdn-,fkf=4,cs-,gp=3,dskzb-,dbf=7,gdcm-,glp=8,xhkgnf=5,mzj-,zhlf=9,njpm-,ntsc=3,hkn=1,td-,hcrm-,gkpr-,gkpr-,crbh=1,dhkj-,ltlq-,fj-,fljtxr-,pskg=6,sk-,bzbn-,szqvlv=5,fjvs=9,jsgjqh=8,rnj=1,sz-,ss=4,rzh-,xh=3,zrffmj=5,rfp-,fljtxr=2,xr-,bmcfk=6,gxjpj=6,hq-,vcf-,ml-,ml=6,lp=7,xk-,vkj-,vd-,rz=9,ldd=7,gxv=7,zcstsg-,rzl-,vqg-,xbr=2,dzb-,gv-,hch-,cc=1,qxr-,klj-,ghrs-,zhc=2,cxp-,hd-,zf-,tr=4,zvvjl-,jp-,zsp-,cdm-,qsbvl-,flbhm=5,frb-,vjx-,fv-,tqb-,ckk-,xf-,vxk-,zd=2,flq=2,grl-,hs=3,xf=7,fnpj=4,phlh=3,vqg-,gp-,gzr-,sqskr=3,flf=4,frlb-,vl-,rq-,fcc-,ndz-,hmhf-,fv-,kfc-,md-,zfq=3,tf=3,rzl=4,xrx-,kql-,hcv-,dx=8,xbm-,dx-,nzqg=5,tg=8,bxphd=9,zdvr-,blffq=8,mjmb-,hqz-,snmq=9,dskzb-,nkd-,qh=4,rfp-,jz=4,xhr=7,lf=6,bhqm=7,mk=1,zmh=9,hpmt-,hjsd-,qznqv=5,zq-,bh=7,dt=1,szqvlv-,lbkn=1,fd=9,cgrq=5,pnbm=4,fdk=6,zq-,xbr-,dsdm-,jxkd=8,fcq-,gdl=5,qsm=2,xj=4,jm-,bm=9,qb=2,dhkj=5,khnxpv-,nc-,xxv-,jbp-,ng-,kg-,jv=9,sv=8,sfdrms-,bmcfk-,jg=9,vbbm=2,znv-,hch=5,fcq=5,mv-,fmq=7,xx=5,ghrs=1,snmq=3,lhzbv-,gxzrf=2,qnxp-,kfx-,rnj=3,cr-,kkx-,tmp=4,jhtf-,md=4,zn-,rzh-,znh-,blffq-,hn-,ltlq-,gzt=9,vhdv-,sf=9,lj=1,tkb=5,jn=7,zld=1,kkx-,vgt-,rs-,bh=7,rz=4,rhsr-,zld=9,qcqx=7,jlz=9,tgj-,cht=4,ftcht-,jvc-,hfk=4,klj=3,szqvlv-,hkn=1,xxv-,zgp-,bmp-,dmt-,znv-,szhrb=8,zxm=3,hch-,vld-,pvcs-,cpx=5,pnbm=1,xzt=1,fv=2,mq=6,sqq-,zxm-,chkhk=7,nmlfxt=4,lps=5,xbm-,mjdj=6,rqb-,zgdcl-,rccrbh-,frb=6,dx-,jrmcp-,xxv-,zdbl=8,hdzx-,rxvj-,bb-,mhm=5,fxf-,kpc=2,mf=3,nd=4,cb=5,ftcht=2,jp=8,tkb-,vdk-,lj=2,dc-,rcq-,kq=1,hscb-,kdp=8,ghks=7,zdn-,nmlfxt=7,jsspr=4,kq-,gs=1,mjmb=3,rx-,qnbz=2,qd=2,xrx=6,ktgv-,lc-,skgz=2,dqt-,ddk-,bm-,vdk-,dvt=3,qm-,kgf=3,qmv-,zh-,ndttzn-,rzh-,nc-,sfdrms=3,zdbl-,zdqjpg=5,vpc=2,hkp-,fxf-,fkf=5,gdl=5,fcq=6,mbf=7,vkjv=6,rddks=9,kg=8,qsbvl-,gm-,fljtxr-,vcf-,dvt-,lv=1,pvqjdb=2,hfk=4,cdm=3,zdn-,mq-,bm-,dt-,cf=4,jgmq=7,sc-,fmq=9,gdcm=1,pdtz-,bkn=9,qsm-,jbgc=5,jz=4,jg=7,gp-,mn=7,rp=7,dmt-,zn=8,vfp=1,psfrk=4,jgpd=4,hkn-,zvlrx=9,jp=9,cs=5,trh-,rlhf-,md=7,jjn-,hscb-,qmv=6,ds-,nkn-,zcstsg-,ksvkx=9,dv=2,zdn=8,vqg=3,flf-,dbf-,xj-,rnj-,zsr-,hgh-,nms-,nmh=4,xh=1,rc=6,tmp=3,fdk=7,bmm=4,sv=9,jb=3,kxx-,bb=3,jhpq=5,nq=4,nc=2,cbr-,kp=5,gr-,tz-,dn-,ljz=2,dhgfl-,sn=7,pg=9,kgf-,ndz=5,qdlgh=4,sjl-,dv-,rddks-,dvt-,sg-,dgrcd=9,rlhf-,ckk-,zqr-,rx-,pfn-,djjft=7,dh-,gxv=2,rcq-,znh-,vdk-,kzf-,gt-,kzg-,mn=8,vgt-,gxv-,tbf-,jnlcs-,rccrbh-,rc=8,djjft-,mkr=6,xm=8,tfnq-,kz-,ng-,cv=2,jhpq=9,htpjdt=2,ntn-,gr-,lnhzc=4,cgv=2,kg-,xc-,mhs-,flf-,kzg=1,xm-,fljtxr-,hcv=7,ptcxqk-,zq=7,zcstsg=4,djflp=3,tfnq=9,zgp=9,hkp=2,tfnq=7,cf-,qm=2,tmp=5,lnhzc-,rnj-,hqz-,mlb=6,ttcm-,ktgv=1,bmcfk-,zpp=1,djjft=5,np-,nms=9,cf-,dv-,hn-,jm=1,zhc-,fxf-,xccn=3,hfk-,kgf=6,gv-,ldd-,lnhzc=4,gn-,fr-,npq=1,pnkhbj-,hjsd=5,xj=3,hn-,jsspr-,nvn=6,rccrbh-,jz=3,jxk-,gk-,kzg-,vzs-,dn-,frlb-,dx=8,sf-,knj-,sng-,cm-,ch-,zmn-,bqf=1,snmq=9,td=2,ntsc=5,fd-,xb=3,kzg-,sc=9,rzl-,cf-,vdk=3,kj=9,cv-,nb=7,bhmgm-,rv-,brdzm=5,kz=8,lj=7,hdzx-,sksk-,rddks-,tr-,fhx=8,kkx=2,xtsq-,gszqbt=7,ml=1,vd-,fd=8,cdxlm=1,jjktx-,sc-,gzt-,cv=8,zth-,bqf=5,jz-,gdl-,jq=9,rxvj=7,vcf-,znv=8,crbh-,qsbvl-,cqjpl-,kp-,cb=7,jjktx-,np-,klk=9,sq=3,rxvj-,fqvs=7,npf-,xj-,lnhzc=8,zqr=9,zhlf-,gv-,spm-,pkhjq=4,fdk=2,bmcfk=1,vskx-,xm=4,rhsr=3,hrbk=3,ffj-,fj=7,hdzx-,hz=6,hs-,nsh-,ddk=5,sg-,bmp-,kj=4,gdnv-,kdp=8,hqz-,bhqm-,np-,lp-,gpx-,dh-,nr-,nd-,jbp=9,sfxv=8,kp-,ckk=4,cpx-,px-,cn-,xt-,rjbd=6,pdtz=5,xmx-,jbp=9,gjm-,qznqv-,nr=6,nc-,zmn=5,xh=3,jjn-,rsfz-,tkb=4,jv=4,vl-,vfp=3,mz=6,cf-,rzh=7,xmx-,cf=4,zdbl-,hgzx-,kpjzn-,rsfz=4,pcflg-,sq-,gdcm=7,ts-,qh-,dc=4,pkhjq-,jvnd=1,tgj=8,mhm=6,spm=8,sjl-,hkn-,flf-,gpx-,qh-,bx-,hhpfdr=6,vgt-,sfxv-,mhm=8,mk=2,lhzbv=5,sjl=4,nd-,fxf=4,mzj=3,gjm-,cjvj-,lsrh=5,jxkd=1,nkd-,ml=7,zld-,gxjpj-,kdp=3,txt-,szqvlv-,ntsc=2,rxvj-,gxv=7,ftcht-,lp-,qrn=2,cgrq-,qjqh=2,qdlgh-,lp=5,cht=8,cs-,jz-,rccrbh-,zh-,djjft=5,kld-,qxr-,hd-,dn=3,pvcs=7,hfl=5,hmhf=8,tfnq=3,znv=4,mn=8,djflp=3,hdm=7,vrd=7,klj-,vzs-,zvlrx-,kj=5,gdnv=1,qm-,fj-,vbxd=4,tg-,qcqx-,nc-,ntsc=3,zvvjl-,zdvr-,rs=8,lnhzc=9,jsgjqh-,dqt=2,rsbv-,flf=3,npf-,ntsc=5,bkmr-,vbbm=4,vfp-,rx-,sv=8,tn=9,ntn=9,sk=7,qhbrv=3,tn=5,tfnq-,sl=9,zjf=1,qsbvl=7,kxx-,cdxlm=9,brdzm-,jv=1,sb-,tqb-,rlhf=5,gzt-,jxk-,xhr=9,mn=2,hjsd-,mv-,sc=8,tfnq=7,crbh=3,rddks-,gpx=9,ct=9,fv-,ffj-,kz=1,xbm-,lsrh=7,gt-,hlg=1,fkf-,qmv=2,dhj=5,flbhm=1,qc=5,cqjpl=4,mn-,nsfhs=8,tgjc-,dvt-,tfnq-,cc=5,kst=8,zgp=2,sl-,gtf-,cc-,bhmgm-,gs=7,vjx=5,pcflg-,dvnj-,gn=8,gr-,xj=7,sn=9,jcc-,dsdm-,mlb=1,xlg=2,zh-,nc-,qdlgh=4,flq-,fd-,khnxpv-,brdzm-,sbtf-,gtf=6,rhsr-,ct-,hkp-,kpc=8,bhmgm=5,tr-,jlz=8,vh-,hfrxnx=4,mbbh-,jzlmc=4,hn=1,px-,mhm-,pvf-,hcrm=8,fjvs-,zxm=5,xn=6,qb-,znh=6,xxv-,zvlrx=5,rddks=3,xhhp=1,jsspr-,kxx-,xk-,gp=2,tff-,sq-,khs-,rccrbh=7,ghks=2,dgrcd=1,jjktx=2,zmn=1,hs-,jjn-,cjvj-,zzd-,bhc-,zfq-,sv-,jm=7,hmhf=1,tr=5,ltlq-,jxk-,gdcm=8,bhmgm-,xkv=8,cr=4,fd-,gxjpj=9,ntsc=4,gxjpj-,kkx=1,mk-,pfn=9,hfrxnx=1,lpc-,rnj=6,bxphd=1,pxz-,xhhp=7,ghrs=5,phlh-,snmq=6,kld-,vq-,mzj-,rnj=9,cpx=5,kzf-,fn=7,xm-,ffj=9,xccn=1,gpx-,kst-,tg-,jbp=8,fv-,djflp-,cgv-,ltlq=2,gp-,nsh-,pz=8,dh-,rm-,vbbm-,lf-,jm-,ghrs-,zdn-,bh-,cv-,bmcfk=5,fr=5,qdlgh-,gszqbt-,ftl=1,jgj-,ch-,xx=8,xkv-,ttcm-,lnj-,xt=4,flq=6,hkp=2,jgj=3,gn=3,pskg-,dd-,djjft=6,mk=3,frb-,sfdrms=1,jsspr=1,qxr-,vs=3,cdm=2,brdzm=8,hkp-,nmlfxt-,tmp-,nphr=5,ldd=8,qb=6,ch=7,mv=9,bc=3,jgmq=8,skgz-,gp=2,jxkd-,gzr-,hxgp=5,lkm=3,nd=4,lj-,kst=2,gxzrf-,pxktxc=6,px-,gcxq-,jxkd-,zkjdmg-,hch-,cqjpl-,pg=6,vpdp=3,th=3,sksk=3,jvnd=7,ng=6,sqq=5,xh-,flbhm-,mbf-,sjl=6,qsbvl=1,ntsc-,qsm-,gt-,vkjv=3,sqx=3,pvf=9,sn=4,kxx=9,zvp=6,qn=6,blffq-,jz=1,mddp=5,tfnq=5,jk-,djflp-,lps-,zn-,hcv=8,tr-,ffzb-,hkp-,jzlmc=7,hfk=6,cgrq=6,rzh=3,dz=2,xdxjn-,hqz=8,jv-,jq-,kzf=1,pvf=3,mn=7,hkn=7,fj-,lmf-,qnbz=8,gdnv-,lc-,hgh=6,fkf=1,gn-,ml-,gxzrf-,grl=6,xf=4,jhpq=2,hdm=2,mgn=1,vfp=6,jp-,ngc=3,grl-,mbf=5,fxf-,tpk=2,psfrk=4,rddks=1,cm=5,xx=6,vd=4,bm=9,qsbvl-,fkf=5,sxn=2,gcxq=8,mgn-,hn=1,fqvs=3,vkjv=2,kgf-,hgzx-,scpf-,xkv=3,gdnv=8,xxv=4,qznqv=5,ndttzn=1,ks=1,nk=6,fj=4,vrc=4,nkd-,gn=5,tff-,rc-,qznqv=8,hp-,vpc-,cf=2,jrfq-,jp=7,dskzb=1,qnbz=4,lkm-,dx=2,fkf=9,flbhm=3,bhc=5,lj=8,ntn-,jrmcp-,ltj-,nphr-,vjx=9,jb-,djjft=2,tgj=1,ktgv-,ltj=6,njpm-,sng-,ksvkx-,rm=6,zm=2,gpx=5,mbbh-,zkjdmg-,fcc-,vdk=1,qznqv=7,nkn=9,zvlrx-,jzlmc-,szqvlv=9,kgx-,mk-,nd-,mhm=7,tf-,hfrxnx=5,pxktxc=3,jq=2,kj-,bzq-,zxm-,jm=5,zgdcl=5,xccn-,rcq-,hkp-,jgpd-,mddp-,tg-,kp=1,kr-,njpm-,gl-,hdzx=9,gkpr-,ntn-,hp-,hfk=6,qhbrv=6,ptcxqk-,zb-,kvhx-,qxl-,hch-,jvnd-,ks-,gszqbt=3,pnbm=3,hrpq=5,ckk-,fkf=1,sng-,xm=8,vrc-,cxp=5,zb=9,ngc=1,gdf=2,hq-,dvt=1,scpf=3,skgz=1,mz-,mq-,lj-,vjf-,jb-,nqvpv-,jrmcp=3,np-,klj-,sfxv-,rx=3,jk=7,kql=2,vxdpxs=9,ldd=9,njx=5,ttcm-,lc=2,cnrlzv=2,np-,dzb=2,qcqx=6,vdk-,cgrq-,dqt=5,cgv=3,fn=7,rsfz-,jzlmc=9,vs=9,jxk=4,rv=5,spm=9,mq=9,rsbv=1,nr-,hxgp=6,pxktxc=5,jk=1,rsbv=3,nkn-,cbr=5,dvt=6,gzt-,bzq-,kq=2,dc=3,dnx-,hch-,qnbz=6,mf=7,tgj=2,zd-,tpk-,rq-,mz-,fn=9,lkc-,jhpq=2,cf=5,cm-,fnpj=8,frb-,xn-,sqq=5,vrd=8,psfrk-,xt=8,hfk-,kz=3,zvvjl-,kpjzn=3,vrd-,cm=2,zrffmj=3,ntn-,gr-,sk=1,mjmb=4,nmh=5,cpx=2,jrmcp=8,nv=2,bmp-,fn=6,xb-,tqb-,ngc-,sz=1,mzj-,jcc=9,fd=4,zsr=1,sq=5,vhdv=3,jsgjqh-,bhc-,xbr-,qrn-,hdm=8,hn-,xkv-,xhhp=7,nsh=1,dn=4,flf=3,jhtf=3,kld=7,vjf-,blffq-,cc-,bjqx=7,kkmf=1,hgzx-,hz=3,gdnv-,gcxq=3,ksvkx-,bj=8,zrffmj-,dvkt=8,fn=2,gk=7,rq-,jhpq=7,znv-,jgj=4,jsmql=7,hjsd-,zmn=6,vq-,xmx=8,gs-,bqf-,fnpj=2,gtpx-,trh=3,skgz=4,gdl-,bb-,kz-,pvr-,pxktxc-,gxzrf-,lp=7,vqg=8,szhrb=8,fmq-,vrc=6,fcq-,ktgv=7,zdqjpg-,hch=1,lv=4,nb=6,vl=8,flbhm-,sk-,gpx-,sfdrms-,hkp-,zh-,jq-,sl=6,xb-,snmq-,xb-,bkmr-,nbpvc=9,zh-,fzk=9,rz-,hkn=7,nmh-,mgn-,szhrb=8,psp-,xrv-,frlb=2,dx=2,djjft=1,qnbz=1,px=3,ljz-,rlhf=4,cdm=3,rcq=3,xn-,mf-,bkn-,vcf=9,bh-,dt-,cc-,vpdp=8,sksk=4,vkj=9,hqz=6,zzd-,nkd-,ptcxqk=7,ptcxqk-,jz=3,xc=2,md=8,ls=2,jvl-,jhpq=6,hxgp=6,nmh-,gp-,ldd-,hgzx-,hqf-,cnrlzv=9,cht=8,gs-,zgdcl-,xc=7,vq=9,fhx-,zgp=6,spm-,xrv-,gn=8,gxv=2,hqf=1,sfdrms-,zxm-,kkm=9,zmh-,sfdrms-,ls=2,qr-,jbp=5,jxkd=4,ttcm=9,qnfb=7,hscb-,kgf-,qsbvl=9,njpm-,vdk-,ttcm=9,qrn-,zzd=8,mj-,bkn-,tg-,vq=6,bxphd=3,xbm=5,vxdpxs=8,mfdck-,klj=1,bhc-,jvc=6,zsr-,sjl-,spm=9,tgjc=7,kgf=6,cdxlm=9,zqr=1,lpc=7,gzt-,hfrxnx-,mhm=9,dvnj=7,cz-,gv=3,rnj=9,zvlrx=9,dhgfl-,rrxck-,pskg-,nsfhs-,jxkd=9,zmh-,lrf-,fnpj-,xlg=9,jq-,kpc=5,flq=3,fnpj-,kg-,bmcfk=1,cdm-,rjbd-,xf=2,zqr-,gp=8,nbpvc=4,sk-,sb=3,xhkgnf-,hb=3,rsfz-,tgjc-,dxq-,kg-,zq=6,xrx-,nf-,vjf=8,jz=4,hcv-,cbr-,jrmcp-,jp=7,xj-,rg=1,vzs-,sc=8,cgv=6,zt=3,pnbm=3,ttcm-,mbbh=2,lkc-,dvnj-,mhs=3,bqf-,xdxjn-,sq=1,ltj=7,ss-,zhc-,djjft=3,cp-,hrpq=2,ghks-,bkn-,fljtxr=3,hb=6,xdxjn-,xm=2,hlg-,hq-,jsgjqh=9,bmp=1,hfrxnx-,hqz=8,sqq-,xj-,dqt-,sv=5,gn-,vfp=6,fmq-,khnxpv=6,kzf-,gn=1,hq=6,zd-,skgz-,qb=9,hch=7,phlh-,xj=1,mbf-,dxq-,jsspr-,ckk=2,qznqv=1,rm=7,xhr=2,khnxpv-,mbf-,cf-,zb-,gpx=5,vfp=5,zsp-,sfxv=9,bhqm=2,hkn=2,dxq-,dhgfl=6,vgt=3,htpjdt-,cz=1,gt=2,bkmr-,bzq-,zdn-,sz=6,zdvr-,jv=3,lrf-,jg=2,jjktx=1,jn=6,djflp-,bm-,dmt-,hrpq-,jvnd=4,njpm=5,zh-,qznqv=2,rhsr=3,gpx=1,mn-,rs=8,mlb=2,tmp=9,ptcxqk-,ct-,fv-,qn-,fqvs-,gpx-,zm-,vjx=9,ftl=2,tff=7,hq-,lps=6,csz=9,bjqx=4,hn-,hkn=8,zgp-,ftl=6,qsbvl=4,kkmf-,zvlrx=5,zdqjpg-,ch=6,zqr-,vkj=5,rqb=7,mk-,hdzx=3,vd-,bmcfk-,csz=1,ntn=9,rlhf=1,pvr=5,npf=2,blffq-,dqt=2,cdxlm-,vkj=3,ndz=6,rz=9,jzlmc=4,vfp-,xh=4,rp-,qnxp=2,qsbvl=1,mj-,kzg=7,rzh-,kpc=1,rjbd=6,rzh-,sqskr=5,rnj-,kfc=4,xb=9,lvg=7,kgx-,qm=4,hrpq-,mbf=7,ds-,qdlgh=1,gkpr=3,fkf=2,cbr-,lv-,tqb-,mbbh-,xm-,fn=2,lbkn=6,qmv-,vs=3,jgmq=8,ptcxqk-,bhc-,px-,qdlgh-,jg-,jbgc=4,hcrm=5,ntsc-,mzj-,fcq-,mddp=2,zt=6,flf-,pvcs-,flf=3,bxphd=1,qrn-,ndz=5,sn-,fmq-,sf=8,djjft-,ltj-,dc-,kz=8,mzj-,gpx=4,ttcm=6,brdzm-,zld-,npq=4,dgrcd=4,zth-,bc=9,sjl-,blffq-,xxv-,bkmr-,fjvs-,kp=2,sfxv=5,xmx=9,zdvr=4,jb-,grl-,gm-,jsspr-,nzqg=6,dz-,zfq-,pvcs-,zvlrx-,rccrbh=3,np=5,fhx-,tfnq=5,ss=3,qn=4,fxf-,flq=5,vd-,vh=5,cdm-,gtpx-,flq-,xhhp-,cxp=3,rnj=1,xk-,nsh-,rqb-,bkn=2,qnxp=6,gk-,ct=8,xn=9,bhmgm=1,mv-,jxkd=1,jrmcp=4,tnd=3,td=5,tlsf=4,gv=9,kfc=8,jjn=3,lnhzc=1,bmp=3,mjmb-,vkjv=4,cht-,mbbh-,mj=1,gk-,dbf=6,lmf-,gjm=6,hch=3,vjf=2,cn-,tqb-,sb-,kvhx=7,nsh=2,gs=4,gpx=1,dhj=8,cr=8,flf=9,bmp=6,zh=2,bxphd-,jq-,vpc-,dmt=9,tfnq-,bjqx-,qc-,gxv=3,mq=8,ng=9,mfdck=3,ct-,bjqx=1,thhf-,txt-,zvp=7,npq-,rfp-,qjqh-,bjqx-,vjf=9,rxvj=3,sq-,cdm-,mkr-,xhkgnf-,qh-,cb=2,mhm=6,pnf-,rz-,pvf=4,xx=9,bjqx-,jxkd-,cbr=4,sb=8,xj=9,jq=7,rzl=7,qhbrv-,lp-,qxl=6,zm-,dhkj=3,frb-,jn-,scpf=2,mj=5,jrmcp-,xb-,ldd=1,bhc-,jjn-,zzd-,zgdcl=8,kxx-,rxvj-,jgpd=5,nzqg-,qb=9,gp-,vgt=6,cs=1,rlhf-,qh-,nf=9,jgj-,zfq=4,xh=8,pz-,gdnv=6,sfdrms=9,hrbk-,gdnv-,zcstsg=7,hcv-,zsp=9,rzh=7,rv-,xh-,tz-,rz=8,dbf-,mgn=5,sv=6,sn-,xmx-,cm=5,pvr=4,jxk=9,zdbl=3,hch-,zkjdmg=3,rrxck-,fcc=9,vhdv-,jsmql-,xbm-,hgh-,bzbn-,gxzrf=3,zqr=8,zpp-,ckk=1,tbf=4,vhdv-,bmp-,cdm=6,ffzb=6,gdl-,xx-,sng-,bqf=9,hp=4,lj=5,kg=7,ffj-,nvn-,xccn=7,zdbl-,xx-,nkd-,npf=1,psfrk-,mn=3,fxf-,zvvjl-,qr=8,dz-,hdxfn-,dvkt-,dmt=4,dskzb=1,txt-,xt-,rs-,dhj=8,mhm=1,ss=1,ntsc-,bmm-,mq=1,kpjzn=9,jv-,ph=9,cz=2,td=6,zn=8,jjn-,tkb-,dhkj=2,hn=9,hcrm-,nkd=2,cnrlzv=3,sqskr-,nzqg-,qnfb-,vjf-,cjm-,flf=8,bmcfk=2,qznqv=9,djjft=2,blffq=6,gdl=8,qn-,hcrm=4,mbf=4,hdxfn=2,cdm=5,hkn-,qc-,xc=7,tbf-,nc-,sl-,jvl=9,gs-,ghks=8,jk-,xx=7,hs=6,vq-,zf=4,xt-,vfp=4,fcc-,ltj-,ddk=7,sng-,hhpfdr-,dx=1,cv=9,dsdm-,cbr-,zzd=1,jm-,sf=7,nk-,xt-,bc=1,sqx-,tn=9,rsbv-,hfk=6,vrd-,nf-,dvkt-,jk=9,xxv-,xkv=9,trh=4,rnj=6,gzr-,rg-,flq=5,rnj-,hmhf=8,lpc-,gtf-,rnj-,bhc-,lnj=6,jhpq=9,qdlgh=5,ng-,zkjdmg=9,ts=1,ph=9,dskzb-,rccrbh=5,xhhp-,ml=9,kj=7,blffq-,nqvpv=4,dd=6,ftl-,tz-,trh-,hpmt=4,hmhf-,txnqj=5,lv-,jvl=6,dvnj=7,zkjdmg-,fcc=7,bm=7,lhzbv-,bh=5,xx=4,qxr=7,djflp-,qjqh-,fv=3,gs=8,kg=2,tkb-,qnbz=2,jbgc-,jvc=2,jn=6,xrx-,zhlf=3,fmq-,jjn-,vqg=2,lbkn=9,zn-,lp-,zb=6,mgn=6,gv-,jp=7,gxzrf=1,jgmq=7,knj=7,dhkj=1,ds-,px-,xlg=1,mfdck=1,zth-,pj-,xzt-,np=7,sz=3,hmhf=1,lpc-,rjbd-,gdf-,ss=4,bhc-,bc=7,rsbv-,rv-,lmf-,rsbv=5,hqz-,rqb-,nk=5,rccrbh-,gdl-,dvkt-,fmq-,ds=5,kld=3,lrf-,qnk-,jm-,hhpfdr-,ddk=8,qcqx=2,ltj=1,kkmf-,zxm-,dd-,bkn=6,fmq-,gpx-,qr=1,hfrxnx-,blffq=9,jvc=6,rjbd=3,kzf-,rs=2,lf=7,ts-,sb=8,cp-,qjqh-,gp=4,fj-,qznqv=7,xccn-,bhmgm=8,nc-,pvf=9,nq=6,hn=5,gk=3,hjsd=9,jrfq-,sg=9,vpdp-,zh-,rg-,xc-,khnxpv-,jv-,nc-,sxn-,pvqjdb-,zxm=1,xc-,vjx=1,ls-,hjsd=6,vs=8,knj-,qr-,vpc=3,hjsd-,dhgfl=8,chkhk=5,xb=9,lg-,lps=2,knj=9,rp-,zsp=5,qxl=2,hxgp=9,zf=2,kpjzn=4,xhhp-,dhj-,jsmql=9,hfl-,hkp-,cr=4,nnr-,rx-,vkj-,xc=9,bj-,xrv=9,nmh=4,vpdp=1,hgh-,sfxv=2,fv-,kr-,vl-,xb=9,xf=5,mbf=9,fcq=1,zn=9,zxm-,zd-,gjm=9,gxv-,znh-,jjktx=3,qznqv=4,hqz-,vh-,gv-,mfrx-,mj=9,qmv-,ds=7,ltlq=5,bmcfk-,kpjzn=6,hcv=1,fd-,nnr-,dxq-,xr-,lc=1,hmhf=4,rq-,xbm=9,qdlgh=6,fmq=7,tr=4,jjn-,gs-,dv=5,jnlcs=3,lps-,zrffmj=2,lp=8,xx-,ndttzn-,ltlq=3,sqskr=9,snmq-,dvnj-,hs=8,zld-,spm-,kxx=7,rqb-,knj=8,bb=1,fkf=5,ffzb-,bzbn=9,fn=2,rq=3,xk-,vdk-,jp=2,qr=1,pg-,hgzx-,fcc=4,gxzrf-,sbtf=1,dv=5,xrx=8,jz-,lf=3,zcstsg=9,kp=5,hntnvb-,kg-,gdl=1,qn-,vfp=5,xxv-,nkn=9,qdlgh-,xhkgnf-,dvnj-,lc=5,rcq=3,kgx-,qspvk-,tbf=7,ljz-,ttcm-,hfk-,ml-,kfc-,psp-,kr=5,zpp-,nc=1,lsgd=9,bkn=2,ffj=7,jz-,th-,bmcfk=7,mv-,pnf=9,qjqh=7,cz-,bhqm-,bjqx-,tn-,jlz=5,ss=9,vl-,tff=8,pnf-,xt=5,zgp-,lg=7,qn=3,zmh=4,md-,nkd=9,mlb-,gxzrf=8,jgmq=3,mn-,gm=4,tfnq-,dd=4,lj-,xr-,zkjdmg-,gjm=2,qn-,nphr-,vjf-,bx=4,sfdrms=6,npf=4,vjf=9,ltj=6,xr-,gdnv=4,kp=5,cnrlzv=6,vjx-,fqvs=4,cm-,cr=6,zsr-,qd=1,grl=2,ng=5,ckk=3,ktgv=2,fcc=2,jq-,bmp-,qnfb-,ng=9,ch=8,sqskr=1,cm-,cn-,xk-,jxk=3,qxl-,ddk-,nbpvc=6,vs=5,qmv=9,jgmq-,gdl-,cdm=1,klk-,ls-,zjf-,vxk-,kg-,zhc=7,tn-,nsfhs-,thhf-,lpc-,mjdj=2,dr-,fdk-,xrx=5,fqvs=7,sc=1,jzlmc-,tnd=1,qnfb-,klk-,kql=5,zhc=9,dxq=2,xf-,qxl=3,rqb=7,lkm-,vkj=7,ss-,hrpq=6,rrxck=1,hgh=4,lhzbv=1,khs=9,gdcm-,bhc=2,hgzx=1,jsmql=4,khnxpv-,fxf=7,zn=1,ls-,vzs-,fhx=7,jbgc=2,bzq-,hscb=7,vh=6,bmp-,lvg-,ttcm=6,nmh-,hkp=2,grl-,csz=6,ts=9,zdvr=4,pdzb=1,kst=4,chkhk-,njpm-,sbtf=9,ktgv=9,vkj=3,bkn-,lpc-,cpdtnk-,gv-,th=3,tr=4,qsbvl-,pskg-,qmv-,skgz=3,jxkd=4,gdf-,fd=5,gdl=9,lhzbv-,bmm-,hfk=1,kr-,rm-,gv=4,kkmf-,npq=2,dnx-,fkf=3,hrbk-,ckk=7,cpdtnk=6,bh-,fnpj-,jrmcp=9,mhs=8,gdcm-,nv-,qd=3,sjl-,kfc-,hs-,khs-,knj-,mzj=7,ffzb=7,nf=6,frlb=1,dv=1,tgjc=5,hf-,sb-,qn-,dgrcd=3,sqq=1,xbr=8,zpp-,njpm=5,xr-,vh-,gv=1,gp-,bj-,jgj=9,gkpr-,rrxck-,hjsd-,rm=1,gszqbt=4,khnxpv-,tg-,kdp=8,nmlfxt-,zkjdmg=2,lnhzc-,cv=6,vskx=2,ttcm-,sfxv-,phlh-,kzf=8,lkm-,rccrbh-,zfq=9,rc-,gnk=6,vcf=3,gcxq=2,hkp=7,kdp-,hn=7,mfdck=5,qsbvl-,mddp=3,pg=9,tbf-,mn-,gxzrf=8,sf-,vdk=8,lvg-,zdvr-,qrn-,jrfq=9,vld-,mlb-,zvlrx-,szqvlv=4,pskg=6,vh=4,qb-,rxvj=2,gp=4,hf=1,jvl=3,zdqjpg=9,fjvs=3,vpdp=8,fcc-,hqf=7,zzd-,zq-,mbf-,hqz=6,lps=1,tbf=4,hcrm=9,dhkj-,rccrbh=2,kq=7,mzj-,rrxck=3,zn-,mfdck-,gr=6,jvc=9,hq-,vbxd=4,cz=4,lf-,qspvk-,ltj=1,zhc-,flbhm=5,qm=6,hdzx=6,tbf-,tf=5,qd=8,pdzb-,klj-,mddp=2,nk=3,dsdm=3,cbr-,mq=4,xrv-,pz=7,dhj=4,nnr-,bj=6,sh-,gr-,fnpj-,lt-,kq=5,dr=8,tpk-,vdk=7,qsbvl-,qnxp=3,ndz=9,rs-,jzlmc-,qjqh=5,mkr=9,tnd-,kkm-,qxl-,ntsc-,mz=5,qnk-,mhs=4,bx=9,qmv=6,xh=5,cr-,hkn-,vbxd=4,qd-,zmh-,sfxv=8,tkb=9,pxz-,xmx-,rz=2,gxjpj-,grl-,rz=9,sksk=8,cm-,zpp=2,pj=8,ntn-,hkn=4,zkjdmg-,bhqm=2,bh=6,hpmt=8,mhm-,gdl=9,kfc=3,xx=1,djflp=5,ttcm=5,qnbz-,crbh=8,mp-,tfnq=9,nms-,cr=3,ksvkx=9,bmm-,hxgp=5,ttcm-,bzbn-,xhr=9,gv=9,zfq-,jvnd-,jjktx=1,pkhjq=7,frb-,hz=4,xhr=3,gszqbt-,xm-,gm=6,fljtxr-,cpdtnk-,zvp-,tz-,dz-,jlz-,lsgd=5,qcqx=3,nzqg-,vzs-,kq=4,fd=9,jnlcs-,nc-,sz-,pskg=1,bhqm=4,khnxpv-,dvt=2,lj-,gdf-,ts-,qdlgh=5,hntnvb=4,rjbd-,snmq-,pskg=6,frb-,fdk-,kpc-,pcflg=9,rv-,gt-,nv-,kzf-,gp-,frb-,jnlcs=5,grl=7,fcc-,ng-,mzj-,kzf-,sh-,kpjzn=3,gcxq-,dbf=5,gdnv-,vkj=1,tqb=5,rq-,dn-,zxm-,mzj=1,kzg=4,nnr=7,jgj-,vjzl-,xmx=5,hrpq-,ktgv-,ttcm-,rnj=1,qb-,sk-,cjvj-,mfrx=1,cz-,dhj-,mhs-,qmv=9,qxr=2,vh=8,spm=3,rsfz=1,cgrq=7,xm=7,zhlf-,kz=9,dc-,fjvs=8,lps-,nmlfxt=7,ts=9,fcq-,kr=2,npf-,szhrb-,zkjdmg=7,ljz=1,blffq=6,lbkn=6,cf-,vgt=9,gm=8,nq=2,ffj=6,zvp-,djjft-,tgj-,lkm=4,sfxv-,rz=6,psfrk-,zth-,pnkhbj-,zgdcl-,ktgv=9,bjqx-,ntsc=4,cxp-,ml=1,qc-,kzg-,sng=8,grl-,mfrx-,xlg-,hdm-,ftcht=2,zt=9,flbhm=6,pskg=7,jgj-,kvhx=5,cr=1,dxq=5,nkn=8,vld=9,xrx=6,cz-,zzd=5,szhrb=3,hrbk=9,rv=8,zjf-,hdzx=6,zcstsg=3,fr-,lnhzc-,fzk=3,jjktx-,sqx=3,fr=6,rs-,gdnv-,cm=8,dx-,cth=7,cz=8,xrx-,mf=8,jk=3,jv-,qhbrv-,nq-,txnqj-,sv=4,zgp-,sg-,tg-,jq-,hfrxnx-,gszqbt=3,mq-,hrpq=9,vxdpxs=4,trh=9,ffj-,rzh=6,gxv-,kzg=3,kj=9,vjx=2,cm=2,cc-,sh=3,fjvs-,mf-,lbkn-,kvhx-,jgj-,gm-,mhs=3,rqb=4,sn-,mjdj-,kq-,xrx=2,fcq=4,xt=9,khnxpv-,sqx-,rzh=2,jjn-,ss=9,kzf=6,dbf-,hpmt=1,td-,rq-,xj-,nv-,fqvs=9,hcv-,fr-,qnbz=7,bb=9,qsbvl-,lc=1,vpdp=3,pz=1,rnj=3,rfp=4,tff=5,cs-,zsp=7,cqjpl-,vskx=3,tn-,tn-,tf=4,nr=2,kpjzn=3,hjsd=6,vjzl-,hdxfn-,rhsr=5,snmq=9,znv-,kgf-,zsp=2,rc=9,fd-,gk-,cp-,lg-,tbf-,szqvlv-,rz-,sz=6,hpmt=4,vbxd-,kxx-,bx-,gkpr=9,qr-,bqf-,fljtxr-,hs-,rs=4,ls-,pcflg-,ttcm-,bh=3,vhdv=5,nk-,jk-,hntnvb=7,hhpfdr=4,rc=4,cpx=1,txnqj-,cp=5,rsbv-,lbkn-,rlhf=5,fnpj=5,gm-,lv-,kkmf-,xj=7,vzs-,zd=2,nmh-,bmcfk-,xj=4,zld-,tr-,bhc=8,mk-,dvnj-,jb-,pvr=2,fzk=4,xf=3,hpmt=1,vh=6,dz=2,td-,kg-,rx-,zth-,cr-,flf-,fnpj=1,gdcm-,hs=9,qspvk=9,sq=7,kdp-,nmlfxt=3,qnk=7,jsspr-,xt-,knj-,qr=2,ffzb=9,qhbrv=3,zhc-,zzd-,bzzdx=5,dd=1,gxv=4,mddp-,gk-,rnj=6,sb-,xx-,jrfq-,dr=9,ks-,qrn=1,pcflg=3,zn=2,hkp-,dt=1,mq=8


